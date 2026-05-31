resource "aws_secretsmanager_secret" "argocd_admin" {
  name                    = "${module.this.name}-argocd-admin"
  description             = "ArgoCD Admin Password"
  recovery_window_in_days = 7
}
