module "account_check" {
  source = "../../../../modules/aws/account"

  region      = var.region
  environment = var.environment
}
