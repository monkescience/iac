output "account_id" {
  value = local.accounts["${var.region}-${var.environment}"]
}