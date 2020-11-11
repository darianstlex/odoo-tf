resource "aws_acm_certificate" "app" {
  domain_name       = "ipuit.tech"
  validation_method = "DNS"
}

output "domain_validations" {
  value = aws_acm_certificate.app.domain_validation_options
}
