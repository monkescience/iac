output "account_id" {
  value = local.accounts["${var.region}-${var.environment}"]
}

output "account_ids" {
  description = "All known account IDs, keyed by <region>-<environment>. Single source of truth for callers that need more than their own account (e.g. sso assignments)."
  value       = local.accounts
}