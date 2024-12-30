terraform {
  source = "${get_repo_root()}/terraform-modules/aws/vpc"
}

include "root" {
  path   = find_in_parent_folders()
  expose = true
}

###########################################################
# Input variables for this module
###########################################################
inputs = {
  name = "strimq"
  vpc_cidr = "10.1.0.0/21"
  secondary_cidr_blocks = ["100.64.0.0/16"]
  # NOTE: standard-private
  # enable_nat_gateway = true
  enable_nat_gateway = false
  enable_vpc_endpoints = false
}