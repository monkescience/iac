output "route53_zone_id" {
  description = "ID of the Route 53 hosted zone"
  value       = module.base.route53_zone_id
}