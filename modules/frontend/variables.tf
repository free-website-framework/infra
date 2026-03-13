variable "name_prefix" { type = string }
variable "account_id" { type = string }
variable "api_token" { type = string }
variable "email" { type = string }
variable "google_client_id" { type = string }
variable "google_client_secret" { type = string }
variable "domain_prefix" { type = string }
variable "github_owner" { type = string }
variable "github_repo" { type = string }
variable "github_branch" { type = string }

variable "backend_url" {
  type      = string
  sensitive = true
}
variable "backend_access_key" {
  type = object({
    id     = string
    secret = string
  })
  sensitive = true
}
