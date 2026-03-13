data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "this" {
  name               = "lambda-role"
  assume_role_policy = data.aws_iam_policy_document.this.json
}

resource "aws_iam_role_policy_attachment" "logs" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_dynamodb_table" "this" {
  name         = "fastapi-db"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "pk"
  attribute {
    name = "pk"
    type = "S"
  }
}

resource "aws_iam_role_policy" "dynamo" {
  role = aws_iam_role.this.id
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{ Effect = "Allow", Action = ["dynamodb:GetItem", "dynamodb:PutItem"], Resource = aws_dynamodb_table.this.arn }]
  })
}

resource "aws_lambda_function" "this" {
  function_name = "${var.project}-lambda"
  role          = aws_iam_role.this.arn
  filename      = archive_file.package.output_path
  code_sha256   = archive_file.package.output_base64sha256
  handler       = var.mangun_handler_path
  runtime       = "python${var.python_version}"
  architectures = ["arm64"]

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.this.name
      TABLE_PK   = aws_dynamodb_table.this.hash_key
    }
  }
  # reserved_concurrent_executions = 1
  # Limit to 1 concurrent execution to limit costs
  # if you get an error:
  # "Specified ReservedConcurrentExecutions for function decreases account's UnreservedConcurrentExecution below its minimum value of [10].""
  # it probably means you have a test account with 10 concurrent executions limit, but you can reserve up to the Unreserved account concurrency value minus 100
  # https://eu-central-1.console.aws.amazon.com/servicequotas/home/services/lambda/quotas
}


resource "aws_lambda_function_url" "this" {
  function_name      = aws_lambda_function.this.function_name
  authorization_type = "AWS_IAM"
}

resource "aws_lambda_permission" "this" {
  statement_id           = "AllowPublicInvokeFunctionUrl"
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = aws_lambda_function.this.function_name
  principal              = "*"
  function_url_auth_type = aws_lambda_function_url.this.authorization_type
}

resource "aws_iam_user" "this" {
  name = "${var.project}-url-invoker"
}

resource "aws_iam_access_key" "this" {
  user = aws_iam_user.this.name
}

resource "aws_iam_policy" "this" {
  name = "${var.project}-invoke-lambda-url"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunctionUrl",
          "lambda:InvokeFunction",
        ]
        Resource = aws_lambda_function.this.arn
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "this" {
  user       = aws_iam_user.this.name
  policy_arn = aws_iam_policy.this.arn
}
