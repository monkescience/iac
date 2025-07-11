output "loki_s3_bucket_arn" {
  description = "ARN of the S3 bucket for Loki logs"
  value       = aws_s3_bucket.loki_logs.arn
}

output "loki_iam_role_arn" {
  description = "ARN of the IAM role for Loki service account"
  value       = aws_iam_role.loki_service_role.arn
}
