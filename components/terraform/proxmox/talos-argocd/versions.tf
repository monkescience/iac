terraform {
  required_version = ">= 1.11.6"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "3.3.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.6.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.19.0"
    }
  }
}
