output "certificate_arn" {
  description = "ARN of the SSL certificate for the domain"
  value       = module.base.certificate_arn
}

output "route53_zone_id" {
  description = "ID of the Route 53 hosted zone"
  value       = module.base.route53_zone_id
}