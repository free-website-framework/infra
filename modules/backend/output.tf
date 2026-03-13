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
