resource "aws_ecr_repository" "this" {
  name                 = "${var.project}-backend"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = var.env == "dev"
}

locals {
  dummy_image_uri = "${aws_ecr_repository.this.repository_url}:dummy"
}

# This is needed to create the ECR repository and push a dummy image before creating the Lambda function, otherwise Terraform will fail with an error that the image doesn't exist. After the Lambda function is created, the dummy image will be replaced with backend image built in the GitHub Actions workflow.
resource "null_resource" "bootstrap_dummy_image" {
  triggers = {
    image_uri = aws_ecr_repository.this.arn
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
        action       = { type = "expire" }
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 5
        }
      }
    ]
  })
}
