data "aws_caller_identity" "current" {}

#---------------------------------------------------------------
# KMS for sops resources
#---------------------------------------------------------------
module "sops-kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "3.1.1"

  description             = "KMS key for sops resources"
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 7

  # Policy
  key_administrators = [data.aws_caller_identity.current.arn]
  key_users          = [data.aws_caller_identity.current.arn]

  # Aliases
  aliases = ["${local.name}/sops"]

  tags = local.tags
}
