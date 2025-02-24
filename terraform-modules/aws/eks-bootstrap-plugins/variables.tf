variable "name" {
  description = "Name of the VPC and EKS Cluster"
  type        = string
  default     = "strimq"
}

variable "tags" {
  description = "Default tags"
  type        = map(string)
  default     = {}
}

variable "eks_cluster_name" {
  description = "EKS Cluster name"
  type        = string
}

variable "eks_cluster_endpoint" {
  description = "EKS Cluster endpoint"
  type        = string
}

variable "eks_cluster_certificate_authority_data" {
  description = "EKS Cluster certificate authority data"
  type        = string
}
