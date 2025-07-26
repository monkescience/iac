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

data "aws_ecr_lifecycle_policy_document" "lifecycle_policy_document" {
  rule {
    priority    = 1
    description = "Remove untagged images after 7 days"

    selection {
      count_number = 7
      count_type   = "sinceImagePushed"
      count_unit   = "days"
      tag_status   = "untagged"
    }

    action {
      type = "expire"
    }
  }

  rule {
    priority    = 2
    description = "Keep only the 4 most recent images for this repository"

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

resource "aws_ecr_lifecycle_policy" "lifecycle_policy" {
  for_each = var.ecr_repositories

  repository = aws_ecr_repository.ecr_repository[each.key].id
  policy     = data.aws_ecr_lifecycle_policy_document.lifecycle_policy_document.json
}