output "url" {
  value     = aws_lambda_function_url.this.function_url
  sensitive = true
}

output "access_key" {
  value = {
    id     = aws_iam_access_key.this.id
    secret = aws_iam_access_key.this.secret
  }
  sensitive = true
}

output "github_actions_role_name" {
  value = aws_iam_role.github_actions.name
}

output "ecr_repo_name" {
  value = aws_ecr_repository.this.name
}
