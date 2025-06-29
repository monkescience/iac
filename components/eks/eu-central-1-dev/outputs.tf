output "eks_cluster_endpoint" {
  description = "The endpoint for the EKS cluster"
  value       = module.base.eks_cluster_endpoint
}

output "eks_cluster_certificate_authority_data" {
  description = "The certificate authority data for the EKS cluster"
  value       = module.base.eks_cluster_certificate_authority_data
}

output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.base.eks_cluster_name
}

output "eks_cluster_oidc_issuer_url" {
  description = "The OIDC issuer URL for the EKS cluster"
  value       = module.base.eks_cluster_oidc_issuer_url
}

output "eks_node_role_name" {
  description = "The name of the IAM role for the EKS nodes"
  value       = module.base.eks_node_role_name
}

output "eks_security_group" {
  description = "The security group for the EKS cluster"
  value       = module.base.eks_security_group
}

output "eks_subnet_ids" {
  description = "The list of subnet IDs where the EKS cluster nodes will be deployed"
  value       = module.base.eks_subnet_ids
}