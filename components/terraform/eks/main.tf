data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "${var.project}-${var.region}-${var.environment}-iac-tofu-state"
    key    = "vpc/terraform.tfstate"
    region = var.region
  }
}

module "base" {
  source = "./modules/eks"

  region      = var.region
  environment = var.environment
  project     = var.project

  eks_version                      = var.eks_version
  eks_subnet_ids                   = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  eks_cluster_admin_principal_arns = var.eks_cluster_admin_principal_arns
  eks_public_access_cidrs          = var.eks_public_access_cidrs
}
