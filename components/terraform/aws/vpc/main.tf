module "vpc" {
  source = "../../../../modules/aws/vpc"

  region      = var.region
  environment = var.environment
  project     = var.project

  vpc_cidr_block           = var.vpc_cidr_block
  public_subnets           = var.public_subnets
  private_subnets          = var.private_subnets
  enable_fck_nat           = var.enable_fck_nat
  enable_nat_gateways      = var.enable_nat_gateways
  enable_ecr_vpc_endpoints = var.enable_ecr_vpc_endpoints
}
