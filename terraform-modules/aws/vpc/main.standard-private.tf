# NOTE: standard-private
# data "aws_availability_zones" "available" {}

# locals {
#   name   = var.name

#   azs = slice(data.aws_availability_zones.available.names, 0, 2)

#   # Routable Private subnets only for Private NAT Gateway -> Transit Gateway -> Second VPC for overlapping CIDRs
#   # e.g., var.vpc_cidr = "10.1.0.0/21" => output: ["10.1.0.0/24", "10.1.1.0/24"] => 256-2 = 254 usable IPs per subnet/AZ
#   private_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 3, k)]
#   # Routable Public subnets with NAT Gateway and Internet Gateway
#   # e.g., var.vpc_cidr = "10.1.0.0/21" => output: ["10.1.2.0/26", "10.1.2.64/26"] => 64-2 = 62 usable IPs per subnet/AZ
#   public_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 5, k + 8)]
#   # RFC6598 range 100.64.0.0/16 for EKS Data Plane for two subnets(32768 IPs per Subnet) across two AZs for EKS Control Plane ENI + Nodes + Pods
#   # e.g., var.secondary_cidr_blocks = "100.64.0.0/16" => output: ["100.64.0.0/17", "100.64.128.0/17"] => 32768-2 = 32766 usable IPs per subnet/AZ
#   secondary_ip_range_private_subnets = [for k, v in local.azs : cidrsubnet(element(var.secondary_cidr_blocks, 0), 1, k)]

#   tags = merge(var.tags, {
#     GithubRepo = "github.com/StrimQ/iac"
#   })
# }

# #---------------------------------------------------------------
# # VPC
# #---------------------------------------------------------------
# # WARNING: This VPC module includes the creation of an Internet Gateway and NAT Gateway, which simplifies cluster deployment and testing, primarily intended for sandbox accounts.
# # IMPORTANT: For preprod and prod use cases, it is crucial to consult with your security team and AWS architects to design a private infrastructure solution that aligns with your security requirements

# module "vpc" {
#   source  = "terraform-aws-modules/vpc/aws"
#   version = "~> 5.17.0"

#   name = local.name
#   cidr = var.vpc_cidr
#   azs  = local.azs

#   # Secondary CIDR block attached to VPC for EKS Control Plane ENI + Nodes + Pods
#   secondary_cidr_blocks = var.secondary_cidr_blocks

#   # 1/ EKS Data Plane secondary CIDR blocks for two subnets across two AZs for EKS Control Plane ENI + Nodes + Pods
#   # 2/ Two private Subnets with RFC1918 private IPv4 address range for Private NAT + NLB + Airflow + EC2 Jumphost etc.
#   private_subnets = concat(local.private_subnets, local.secondary_ip_range_private_subnets)

#   # ------------------------------
#   # Optional Public Subnets for NAT and IGW for PoC/Dev/Test environments
#   # Public Subnets can be disabled while deploying to Production and use Private NAT + TGW
#   public_subnets     = local.public_subnets
#   enable_nat_gateway = var.enable_nat_gateway
#   single_nat_gateway = true
#   #-------------------------------

#   public_subnet_tags = {
#     "kubernetes.io/role/elb" = 1
#   }

#   private_subnet_tags = {
#     "kubernetes.io/role/internal-elb" = 1
#     # Tags subnets for Karpenter auto-discovery
#     "karpenter.sh/discovery" = local.name
#   }

#   tags = local.tags
# }

# module "vpc_endpoints_sg" {
#   source  = "terraform-aws-modules/security-group/aws"
#   version = "~> 5.2.0"

#   create = var.enable_vpc_endpoints

#   name        = "${local.name}-vpc-endpoints"
#   description = "Security group for VPC endpoint access"
#   vpc_id      = module.vpc.vpc_id

#   ingress_with_cidr_blocks = [
#     {
#       rule        = "https-443-tcp"
#       description = "VPC CIDR HTTPS"
#       cidr_blocks = join(",", module.vpc.private_subnets_cidr_blocks)
#     },
#   ]

#   egress_with_cidr_blocks = [
#     {
#       rule        = "https-443-tcp"
#       description = "All egress HTTPS"
#       cidr_blocks = "0.0.0.0/0"
#     },
#   ]

#   tags = local.tags
# }

# module "vpc_endpoints" {
#   source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
#   version = "~> 5.17.0"

#   create = var.enable_vpc_endpoints

#   vpc_id             = module.vpc.vpc_id
#   security_group_ids = [module.vpc_endpoints_sg.security_group_id]

#   endpoints = merge({
#     s3 = {
#       service         = "s3"
#       service_type    = "Gateway"
#       route_table_ids = module.vpc.private_route_table_ids
#       tags = {
#         Name = "${local.name}-s3"
#       }
#     }
#     },
#     { for service in toset(["autoscaling", "ecr.api", "ecr.dkr", "ec2", "ec2messages", "elasticloadbalancing", "sts", "kms", "logs", "ssm", "ssmmessages"]) :
#       replace(service, ".", "_") =>
#       {
#         service             = service
#         subnet_ids          = module.vpc.private_subnets
#         private_dns_enabled = true
#         tags                = { Name = "${local.name}-${service}" }
#       }
#   })

#   tags = local.tags
# }
