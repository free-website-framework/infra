variable "project" {
  type    = string
  default = "free-website-framework"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "backend_github" {
  type = object({
    owner               = string
    repo                = string
    branch              = string
    python_version      = string
    mangun_handler_path = string
  })
  default = {
    owner               = "free-website-framework"
    repo                = "backend"
    branch              = "main"
    python_version      = "3.14"
    mangun_handler_path = "app.main.handler"
  }
}

variable "frontend_github" {
  type = object({
    owner  = string
    repo   = string
    branch = string
  })
  default = {
    owner  = "free-website-framework"
    repo   = "frontend"
    branch = "main"
  }
}

variable "cloudflare" {
  type = object({
    account_id = string
    api_token  = string
  })
}

variable "google_identity_provider" {
  type = object({
    client_id     = string
    client_secret = string
  })
}

variable "email" { type = string }

variable "domain_prefix" {
  type        = string
  default     = "szymon-cloudflare-pages"
  description = "This vaule will be used in the final url like https://<domain_prefix>.pages.dev/. It needs to be unique across all Cloudflare Pages projects. If it is not unique, the url will will be created with a random suffix like https://<domain_prefix>-randomsuffix.pages.dev/"
}
