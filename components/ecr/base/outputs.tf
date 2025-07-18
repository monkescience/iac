output "ecr_repository_urls" {
  description = "List of created ECR repository URLs"
  value = [
    for repo_name, repo in var.ecr_repositories : aws_ecr_repository.ecr_repository[repo_name].repository_url
  ]
}