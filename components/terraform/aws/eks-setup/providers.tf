module "tags" {
  source = "../../../../modules/aws/tags"

  project     = var.project
  region      = var.region
  environment = var.environment
  component   = var.component
}

provider "aws" {
  region = var.region

  default_tags {
    tags = module.tags.default_tags
  }
}

provider "kubectl" {
  host                   = data.terraform_remote_state.eks.outputs.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.eks_cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.eks.outputs.eks_cluster_name]
  }
}
