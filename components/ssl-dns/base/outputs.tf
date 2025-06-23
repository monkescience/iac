output "certificate_arn" {
  description = "ARN of the SSL certificate for the domain"
  value       = aws_acm_certificate.monke_science.arn
}

output "route53_zone_id" {
  description = "ID of the Route 53 hosted zone"
  value       = aws_route53_zone.monke_science.zone_id
}