This repo is a part of https://github.com/free-website-framework. Go to the link to read more about this project.


# Prerequisites

1. Prepare fontend and backend repositories and follow theirs prerequisites
2. Run `aws configure` to set access key id and secret access key
3. Run docker daemon
4. Create a Cloudflare Account API token with 3 permissions: `Access: Identity Providers`, `Cloudflare Pages`, `Access: Apps and Policies`. For each select Account in the first column and Edit in the third column. Remember to store your token before exiting as it won't be visible afterwards.
5. Integrate frontend github with Cloudflare. Go to a Cloudflare website -> Build -> Compute -> Workers & Pages -> Create application -> wait for few seconds and click Connect GitHub -> after selecting repos click Install & Authorize and you can close the website. The rest will be done from terraform. https://developers.cloudflare.com/pages/get-started/git-integration/
6. Enable zero trust on Cloudflare. Go to a Cloudflare website -> Protect & Connect -> Zero Trust -> Get started -> pick a name -> Zero Trust Free Select plan -> fillin a card details
7. Create a client id and a client secret for using Google as an identity provider. Follow this tutorial until step 9: https://developers.cloudflare.com/cloudflare-one/integrations/identity-providers/google/
8. Create a tfvars file with all the needed values:
```
domain_prefix = "my-very-own-website-unique" # The final website will be hosted at https://<domain_prefix>.pages.dev/ if domain_prefix is world wide unique.
project = "my-website"                       # Prefix to all names and label
env = "dev"

backend_github = {
  owner               = "<put your owner here>"
  repo                = "<project>-backend"
  branch              = "main"
  python_version      = "3.14"
  mangun_handler_path = "app.main.handler"
}

frontend_github = {
  owner  = "<put your owner here>"
  repo   = "<project>-frontend"
  branch = "main"
}

cloudflare = {
  account_id = "xxx"
  api_token  = "xxx"
}
google_identity_provider = {
  client_id     = "xxx.apps.googleusercontent.com"
  client_secret = "xxx"
}
email = "xxx@gmail.com"
```


# How to deploy a website

```
export VAR_FILE=/terraform-vars/infra.tfvars
terraform init
terraform apply -var-file=$VAR_FILE
```

You need to wait for a minute or two before a page will be running.
Then open the output url and test if you can login.

You can create a request to backend in Insomnia with Auth AWS IAM set with values from terraform console
```
> nonsensitive(module.backend.url)
> nonsensitive(module.backend.access_key.id)
> nonsensitive(module.backend.access_key.secret)
```
Region: eu-central-1
Service: lambda


```
terraform destroy -var-file=$VAR_FILE
```


# How to apply changes

When you do any changes to either frontend or backend you must push them to github.
Then if you only changed frontend, cloudflare will automatically see the changes and they will be applied.
However if you want to apply changes to AWS lambda backend you have to run `terraform apply`.
You don't have to change any tfvars as github change will be visible in terraform and the code will be updated. 


# Common errors

```
╷
│ Error: local-exec provisioner error
│ 
│   with module.backend.null_resource.package,
│   on modules/backend/build.tf line 15, in resource "null_resource" "package":
│   15:   provisioner "local-exec" {
│ 
│ Error running command 'rm -rf modules/backend/build/repo modules/backend/build/package
│ git clone git@github.com:<owner>/<project>-backend.git -b <branch> --depth 1 modules/backend/build/repo
│ docker build \
│   -f ./modules/backend/build/Dockerfile \
│   --target artifact \
│   --platform linux/arm64 \
│   --output type=local,dest=modules/backend/build/package \
│   --build-arg python_version=3.14 \
│   modules/backend/build
│ ': exit status 1. Output: Cloning into 'modules/backend/build/repo'...
│ ERROR: Cannot connect to the Docker daemon at unix:///xxx/.docker/run/docker.sock. Is the docker daemon running?
│ 
╵
```

Fix: This probably means point 3 from prerequisites is not fulfilled. To be able to create a zip package for AWS lambda I used docker. You need to install `Docker Desktop` https://www.docker.com/products/docker-desktop/ or check `podman` and run it before `terraform apply`.


