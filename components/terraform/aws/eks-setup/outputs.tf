output "loki_s3_bucket_arn" {
  description = "ARN of the S3 bucket for Loki logs"
  value       = module.eks-setup.loki_s3_bucket_arn
}

output "loki_iam_role_arn" {
  description = "ARN of the IAM role for Loki service account"
  value       = module.eks-setup.loki_iam_role_arn
}
