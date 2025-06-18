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

