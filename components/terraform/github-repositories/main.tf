module "base" {
  source = "./modules/repositories"

  repos_path = "${path.module}/definitions"
}
