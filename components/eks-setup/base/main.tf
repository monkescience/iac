# Karpenter resources
resource "kubectl_manifest" "eks_node_class" {
  yaml_body = templatefile("${path.module}/eks-node-class.yaml", {
    region             = var.region
    environment        = var.environment
    eks_node_role_name = var.eks_node_role_name
    eks_security_group = var.eks_security_group
    eks_subnet_ids     = var.eks_subnet_ids
  })
}

resource "kubectl_manifest" "eks_node_pool" {
  yaml_body = file("${path.module}/eks-node-pool.yaml")
}

# ArgoCD Resources
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "8.1.3"
  wait             = true
  timeout          = 600


  values = [file("${path.module}/argocd-config.yaml")]

  lifecycle {
    ignore_changes = all
  }

  depends_on = [
    kubectl_manifest.eks_node_class,
    kubectl_manifest.eks_node_pool
  ]
}

resource "kubernetes_secret" "argocd_git" {
  metadata {
    name      = "gitops-repository"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type = "git"
    url  = "https://github.com/monkescience/gitops"
    name = "gitops"
    # For private repos:
    # username = var.github_username
    # password = var.github_token
  }

  depends_on = [helm_release.argocd]
}

resource "kubectl_manifest" "argocd_root_app" {
  yaml_body = templatefile("${path.module}/argocd-root-app.yaml", {
    region      = var.region
    environment = var.environment
  })

  depends_on = [
    helm_release.argocd,
    kubernetes_secret.argocd_git
  ]
}

# Loki Logs Resources
resource "aws_s3_bucket" "loki_logs" {
  bucket = "${module.this.name}-loki-logs"
}

resource "aws_s3_bucket_versioning" "loki_logs" {
  bucket = aws_s3_bucket.loki_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "loki_logs" {
  bucket = aws_s3_bucket.loki_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "loki_logs" {
  bucket = aws_s3_bucket.loki_logs.id

  rule {
    id     = "expiration"
    status = "Enabled"

    filter {
      prefix = ""
    }

    expiration {
      days = 30
    }
  }
}

resource "aws_s3_bucket_public_access_block" "loki_logs" {
  bucket = aws_s3_bucket.loki_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "loki_logs_deny_unencrypted_s3_access" {
  version = "2012-10-17"

  statement {
    effect = "Deny"
    sid    = "DenyUnencryptedS3Access"
    actions = [
      "s3:*"
    ]
    resources = [
      aws_s3_bucket.loki_logs.arn,
      "${aws_s3_bucket.loki_logs.arn}/*"
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test = "Bool"
      values = [
        "false"
      ]
      variable = "aws:SecureTransport"
    }
  }
}

resource "aws_s3_bucket_policy" "loki_logs" {
  bucket = aws_s3_bucket.loki_logs.id
  policy = data.aws_iam_policy_document.loki_logs_deny_unencrypted_s3_access.json
}
