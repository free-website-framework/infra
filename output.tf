data "aws_caller_identity" "this" {}

output "AWS_ACCOUNT_ID" {
  value = data.aws_caller_identity.this.account_id
}

output "AWS_ROLE_FOR_GITHUB_ACTIONS" {
  value = module.backend.github_actions_role_name
}

output "ECR_REPOSITORY" {
  value = module.backend.ecr_repo_name
}

output "ECR_IMAGE" {
  value = module.backend.variables.image_name
}

output "forontend url" {
  value = module.frontend.url
}
