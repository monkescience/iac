# Cert Manager IAM Role and Policy
data "aws_iam_policy_document" "cert_manager_assume_role_policy" {
  version = "2012-10-17"

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${module.account_check.account_id}:oidc-provider/${local.eks_cluster_oidc_issuer_uri}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.eks_cluster_oidc_issuer_uri}:sub"
      values   = ["system:serviceaccount:cert-manager:cert-manager"]
    }
  }
}

resource "aws_iam_role" "cert_manager_service_role" {
  name               = "${var.eks_cluster_name}-cert-manager"
  assume_role_policy = data.aws_iam_policy_document.cert_manager_assume_role_policy.json
}

resource "aws_iam_role_policy" "cert_manager_route53_policy" {
  name   = "CertManagerRoute53Policy"
  role   = aws_iam_role.cert_manager_service_role.id
  policy = data.aws_iam_policy_document.cert_manager_route53_permissions.json
}

data "aws_iam_policy_document" "cert_manager_route53_permissions" {
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

# Loki IAM Role and Policy
data "aws_iam_policy_document" "loki_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${module.account_check.account_id}:oidc-provider/${local.eks_cluster_oidc_issuer_uri}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.eks_cluster_oidc_issuer_uri}:sub"
      values   = ["system:serviceaccount:loki:loki"]
    }
  }
}

resource "aws_iam_role" "loki_service_role" {
  name               = "${module.this.name}-loki"
  assume_role_policy = data.aws_iam_policy_document.loki_assume_role_policy.json
}

data "aws_iam_policy_document" "loki_s3_permissions" {
  version = "2012-10-17"

  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      aws_s3_bucket.loki_logs.arn,
      "${aws_s3_bucket.loki_logs.arn}/*"
    ]
  }
}

resource "aws_iam_role_policy" "loki_s3_access" {
  name   = "LokiS3AccessPolicy"
  role   = aws_iam_role.loki_service_role.id
  policy = data.aws_iam_policy_document.loki_s3_permissions.json
}
