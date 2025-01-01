variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

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

variable "eks_cluster_version" {
  description = "EKS Cluster version"
  type        = string
  default     = "1.31"
}
