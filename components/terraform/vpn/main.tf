data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "${var.project}-${var.region}-${var.environment}-iac-tofu-state"
    key    = "vpc/terraform.tfstate"
    region = var.region
  }
}

module "base" {
  source = "./modules/vpn"

  project     = var.project
  region      = var.region
  environment = var.environment

  vpc_id            = data.terraform_remote_state.vpc.outputs.vpc_id
  vpc_public_subnet = data.terraform_remote_state.vpc.outputs.public_subnet_ids[0]
}
