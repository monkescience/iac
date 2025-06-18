data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "${var.project}-${var.region}-${var.environment}-iac-tofu-state"
    key    = "eks/terraform.tfstate"
    region = var.region
  }
}

module "base" {
  source = "../base"

  region      = var.region
  environment = var.environment
  project     = var.project

  eks_cluster_endpoint                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
  eks_cluster_certificate_authority_data = data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data
  eks_cluster_name                       = data.terraform_remote_state.eks.outputs.cluster_name
  eks_cluster_oidc_issuer_url            = data.terraform_remote_state.eks.outputs.cluster_oidc_issuer_url

  route53_hosted_zone_id = "Z01546261NTTOBINL68WG"
}
