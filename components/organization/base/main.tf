resource "aws_organizations_organization" "org" {
  aws_service_access_principals = [
    "sso.amazonaws.com",
  ]
  feature_set = "ALL"
}

resource "aws_organizations_account" "dev" {
  name  = "monke-dev"
  email = "allround.email+monke-dev@gmail.com"
}

resource "aws_organizations_account" "prod" {
  name  = "monke-prod"
  email = "allround.email+monke-prod@gmail.com"
}

resource "aws_budgets_budget" "org" {
  name         = "${module.this.name}-budget"
  budget_type  = "COST"
  limit_amount = "50"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = ["allround.email+monke-budget@gmail.com"]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = ["allround.email+monke-budget@gmail.com"]
  }
}