output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${data.aws_region.current.name} update-kubeconfig --name ${module.eks.cluster_name}"
}

output "cluster_name" {
  description = "Cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Cluster certificate authority data"
  value       = module.eks.cluster_certificate_authority_data
}
