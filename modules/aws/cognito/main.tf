# Cognito User Pool for OAuth
resource "aws_cognito_user_pool" "this" {
  name = module.this.name

  deletion_protection = "INACTIVE"
  mfa_configuration   = "ON"

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  auto_verified_attributes = [
    "email"
  ]

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  password_policy {
    minimum_length                   = 12
    require_uppercase                = true
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    temporary_password_validity_days = 7
  }

  software_token_mfa_configuration {
    enabled = true
  }
}

resource "aws_cognito_user_pool_domain" "this" {
  domain       = "${module.this.name}-user-pool-domain"
  user_pool_id = aws_cognito_user_pool.this.id
}

resource "aws_cognito_user_pool_client" "this" {
  name                                 = "${module.this.name}-user-pool-client"
  user_pool_id                         = aws_cognito_user_pool.this.id
  generate_secret                      = true
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["openid", "email", "profile"]
  callback_urls = [
    "https://argocd.dev.eu-central-1.monke.science/oauth2/idpresponse",
    "https://grafana.dev.eu-central-1.monke.science/oauth2/idpresponse",
  ]
  logout_urls = [
    "https://argocd.dev.eu-central-1.monke.science",
    "https://grafana.dev.eu-central-1.monke.science",
  ]
  supported_identity_providers = ["COGNITO"]
}
