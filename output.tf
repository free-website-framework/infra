data "aws_caller_identity" "this" {}
data "aws_region" "this" {}

output "deployment_summary_text" {
  value = <<EOT
These are the values to use in backend deplyment and GitHub Actions secrets:
AWS_ACCOUNT_ID=${data.aws_caller_identity.this.account_id}
AWS_ROLE_FOR_GITHUB_ACTIONS=${module.backend.github_actions_role_name}
AWS_REGION=${data.aws_region.this.id}
PLATFORM=linux/${module.backend.lambda_arch}
ECR_REPOSITORY=${module.backend.ecr_repo_name}
LAMBDA_FUNCTION_NAME=${module.backend.lambda_name}
EOT
}

output "frontend_url" {
  value = module.frontend.url
}
