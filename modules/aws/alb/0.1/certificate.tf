resource "aws_acm_certificate" "primary" {
  domain_name       = aws_route53_record.primary.fqdn
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation_primary" {
  allow_overwrite = true
  name            = tolist(aws_acm_certificate.primary.domain_validation_options)[0].resource_record_name
  records         = [ tolist(aws_acm_certificate.primary.domain_validation_options)[0].resource_record_value ]
  type            = tolist(aws_acm_certificate.primary.domain_validation_options)[0].resource_record_type
  zone_id         = data.aws_route53_zone.primary.id
  ttl             = 60
}

resource "aws_acm_certificate_validation" "primary" {
  certificate_arn         = aws_acm_certificate.primary.arn
  validation_record_fqdns = [ aws_route53_record.cert_validation_primary.fqdn ]
}
