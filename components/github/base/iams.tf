data "aws_iam_policy_document" "mirror_assume_role" {
  count = var.mirror_enabled ? 1 : 0

  version = "2012-10-17"

  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRoleWithWebIdentity",
      "sts:TagSession"
    ]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.github_domain}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "${var.github_domain}:sub"
      values = [
        "repo:${var.mirror_github_repository}:*",
      ]
    }
  }
}

resource "aws_iam_role" "mirror" {
  count = var.mirror_enabled ? 1 : 0

  name               = "${module.this.name}-mirror"
  assume_role_policy = data.aws_iam_policy_document.mirror_assume_role[0].json
}

data "aws_iam_policy_document" "mirror" {
  count = var.mirror_enabled ? 1 : 0

  version = "2012-10-17"

  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload"
    ]
    resources = [
      for repository in var.mirror_ecr_repository_arns : repository
    ]
  }

}

resource "aws_iam_role_policy" "mirror" {
  count = var.mirror_enabled ? 1 : 0

  name   = "AllowECRAccess"
  role   = aws_iam_role.mirror[0].id
  policy = data.aws_iam_policy_document.mirror[0].json
}
