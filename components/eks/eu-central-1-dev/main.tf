data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "${var.project}-${var.region}-${var.environment}-iac-tofu-state"
    key    = "vpc/terraform.tfstate"
    region = var.region
  }
}

module "base" {
  source = "../base"

  region      = var.region
  environment = var.environment
  project     = var.project

  eks_version    = "1.33"
  eks_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  eks_cluster_admin_principal_arns = [
    "arn:aws:iam::387105013966:role/aws-reserved/sso.amazonaws.com/eu-central-1/AWSReservedSSO_admin_dc1b034f828d678b",
  ]
}