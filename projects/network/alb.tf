resource "aws_alb" "internal" {
  subnets         = module.vpc.private_subnets
  internal        = true
  name            = "tf-alb-shared-internal"
  security_groups = [aws_security_group.this.id]
  tags = merge(
    var.common_tags,
    {
      "Name" = "alb-shared-internal",
    },
  )
}

resource "aws_alb" "external" {
  subnets         = module.vpc.public_subnets
  internal        = false
  security_groups = [aws_security_group.this.id]
  name            = "tf-alb-shared-external"
  tags = merge(
    var.common_tags,
    {
      "Name" = "alb-shared-external",
    },
  )
}

locals {
  alb_arns = [
    aws_alb.internal.arn,
    aws_alb.external.arn,
  ]
}

resource "aws_alb_listener" "https" {
  count             = 2
  load_balancer_arn = element(local.alb_arns, count.index)
  certificate_arn   = aws_acm_certificate_validation.primary.certificate_arn
  port              = "443"
  protocol          = "HTTPS"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Page not found"
      status_code  = "404"
    }
  }
}

resource "aws_alb_listener" "http" {
  count             = 2
  load_balancer_arn = element(local.alb_arns, count.index)
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_security_group" "this" {
  vpc_id = module.vpc.vpc_id
  name   = "tf-alb-shared-default-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_route53_zone" "primary" {
  name         = var.alb_default_dns_zone
  private_zone = false
}

resource "aws_acm_certificate" "primary" {
  domain_name       = var.alb_default_fqdn
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
