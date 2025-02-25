terraform {
  source = "${get_repo_root()}/terraform-modules/aws/eks-bootstrap-plugins"
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "eks" {
  config_path = "${get_terragrunt_dir()}/../eks"
}

###########################################################
# Input variables for this module
###########################################################
inputs = {
  name                                   = "strimq"
  eks_cluster_name                       = dependency.eks.outputs.cluster_name
  eks_cluster_endpoint                   = dependency.eks.outputs.cluster_endpoint
  eks_cluster_certificate_authority_data = dependency.eks.outputs.cluster_certificate_authority_data
  sealed_secrets_values_file             = "${get_terragrunt_dir()}/../../charts/sealed-secrets/values.yaml"
  sealed_secrets_tls_sops_file           = "${get_terragrunt_dir()}/assets/sealed-secrets-key.secrets.enc.yaml"
}