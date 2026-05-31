output "default_tags" {
  value = {
    "custom:project"     = var.project
    "custom:region"      = var.region
    "custom:environment" = var.environment
    "custom:iac"         = var.iac
    "custom:component"   = var.component
  }
}