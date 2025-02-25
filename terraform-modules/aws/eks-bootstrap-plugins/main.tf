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

data "sops_file" "sealed_secrets_tls" {
  source_file = var.sealed_secrets_tls_sops_file
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
resource "kubernetes_secret" "sealed_secrets_tls" {
  metadata {
    name      = "sealed-secrets-key"
    namespace = "kube-system"
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = data.sops_file.sealed_secrets_tls.data["tls.crt"]
    "tls.key" = data.sops_file.sealed_secrets_tls.data["tls.key"]
  }
}

resource "helm_release" "sealed-secrets" {
  name      = "sealed-secrets"
  namespace = "kube-system"

  repository = "https://bitnami-labs.github.io/sealed-secrets"
  chart      = "sealed-secrets"
  version    = "2.17.0"

  timeout = 600

  values = [
    templatefile(var.sealed_secrets_values_file, {
      secretName = kubernetes_secret.sealed_secrets_tls.metadata[0].name
    })
  ]
}