```
╷
│ Error: failed to make http request
│ 
│   with module.frontend.cloudflare_pages_project.this,
│   on modules/frontend/main.tf line 1, in resource "cloudflare_pages_project" "this":
│    1: resource "cloudflare_pages_project" "this" {
│ 
│ POST "https://api.cloudflare.com/client/v4/accounts/xxx/pages/projects": 401 Unauthorized {
│   "result": null,
│   "success": false,
│   "errors": [
│     {
│       "code": 8000011,
│       "message": "There is an internal issue with your Cloudflare Pages Git installation. If this issue persists after reinstalling your installation, contact support: https://xxx."
│     }
│   ],
│   "messages": []
│ }
│ 
╵
```

Fix: This probably means point 5 from prerequisites is not fulfilled. If you have installed cloudflare app on github you can try to remove it and add it again.


```
╷
│ Error: failed to make http request
│ 
│   with module.frontend.cloudflare_pages_project.this,
│   on modules/frontend/main.tf line 1, in resource "cloudflare_pages_project" "this":
│    1: resource "cloudflare_pages_project" "this" {
│ 
│ POST "https://api.cloudflare.com/client/v4/accounts/xxx/pages/projects": 403 Forbidden
│ {"success":false,"errors":[{"code":10000,"message":"Authentication error"}],"messages":[],"result":null}
│ 
╵
╷
│ Error: failed to make http request
│ 
│   with module.frontend.cloudflare_zero_trust_access_identity_provider.this,
│   on modules/frontend/main.tf line 52, in resource "cloudflare_zero_trust_access_identity_provider" "this":
│   52: resource "cloudflare_zero_trust_access_identity_provider" "this" {
│ 
│ POST "https://api.cloudflare.com/client/v4/accounts/xxx/access/identity_providers": 403 Forbidden
│ {"success":false,"errors":[{"code":10000,"message":"Authentication error"}],"messages":[],"result":null}
│ 
╵
╷
│ Error: failed to make http request
│ 
│   with module.frontend.cloudflare_zero_trust_access_policy.this,
│   on modules/frontend/main.tf line 62, in resource "cloudflare_zero_trust_access_policy" "this":
│   62: resource "cloudflare_zero_trust_access_policy" "this" {
│ 
│ POST "https://api.cloudflare.com/client/v4/accounts/xxx/access/policies": 403 Forbidden
│ {"success":false,"errors":[{"code":10000,"message":"Authentication error"}],"messages":[],"result":null}
│ 
╵
```

Fix: This probably means point 6 from prerequisites is not fulfilled. You should run bolow commands also if you got errors for GET with 401 Unauthorized.


```
export CLOUDFLARE_API_TOKEN=<generated_from_point_4>
export ACCOUNT_ID=<generated_from_point_4>

curl https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/tokens/verify -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" | jq '.messages[0].message'

[ "$(curl -s https://api.cloudflare.com/client/v4/accounts -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" | jq -r '.result[0].id')" = "$ACCOUNT_ID" ] && echo "Account ID is correct" || echo "Account ID missmatch"
```


# Debug deployment errors

Before you deploy your infrastructure you should have a working local changes. This minimise debuging effort on cloudflare and AWS which is much harder.

1. Check connection between frontend and backend:
    Go to Cloudflare -> Build -> Compute -> Workers & Pages -> select your page -> View details -> Functions -> Begin log stream -> trigger running some backend endpoints on frontend and wait for logs

2. If when you try to see a website and you choose a google to sign in with but you got an error `400: redirect_uri_mismatch` you should double check if cloudflare zero trust team name match what is in google identity provider. Check zero trust team name in cloudflare -> Protect & Connect -> Zero Trust -> Settings -> Team name. Then go to https://console.cloud.google.com/ and search for `Google Auth Platform`. Go to `Clients` select `cloudflare` and check if URIs match https://<zero-trust-team-name>.cloudflareaccess.com.

