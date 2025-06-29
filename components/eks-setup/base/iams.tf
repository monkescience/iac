# Cert Manager IAM Role and Policy
data "aws_iam_policy_document" "cert_manager_assume_role" {
  version = "2012-10-17"

  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${module.account_check.account_id}:oidc-provider/${local.eks_cluster_oidc_issuer_uri}"]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${local.eks_cluster_oidc_issuer_uri}:sub"
      values   = ["system:serviceaccount:cert-manager:cert-manager"]
    }
  }
}

resource "aws_iam_role" "cert_manager" {
  name               = "${var.eks_cluster_name}-cert-manager"
  assume_role_policy = data.aws_iam_policy_document.cert_manager_assume_role.json
}

resource "aws_iam_role_policy" "cert_manager" {
  name   = "CertManagerPolicy"
  role   = aws_iam_role.cert_manager.id
  policy = data.aws_iam_policy_document.cert_manager.json
}

data "aws_iam_policy_document" "cert_manager" {
  version = "2012-10-17"

  statement {
    effect = "Allow"

    actions = [
      "route53:GetChange",
    ]

    resources = [
      "arn:aws:route53:::change/*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets"
    ]

    resources = [
      "arn:aws:route53:::hostedzone/${var.route53_zone_id}",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "route53:ListHostedZonesByName"
    ]

    resources = [
      "*"
    ]
  }
}