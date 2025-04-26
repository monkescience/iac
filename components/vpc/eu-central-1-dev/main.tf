module "base" {
  source = "../base"

  region      = var.region
  environment = var.environment
  project     = var.project

  vpc_cidr_block = "10.69.0.0/16"
  public_subnets = [
    { availability_zone = "eu-central-1a", cidr_block = "10.69.0.0/22" },
    { availability_zone = "eu-central-1b", cidr_block = "10.69.4.0/22" },
    { availability_zone = "eu-central-1c", cidr_block = "10.69.8.0/22" }
  ]
  private_subnets = [
    { availability_zone = "eu-central-1a", cidr_block = "10.69.64.0/20" },
    { availability_zone = "eu-central-1b", cidr_block = "10.69.80.0/20" },
    { availability_zone = "eu-central-1c", cidr_block = "10.69.96.0/20" }
  ]
}