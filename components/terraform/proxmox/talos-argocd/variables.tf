variable "cluster_name" {
  type = string
}

variable "talos_cluster_state_path" {
  type = string
}

variable "gitops_repository" {
  type = string
}

variable "gitops_target_revision" {
  type = string
}

variable "argocd_chart_version" {
  type = string
}

# tflint-ignore: terraform_unused_declarations
variable "component" {
  type = string
}

# tflint-ignore: terraform_unused_declarations
variable "namespace" {
  type    = string
  default = null
}

# tflint-ignore: terraform_unused_declarations
variable "tenant" {
  type    = string
  default = null
}

# tflint-ignore: terraform_unused_declarations
variable "environment" {
  type    = string
  default = null
}

# tflint-ignore: terraform_unused_declarations
variable "stage" {
  type    = string
  default = null
}

# tflint-ignore: terraform_unused_declarations
variable "project" {
  type    = string
  default = null
}
