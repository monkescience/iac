# Output the EKS cluster information needed by the eks-setup module
output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster"
  value       = module.base.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "The certificate authority data for the EKS cluster"
  value       = module.base.cluster_certificate_authority_data
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.base.cluster_name
}

output "cluster_oidc_issuer_url" {
  description = "The OIDC issuer URL for the EKS cluster"
  value       = module.base.cluster_oidc_issuer_url
}