output "name" {
  value = var.name != null ? "${var.project}-${var.region}-${var.environment}-${var.name}" : "${var.project}-${var.region}-${var.environment}"
}