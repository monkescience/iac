module "account_check" {
  source = "../../../modules/account"

  region      = var.region
  environment = var.environment
}

module "eks_name" {
  source = "../../../modules/name"

  project     = var.project
  region      = var.region
  environment = var.environment
  name        = "main"
}