terraform {
  required_version = ">= 1.11.6"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "3.2.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.5.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.19.0"
    }
  }
}
