variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "environment" {
  type = string
}

variable "eks_cluster_endpoint" {
  type        = string
  description = "The endpoint for the EKS cluster"
}

variable "eks_cluster_certificate_authority_data" {
  type        = string
  description = "The certificate authority data for the EKS cluster"
}

variable "eks_cluster_name" {
  type        = string
  description = "The name of the EKS cluster"
}

variable "eks_cluster_oidc_issuer_url" {
  type        = string
  description = "The OIDC issuer URL for the EKS cluster"
}

variable "eks_vpc_id" {
  description = "VPC ID where the EKS cluster is deployed"
  type        = string
}

variable "eks_public_subnets" {
  description = "List of public subnets of the EKS cluster"
  type        = list(string)
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate for the EKS load balancer"
  type        = string
}

variable "route53_zone_id" {
  type        = string
  description = "The ID of the Route 53 hosted zone where the EKS cluster will be registered"
}

