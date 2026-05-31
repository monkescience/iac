output "cognito_user_pool_endpoint" {
  description = "The endpoint of the Cognito User Pool"
  value       = module.base.cognito_user_pool_endpoint
}

output "cognito_user_pool_id" {
  description = "The ID of the Cognito User Pool"
  value       = module.base.cognito_user_pool_id
}

output "cognito_user_pool_client_id" {
  description = "The ID of the Cognito User Pool Client"
  value       = module.base.cognito_user_pool_client_id
}
