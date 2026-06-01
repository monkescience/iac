variable "member_account_ids" {
  description = "Map of assignment key -> AWS account ID to grant the admin permission set. Keys become the account-assignment resource keys."
  type        = map(string)
}
