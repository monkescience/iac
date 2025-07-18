terraform {
  backend "s3" {}
}

module "tags" {
  source = "../../../modules/tags"

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