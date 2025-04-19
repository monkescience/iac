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