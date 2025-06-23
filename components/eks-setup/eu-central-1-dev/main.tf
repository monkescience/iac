data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "${var.project}-${var.region}-${var.environment}-iac-tofu-state"
    key    = "eks/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "ssl_dns" {
  backend = "s3"
  config = {
    bucket = "${var.project}-${var.region}-${var.environment}-iac-tofu-state"
    key    = "ssl-dns/terraform.tfstate"
    region = var.region
  }
}

module "base" {
  source = "../base"

  region      = var.region
  environment = var.environment
  project     = var.project

  eks_cluster_endpoint                   = data.terraform_remote_state.eks.outputs.eks_cluster_endpoint
  eks_cluster_certificate_authority_data = data.terraform_remote_state.eks.outputs.eks_cluster_certificate_authority_data
  eks_cluster_name                       = data.terraform_remote_state.eks.outputs.eks_cluster_name
  eks_cluster_oidc_issuer_url            = data.terraform_remote_state.eks.outputs.eks_cluster_oidc_issuer_url

  route53_zone_id = data.terraform_remote_state.ssl_dns.outputs.route53_zone_id
}
