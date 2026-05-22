data "aws_iam_openid_connect_provider" "this" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_role" "github_actions" {
  name = "${var.project}-github-actions"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Federated = data.aws_iam_openid_connect_provider.this.arn },
        Action    = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = { "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com" },
          StringLike   = { "token.actions.githubusercontent.com:sub" = "repo:${var.github_owner}/${var.github_repo}:*" }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "github_actions_policy" {
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = ["ecr:GetAuthorizationToken"],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action = [
          "ecr:CompleteLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:InitiateLayerUpload",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:BatchGetImage"
        ],
        Effect   = "Allow",
        Resource = aws_ecr_repository.this.arn
      },
      {
        Action   = ["lambda:UpdateFunctionCode"],
        Effect   = "Allow",
        Resource = aws_lambda_function.this.arn
      }
    ]
  })
}
