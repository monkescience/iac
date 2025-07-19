module "account_check" {
  source = "../../../modules/account"

  region      = var.region
  environment = var.environment
}

module "this" {
  source = "../../../modules/name"

  project     = var.project
  region      = var.region
  environment = var.environment
  name        = "github"
}