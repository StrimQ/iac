# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  account_name   = "main-account"
  aws_account_id = "429702212725"
  env            = "prod"
}