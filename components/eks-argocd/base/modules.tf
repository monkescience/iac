module "account_check" {
  source = "../../../modules/account"

  region      = var.region
  environment = var.environment
}
