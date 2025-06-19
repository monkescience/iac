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

