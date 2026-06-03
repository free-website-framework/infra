ACCOUNT_ID=123456789
REGION=eu-central-1
ROLE=fwf-github-actions
POLICY=fwf-github-actions-policy
BUCKET=fwf-terraform-state
GITHUB_OWNER=free-website-framework
GITHUB_REPO=infra


ASSUME_POLICY=$(
  sed \
    -e "s/\${ACCOUNT_ID}/$ACCOUNT_ID/g" \
    -e "s/\${GITHUB_OWNER}/$GITHUB_OWNER/g" \
    -e "s/\${GITHUB_REPO}/$GITHUB_REPO/g" \
    assume-policy.json.template
)

aws iam create-role \
  --role-name "$ROLE" \
  --assume-role-policy-document "$ASSUME_POLICY"


aws iam put-role-policy \
  --role-name "$ROLE" \
  --policy-name "$POLICY" \
  --policy-document file://policy.json

aws iam attach-role-policy \
  --role-name $ROLE \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

# aws s3api create-bucket --bucket $BUCKET --region $REGION --create-bucket-configuration LocationConstraint=$REGION
