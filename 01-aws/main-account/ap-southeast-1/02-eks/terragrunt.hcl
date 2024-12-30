terraform {
  source = "${get_repo_root()}/terraform-modules/aws/eks"
}

include "root" {
  path   = find_in_parent_folders()
  expose = true
}

dependencies "vpc" {
  config_path = "${get_terragrunt_dir()}/../vpc"
}

###########################################################
# Input variables for this module
###########################################################
inputs = {
  vpc_id = dependencies.vpc.outputs.vpc_id
  # NOTE: standard-private
  # private_subnets = dependencies.vpc.outputs.private_subnets
  # private_subnets_cidr_blocks = dependencies.vpc.outputs.private_subnets_cidr_blocks
  private_subnets = dependencies.vpc.outputs.public_subnets
  private_subnets_cidr_blocks = dependencies.vpc.outputs.public_subnets_cidr_blocks
  name = "strimq"
  eks_cluster_version = "1.31"
}