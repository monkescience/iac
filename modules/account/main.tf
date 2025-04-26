locals {
  accounts = {
    "eu-central-1-root" = "489721517942",
    "eu-central-1-dev"  = "387105013966",
    "eu-central-1-prod" = "978150176582"
  }
}

data "aws_caller_identity" "current" {
  lifecycle {
    postcondition {
      condition     = local.accounts["${var.region}-${var.environment}"] == self.account_id
      error_message = "The account ID ${self.account_id} does not match the expected account ID ${local.accounts["${var.region}-${var.environment}"]} for the region ${var.region} and environment ${var.environment}."
    }
  }
}