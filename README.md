This repo is a part of https://github.com/free-website-framework. Go to the link to read more about this project.


# Prerequisites
1. Prepare fontend and backend repositories and follow theirs prerequisites
2. Run "aws configure" to set access key id and secret access key
3. Run docker daemon
4. Create an Account API token with such permission: Account - Access: Identity Providers:Edit, Cloudflare Pages:Edit, Access: Apps and Policies:Edit. Remember to store your token before exiting as it won't be visible.
5. Integrate frontend github with cloudflare. Go to Cloudflare website -> Build -> Compute -> Workers & Pages -> Create application -> Connect GitHub -> after selecting repos click Install & Authorize and you can close the website. The rest will be done from terraform. https://developers.cloudflare.com/pages/get-started/git-integration/
6. Create a client id and a client secret for using Google as an identity provider. Follow this tutorial until step 9: https://developers.cloudflare.com/cloudflare-one/integrations/identity-providers/google/
7. Create a tfvars file with all the needed values


# Workflow
```
export VAR_FILE=/terraform-vars/infra.tfvars
terraform init
terraform apply -var-file=$VAR_FILE
```

You need to wait for a minute or two before a page will be running.
Then open the output url and test if you can login.

You can create a request to backend in Insomnia to $(terraform output url) with Auth AWS IAM set with
terraform console
```
> module.backend.url
> nonsensitive(module.backend.access_key.id)
> nonsensitive(module.backend.access_key.secret)
Region: eu-central-1
Service: lambda
```

```
terraform destroy -var-file=$VAR_FILE
```
