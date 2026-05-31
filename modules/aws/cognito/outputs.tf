output "cognito_user_pool_endpoint" {
  description = "The endpoint of the Cognito User Pool"
  value       = aws_cognito_user_pool.this.endpoint
}

output "cognito_user_pool_id" {
  description = "The ID of the Cognito User Pool"
  value       = aws_cognito_user_pool.this.id
}

output "cognito_user_pool_client_id" {
  description = "The ID of the Cognito User Pool Client"
  value       = aws_cognito_user_pool_client.this.id
}
