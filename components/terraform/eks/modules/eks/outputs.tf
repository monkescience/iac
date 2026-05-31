output "eks_cluster_endpoint" {
  description = "The endpoint for the EKS cluster"
  value       = aws_eks_cluster.eks.endpoint
}

output "eks_cluster_certificate_authority_data" {
  description = "The certificate authority data for the EKS cluster"
  value       = aws_eks_cluster.eks.certificate_authority[0].data
}

output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.eks.name
}

output "eks_cluster_oidc_issuer_url" {
  description = "The OIDC issuer URL for the EKS cluster"
  value       = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

output "eks_node_role_name" {
  description = "The name of the IAM role for the EKS nodes"
  value       = aws_iam_role.eks_node.name
}

output "eks_security_group" {
  description = "The security group for the EKS cluster"
  value       = aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id
}

output "eks_subnet_ids" {
  description = "The list of subnet IDs where the EKS cluster nodes will be deployed"
  value       = aws_eks_cluster.eks.vpc_config[0].subnet_ids
}
