data "aws_s3_bucket"  "downloads_osamaoracle_com" {
  provider = aws.eucentral1
  bucket   = "downloads.osamaoracle.com"
}

resource "aws_route53_record" "downloads_osamaoracle_com" {
  zone_id = data.aws_route53_zone.osamaoracle_com.zone_id
  name    = "downloads"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.downloads_osamaoracle_com.domain_name
    zone_id                = aws_cloudfront_distribution.downloads_osamaoracle_com.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_acm_certificate" "downloads_osamaoracle_com" {
  provider          = aws.useast1
  domain_name       = "downloads.osamaoracle.com"
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation_record_downloads_osamaoracle_com" {
  allow_overwrite = true
  name            = tolist(aws_acm_certificate.downloads_osamaoracle_com.domain_validation_options)[0].resource_record_name
  records         = [ tolist(aws_acm_certificate.downloads_osamaoracle_com.domain_validation_options)[0].resource_record_value ]
  type            = tolist(aws_acm_certificate.downloads_osamaoracle_com.domain_validation_options)[0].resource_record_type
  zone_id         = data.aws_route53_zone.osamaoracle_com.id
  ttl             = 60
}

resource "aws_acm_certificate_validation" "downloads_osamaoracle_com" {
  provider                = aws.useast1
  certificate_arn         = aws_acm_certificate.downloads_osamaoracle_com.arn
  validation_record_fqdns = [ aws_route53_record.cert_validation_record_downloads_osamaoracle_com.fqdn ]
}

resource "aws_cloudfront_distribution" "downloads_osamaoracle_com" {
  provider = aws.eucentral1
  origin {
    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2", "TLSv1.1"]
    }

    domain_name = data.aws_s3_bucket.downloads_osamaoracle_com.bucket_domain_name
    origin_id   = "downloads.osamaoracle.com"
  }

  enabled             = true

  aliases = ["downloads.osamaoracle.com"]

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "downloads.osamaoracle.com"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate_validation.downloads_osamaoracle_com.certificate_arn
    ssl_support_method  = "sni-only"
  }
}
