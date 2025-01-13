terraform {
  source = "${get_repo_root()}/terraform-modules/aws/eks"
}

include "root" {
  path   = find_in_parent_folders()
  expose = true
}

dependency "vpc" {
  config_path = "${get_terragrunt_dir()}/../vpc"
}

###########################################################
# Input variables for this module
###########################################################
inputs = {
  vpc_id = dependency.vpc.outputs.vpc_id
  # NOTE: standard-private
  # subnet_ids = compact([for subnet_id, cidr_block in zipmap(dependency.vpc.outputs.private_subnets, dependency.vpc.outputs.private_subnets_cidr_blocks) : substr(cidr_block, 0, 4) == "100." ? subnet_id : null])
  subnet_ids = compact([for subnet_id, cidr_block in zipmap(dependency.vpc.outputs.public_subnets, dependency.vpc.outputs.public_subnets_cidr_blocks) : substr(cidr_block, 0, 4) == "100." ? subnet_id : null])
  name = "strimq"
  eks_cluster_version = "1.31"
}