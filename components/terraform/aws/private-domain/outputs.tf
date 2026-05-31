output "route53_zone_id" {
  description = "ID of the Route 53 hosted zone"
  value       = module.private-domain.route53_zone_id
}
