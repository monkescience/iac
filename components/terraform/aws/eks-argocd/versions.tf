terraform {
  required_version = ">= 1.11.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.68.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.4.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.3.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.19.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.6.3"
    }
  }
}
