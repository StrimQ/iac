# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform/OpenTofu that provides extra tools for working with multiple modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # Automatically load folder-level name
  service_name = basename(get_terragrunt_dir())

  # Automatically load account-level variables
  account_vars = try(
    read_terragrunt_config(find_in_parent_folders("account.hcl")),
    {
      locals = {
        account_name   = "main-account"
        aws_account_id = "429702212725"
        env            = "prod"
      }
    }
  )

  # Automatically load region-level variables
  region_vars = try(
    read_terragrunt_config(find_in_parent_folders("region.hcl")),
    {
      locals = {
        aws_region = "ap-southeast-1"
      }
    }
  )

  # Extract the variables we need for easy access
  env          = local.account_vars.locals.env
  account_name = local.account_vars.locals.account_name
  account_id   = local.account_vars.locals.aws_account_id
  aws_region   = local.region_vars.locals.aws_region
}

# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"
  default_tags {
    tags = {
      ManagedBy = "Terragrunt"
    }
  }
}
EOF
}

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "s3"

  config = {
    encrypt        = true
    bucket         = "strimq-tfstate-bucket"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    dynamodb_table = "terraform-locks"
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
inputs = merge(
  local.account_vars.locals,
  local.region_vars.locals,
)
