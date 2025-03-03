data "aws_region" "current" {}

locals {
  name = var.name

  tags = merge(var.tags, {
    GithubRepo = "github.com/StrimQ/iac"
  })
}

#---------------------------------------------------------------
# EKS Cluster
#---------------------------------------------------------------
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.31.6"

  cluster_name    = local.name
  cluster_version = var.eks_cluster_version

  # Gives Terraform identity admin access to cluster which will
  # allow deploying resources (Karpenter) into the cluster
  enable_cluster_creator_admin_permissions = true
  cluster_endpoint_public_access           = true

  cluster_addons = {
    aws-ebs-csi-driver     = { most_recent = true }
    coredns                = { most_recent = true }
    eks-pod-identity-agent = { most_recent = true }
    kube-proxy             = { most_recent = true }
    vpc-cni                = { most_recent = true }
  }

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  eks_managed_node_groups = {
    karpenter = {
      ami_type       = "BOTTLEROCKET_x86_64"
      instance_types = ["m5.large"]

      min_size     = 0
      max_size     = 3
      desired_size = 2

      labels = {
        # Used to ensure Karpenter runs on nodes that it does not manage
        "karpenter.sh/controller" = "true"
      }
    }
  }

  node_security_group_additional_rules = {
    sealed_secrets_ingress_from_control_plane = {
      type                          = "ingress"
      from_port                     = 8080
      to_port                       = 8080
      protocol                      = "tcp"
      source_cluster_security_group = true
      description                   = "Allow Sealed Secrets to receive traffic from the control plane"
    }
  }
  node_security_group_tags = merge(local.tags, {
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    # (i.e. - at most, only one security group should have this tag in your account)
    "karpenter.sh/discovery" = local.name
  })

  tags = local.tags
}

#---------------------------------------------------------------
# Karpenter
#---------------------------------------------------------------
module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "20.31.6"

  cluster_name          = module.eks.cluster_name
  enable_v1_permissions = true

  # Name needs to match role name passed to the EC2NodeClass
  node_iam_role_use_name_prefix   = false
  node_iam_role_name              = local.name
  create_pod_identity_association = true

  # Used to attach additional IAM policies to the Karpenter node IAM role
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = local.tags
}
