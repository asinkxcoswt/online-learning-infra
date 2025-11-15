resource "aws_cognito_user_pool" "auth" {
  name                    = "${var.name_prefix}-auth"
  username_attributes     = ["email"]          # login by email
  auto_verified_attributes = ["email"]         # verify email

  # Let users sign up themselves (not admin-only)
  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  password_policy {
    minimum_length    = 12
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  # (optional but useful) account recovery via email
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
}

resource "aws_cognito_user_pool_client" "app" {
  name         = "${var.name_prefix}-api"
  user_pool_id = aws_cognito_user_pool.auth.id

  # If this client is used by a public client (mobile, SPA), keep this false.
  # If ONLY your backend uses it (can keep a secret), you can set true.
  generate_secret = false

  # WE ARE NOT USING OAUTH / HOSTED UI → no allowed_oauth_* needed

  # Tell Cognito which auth flows this client is allowed to use
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",  # email + password via InitiateAuth
    "ALLOW_REFRESH_TOKEN_AUTH",  # use refresh_token to get new tokens
    "ALLOW_USER_SRP_AUTH"        # optional: SRP (safer for native/mobile)
  ]
}

resource "aws_ssm_parameter" "cognito_user_pool_id" {
  name  = "/${var.name_prefix}/cognito/user_pool_id"
  type  = "String"
  value = aws_cognito_user_pool.auth.id
}

resource "aws_ssm_parameter" "cognito_user_pool_client_id" {
  name  = "/${var.name_prefix}/cognito/user_pool_client_id"
  type  = "String"
  value = aws_cognito_user_pool_client.app.id
}
