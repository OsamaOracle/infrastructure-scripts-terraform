resource "aws_acm_certificate" "service" {
  count             = length(var.services)
  domain_name       = element(aws_route53_record.service.*.fqdn, count.index)
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation_service" {
  count           = length(var.services)
  allow_overwrite = true
  name            = tolist(element(aws_acm_certificate.service.*.domain_validation_options, count.index))[0].resource_record_name
  records         = [ tolist(element(aws_acm_certificate.service.*.domain_validation_options, count.index))[0].resource_record_value ]
  type            = tolist(element(aws_acm_certificate.service.*.domain_validation_options, count.index))[0].resource_record_type
  zone_id         = data.aws_route53_zone.primary.id
  ttl             = 60
}

resource "aws_acm_certificate_validation" "service" {
  count                   = length(var.services)
  certificate_arn         = element(aws_acm_certificate.service.*.arn, count.index)
  validation_record_fqdns = [ element(aws_route53_record.cert_validation_service.*.fqdn, count.index) ]
}
