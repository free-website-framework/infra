resource "cloudflare_pages_project" "this" {
  account_id        = var.account_id
  name              = var.domain_prefix
  production_branch = var.github_branch

  build_config = {
    build_command   = "npm run build"
    destination_dir = "dist"
  }

  source = {
    config = {
      production_deployments_enabled = true
      owner                          = var.github_owner
      production_branch              = var.github_branch
      repo_name                      = var.github_repo
    }
    type = "github"
  }

  deployment_configs = {
    preview = {
    }

    production = {
      env_vars = {
        "BACKEND_URL" = {
          type  = "secret_text",
          value = var.backend_url
        },
        "AWS_ACCESS_KEY_ID" = {
          type  = "secret_text",
          value = var.backend_access_key.id
        },
        "AWS_ACCESS_KEY_SECRET" = {
          type  = "secret_text",
          value = var.backend_access_key.secret
        }
      }
    }
  }
}

resource "cloudflare_zero_trust_access_identity_provider" "this" {
  config = {
    client_id     = var.google_client_id
    client_secret = var.google_client_secret
  }
  name       = "${var.name_prefix}-pages-google"
  type       = "google"
  account_id = var.account_id
}

resource "cloudflare_zero_trust_access_policy" "this" {
  account_id = var.account_id
  decision   = "allow"
  name       = "${var.name_prefix}-pages-policy"

  include = [{
    email = {
      email = "${var.email}"
    }
  }]
}

resource "cloudflare_zero_trust_access_application" "this" {
  account_id       = var.account_id
  name             = "${var.name_prefix}-pages-access"
  domain           = cloudflare_pages_project.this.subdomain
  session_duration = "24h"
  type             = "self_hosted"
  allowed_idps     = [cloudflare_zero_trust_access_identity_provider.this.id]
  policies = [
    {
      id         = cloudflare_zero_trust_access_policy.this.id
      precedence = 1
    }
  ]
}

# As described here: https://github.com/cloudflare/terraform-provider-cloudflare/issues/3099
# creating a pages project won't automatically deploy it, so we need to trigger the deployment manually
resource "terraform_data" "trigger_initial_deploy" {
  triggers_replace = [
    cloudflare_pages_project.this.id
  ]

  provisioner "local-exec" {
    command = <<EOT
      curl -X POST "https://api.cloudflare.com/client/v4/accounts/${var.account_id}/pages/projects/${cloudflare_pages_project.this.name}/deployments" \
           -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
           -H "Content-Type: application/json" \
           --data '{"branch":"${var.github_branch}"}'
    EOT
    environment = {
      CLOUDFLARE_API_TOKEN = var.api_token
    }
  }
}

