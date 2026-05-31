terraform {
  required_version = ">= 1.11.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.46.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.1.0"
    }
  }
}
