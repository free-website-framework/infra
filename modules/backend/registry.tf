resource "aws_ecr_repository" "this" {
  name = "${var.project}-backend"

  image_tag_mutability = "IMMUTABLE_WITH_EXCLUSION"

  image_tag_mutability_exclusion_filter {
    filter      = "latest*"
    filter_type = "WILDCARD"
  }
}
locals {
  dummy_image_uri = "${aws_ecr_repository.this.repository_url}:dummy"
}

# This is needed to create the ECR repository and push a dummy image before creating the Lambda function, otherwise Terraform will fail with an error that the image doesn't exist. After the Lambda function is created, the dummy image will be replaced with backend image built in the GitHub Actions workflow.
resource "null_resource" "bootstrap_dummy_image" {
  triggers = {
    image_uri = local.dummy_image_uri
  }

  provisioner "local-exec" {
    command = <<EOT
aws ecr get-login-password | docker login --username AWS --password-stdin ${aws_ecr_repository.this.repository_url}

docker import /dev/null ${local.dummy_image_uri}
docker push ${local.dummy_image_uri}
EOT
  }
}

resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 5 images"

        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 5
        }

        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_iam_openid_connect_provider" "this" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]
}

resource "aws_iam_role" "github_actions" {
  name = "${var.project}-github-actions"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.this.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          },
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_owner}/${var.github_repo}:*"
          }
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
      }
    ]
  })
}
