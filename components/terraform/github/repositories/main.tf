module "repositories" {
  source = "../../../../modules/github/repositories"

  repos_path = "${path.module}/definitions"
}
