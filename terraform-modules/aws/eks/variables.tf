variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "private_subnets_cidr_blocks" {
  description = "List of private subnet CIDR blocks"
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
