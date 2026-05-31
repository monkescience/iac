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

variable "eks_public_access_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks allowed to access the public EKS API endpoint"
  validation {
    condition     = alltrue([for c in var.eks_public_access_cidrs : can(cidrhost(c, 0))])
    error_message = "Each item in eks_public_access_cidrs must be a valid IPv4 CIDR (e.g. 1.2.3.4/32)."
  }
}
