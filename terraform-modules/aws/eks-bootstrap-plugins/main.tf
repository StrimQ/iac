provider "kubernetes" {
  host                   = var.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(var.eks_cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = var.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(var.eks_cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

data "aws_region" "current" {}
data "aws_eks_cluster_auth" "this" {
  name = var.eks_cluster_name
}

locals {
  name = var.name

  tags = merge(var.tags, {
    GithubRepo = "github.com/StrimQ/iac"
  })
}

#---------------------------------------------------------------
# Helm Releases
#---------------------------------------------------------------
resource "helm_release" "sealed-secrets" {
  name      = "sealed-secrets"
  namespace = "kube-system"

  repository = "https://bitnami-labs.github.io/sealed-secrets"
  chart      = "sealed-secrets"
  version    = "2.17.0"

  timeout = 600

  values = [
    templatefile(var.sealed_secrets_values_file, {})
  ]
}


resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  create_namespace = true

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "7.7.11"

  timeout = 600

  values = [
    templatefile(var.argocd_values_file, {})
  ]
}
