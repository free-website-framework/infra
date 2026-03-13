
module "backend" {
  source              = "./modules/backend"
  project             = var.project
  env                 = var.env
  github_owner        = var.backend_github.owner
  github_repo         = var.backend_github.repo
  github_branch       = var.backend_github.branch
  mangun_handler_path = var.backend_github.mangun_handler_path
  python_version      = var.backend_github.python_version
}


module "frontend" {
  source               = "./modules/frontend"
  name_prefix          = var.project
  account_id           = var.cloudflare.account_id
  api_token            = var.cloudflare.api_token
  email                = var.email
  google_client_id     = var.google_identity_provider.client_id
  google_client_secret = var.google_identity_provider.client_secret
  domain_prefix        = var.domain_prefix
  github_owner         = var.frontend_github.owner
  github_repo          = var.frontend_github.repo
  github_branch        = var.frontend_github.branch
  backend_url          = module.backend.url
  backend_access_key   = module.backend.access_key
}
