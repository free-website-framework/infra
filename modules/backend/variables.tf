variable "project" { type = string }
variable "env" {
  type = string
  validation {
    condition     = contains(["dev", "prod"], var.env)
    error_message = "Environment must be either 'dev' or 'prod'."
  }
}
variable "github_owner" { type = string }
variable "github_repo" { type = string }
