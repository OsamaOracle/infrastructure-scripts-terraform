resource "aws_route53_record" "hume_osamaoracle_com" {
  zone_id = data.aws_route53_zone.osamaoracle_com.zone_id
  name    = "hume"
  type    = "A"
  alias {
    name                   = aws_alb.this.dns_name
    zone_id                = aws_alb.this.zone_id
    evaluate_target_health = false
  }
}

resource "aws_acm_certificate" "hume_osamaoracle_com" {
  domain_name       = aws_route53_record.hume_osamaoracle_com.fqdn
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation_record_hume_osamaoracle_com" {
  allow_overwrite = true
  name            = tolist(aws_acm_certificate.hume_osamaoracle_com.domain_validation_options)[0].resource_record_name
  records         = [ tolist(aws_acm_certificate.hume_osamaoracle_com.domain_validation_options)[0].resource_record_value ]
  type            = tolist(aws_acm_certificate.hume_osamaoracle_com.domain_validation_options)[0].resource_record_type
  zone_id         = data.aws_route53_zone.osamaoracle_com.id
  ttl             = 60
}

resource "aws_acm_certificate_validation" "hume_osamaoracle_com" {
  certificate_arn         = aws_acm_certificate.hume_osamaoracle_com.arn
  validation_record_fqdns = [ aws_route53_record.cert_validation_record_hume_osamaoracle_com.fqdn ]
}

resource "aws_lb_listener_certificate" "hume_osamaoracle_com" {
  listener_arn    = aws_alb_listener.https.arn
  certificate_arn = aws_acm_certificate_validation.hume_osamaoracle_com.certificate_arn
}

resource "aws_alb_listener_rule" "host_header_rule" {
  listener_arn = aws_alb_listener.https.arn

  condition {
    host_header {
      values = ["hume.osamaoracle.com"]
    }
  }

  action {
    type             = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
      host        = "osamaoracle.com"
      path        = "/products/hume"
    }
  }
}
