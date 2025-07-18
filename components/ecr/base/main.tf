resource "aws_ecr_repository" "ecr_repository" {
  for_each = var.ecr_repositories

  name                 = each.key
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}

# Lifecycle policy for private repositories
data "aws_ecr_lifecycle_policy_document" "private_lifecycle_policy_document" {
  rule {
    priority    = 1
    description = "Keep only the 6 most recent images for private repositories"

    selection {
      count_number = 6
      count_type   = "imageCountMoreThan"
      tag_status   = "any"
    }

    action {
      type = "expire"
    }
  }
}

resource "aws_ecr_lifecycle_policy" "private_lifecycle_policy" {
  for_each = {
    for key, value in var.ecr_repositories : key => value
    if value.repository_type == "private"
  }

  repository = aws_ecr_repository.ecr_repository[each.key].id
  policy     = data.aws_ecr_lifecycle_policy_document.private_lifecycle_policy_document.json
}

# Lifecycle policy for mirror repositories
data "aws_ecr_lifecycle_policy_document" "mirror_lifecycle_policy_document" {
  rule {
    priority    = 1
    description = "Keep only the 4 most recent images for mirror repositories"

    selection {
      count_number = 4
      count_type   = "imageCountMoreThan"
      tag_status   = "any"
    }

    action {
      type = "expire"
    }
  }
}

resource "aws_ecr_lifecycle_policy" "mirror_lifecycle_policy" {
  for_each = {
    for key, value in var.ecr_repositories : key => value
    if value.repository_type == "mirror"
  }

  repository = aws_ecr_repository.ecr_repository[each.key].id
  policy     = data.aws_ecr_lifecycle_policy_document.mirror_lifecycle_policy_document.json
}