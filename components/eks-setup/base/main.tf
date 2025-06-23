# Application Load Balancer Resources
resource "aws_lb" "eks_lb" {
  name               = "${module.this.name}-eks-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.eks_lb.id]
  subnets            = var.eks_public_subnets
}

resource "aws_security_group" "eks_lb" {
  name        = "${module.this.name}-eks-lb-sg"
  description = "Allow inbound HTTPS"
  vpc_id      = var.eks_vpc_id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "eks_lb" {
  name        = "${module.this.name}-eks-lb-tg"
  port        = 443
  protocol    = "TCP"
  vpc_id      = var.eks_vpc_id
  target_type = "ip"

  health_check {
    protocol = "TCP"
    port     = "443"
  }
}

resource "aws_lb_listener" "eks_lb" {
  load_balancer_arn = aws_lb.eks_lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-3-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.eks_lb.arn
  }
}

# ArgoCD Resources
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "8.1.1"
  wait             = true
  timeout          = 600


  values = [file("${path.module}/argocd-config.yaml")]

  lifecycle {
    ignore_changes = all
  }
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
  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "${var.region}-${var.environment}"
      namespace = "argocd"
      finalizers = [
        "resources-finalizer.argocd.argoproj.io"
      ]
    }
    spec = {
      project = "default"
      source = {
        repoURL        = "https://github.com/monkescience/gitops"
        targetRevision = "HEAD"
        path           = "apps/${var.region}-${var.environment}"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "argocd"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
      }
    }
  })

  depends_on = [
    helm_release.argocd,
    kubernetes_secret.argocd_git
  ]
}
