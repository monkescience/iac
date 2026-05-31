variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "environment" {
  type = string
}

variable "account_id" {
  type        = string
  description = "The AWS account ID where the EKS cluster resources are created"
}

variable "eks_cluster_name" {
  type        = string
  description = "The name of the EKS cluster"
}

variable "eks_cluster_oidc_issuer_url" {
  type        = string
  description = "The OIDC issuer URL for the EKS cluster"
}

variable "route53_zone_id" {
  type        = string
  description = "The ID of the Route 53 hosted zone where the EKS cluster will be registered"
}

variable "eks_node_role_name" {
  type        = string
  description = "The name of the IAM role for the EKS nodes"
}

variable "eks_security_group" {
  type        = string
  description = "The security group for the EKS cluster"
}

variable "eks_subnet_ids" {
  type        = list(string)
  description = "The list of subnet IDs where the EKS cluster nodes will be deployed"
}
