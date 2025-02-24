variable "name" {
  description = "Name of the VPC"
  type        = string
  default     = "strimq"
}

variable "tags" {
  description = "Default tags"
  type        = map(string)
  default     = {}
}

# VPC with 2046 IPs (10.1.0.0/21) and 2 AZs
variable "vpc_cidr" {
  description = "VPC CIDR. This should be a valid private (RFC 1918) CIDR range"
  type        = string
  default     = "10.1.0.0/21"
}

# RFC6598 range 100.64.0.0/10
# Note you can only /16 range to VPC. You can add multiples of /16 if required
variable "secondary_cidr_blocks" {
  description = "Secondary CIDR blocks to be attached to VPC"
  type        = list(string)
  default     = ["100.64.0.0/16"]
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway"
  type        = bool
  default     = true
}

variable "enable_vpc_endpoints" {
  description = "Enable VPC Endpoints"
  type        = bool
  default     = false
}
