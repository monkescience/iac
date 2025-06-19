variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "environment" {
  type = string
}

variable "eks_version" {
  type = string
}

variable "eks_subnet_ids" {
  type = list(string)
}

variable "eks_cluster_admin_principal_arns" {
  type        = set(string)
  description = "List of ARNs for IAM principals that will have admin access to the EKS cluster"
}