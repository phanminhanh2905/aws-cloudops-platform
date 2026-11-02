
resource "aws_acm_certificate" "techworld" {
  domain_name       = "techworld.pma-server.site"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "techworld-pma-server-site"
    Environment = "dev"
    Project     = "cloudops-platform"
  }
}

resource "aws_acm_certificate_validation" "techworld" {
  certificate_arn = aws_acm_certificate.techworld.arn

  validation_record_fqdns = [
    for dvo in aws_acm_certificate.techworld.domain_validation_options :
    dvo.resource_record_name
  ]
}

output "acm_dns_validation_records" {
  description = "DNS CNAME records to add manually in Tenten"
  value = [
    for dvo in aws_acm_certificate.techworld.domain_validation_options : {
      domain_name = dvo.domain_name
      name        = dvo.resource_record_name
      type        = dvo.resource_record_type
      value       = dvo.resource_record_value
    }
  ]
}
