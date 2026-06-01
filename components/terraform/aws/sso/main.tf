module "sso" {
  source = "../../../../modules/aws/sso"

  # Source account IDs from the account module (single source of truth), re-keyed to
  # "<namespace>-<environment>" to match the existing assignment resource keys.
  member_account_ids = {
    for region_env, id in module.account_check.account_ids :
    "${var.namespace}-${trimprefix(region_env, "${var.region}-")}" => id
  }
}
