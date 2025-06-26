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

  project     = var.project
  region      = var.region
  environment = var.environment

  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
}