module "ecr" {
  source = "../../../../modules/aws/ecr"

  ecr_repositories = var.ecr_repositories
}
