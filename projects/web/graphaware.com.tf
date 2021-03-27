data "aws_route53_zone" "osamaoracle_com" {
  name = "osamaoracle.com"
}

resource "aws_route53_record" "www_osamaoracle_com" {
  zone_id = data.aws_route53_zone.osamaoracle_com.zone_id
  name    = "www"
  type    = "A"
  alias {
    name                   = aws_alb.this.dns_name
    zone_id                = aws_alb.this.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "osamaoracle_com" {
  zone_id = data.aws_route53_zone.osamaoracle_com.zone_id
  name    = ""
  type    = "A"
  alias {
    name                   = aws_alb.this.dns_name
    zone_id                = aws_alb.this.zone_id
    evaluate_target_health = false
  }
}

resource "aws_acm_certificate" "osamaoracle_com" {
  domain_name       = aws_route53_record.osamaoracle_com.fqdn
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate" "www_osamaoracle_com" {
  domain_name       = aws_route53_record.www_osamaoracle_com.fqdn
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation_record_www_osamaoracle_com" {
  allow_overwrite = true
  name            = tolist(aws_acm_certificate.www_osamaoracle_com.domain_validation_options)[0].resource_record_name
  records         = [ tolist(aws_acm_certificate.www_osamaoracle_com.domain_validation_options)[0].resource_record_value ]
  type            = tolist(aws_acm_certificate.www_osamaoracle_com.domain_validation_options)[0].resource_record_type
  zone_id         = data.aws_route53_zone.osamaoracle_com.id
  ttl             = 60
}

resource "aws_route53_record" "cert_validation_record_osamaoracle_com" {
  allow_overwrite = true
  name            = tolist(aws_acm_certificate.osamaoracle_com.domain_validation_options)[0].resource_record_name
  records         = [ tolist(aws_acm_certificate.osamaoracle_com.domain_validation_options)[0].resource_record_value ]
  type            = tolist(aws_acm_certificate.osamaoracle_com.domain_validation_options)[0].resource_record_type
  zone_id         = data.aws_route53_zone.osamaoracle_com.id
  ttl             = 60
}

resource "aws_acm_certificate_validation" "www_osamaoracle_com" {
  certificate_arn         = aws_acm_certificate.www_osamaoracle_com.arn
  validation_record_fqdns = [ aws_route53_record.cert_validation_record_www_osamaoracle_com.fqdn ]
}

resource "aws_acm_certificate_validation" "osamaoracle_com" {
  certificate_arn         = aws_acm_certificate.osamaoracle_com.arn
  validation_record_fqdns = [ aws_route53_record.cert_validation_record_osamaoracle_com.fqdn ]
}

resource "aws_alb" "this" {
  subnets         = data.terraform_remote_state.network.outputs.vpc.public_subnets
  security_groups = [aws_security_group.this.id]
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_alb.this.arn
  certificate_arn   = aws_acm_certificate_validation.osamaoracle_com.certificate_arn
  port              = "443"
  protocol          = "HTTPS"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_lb_listener_certificate" "www_osamaoracle_com" {
  listener_arn    = aws_alb_listener.https.arn
  certificate_arn = aws_acm_certificate_validation.www_osamaoracle_com.certificate_arn
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.this.arn
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

resource "aws_lb_target_group" "this" {
  port        = 80
  protocol    = "HTTP"
  vpc_id   = data.terraform_remote_state.network.outputs.vpc.vpc_id
}

resource "aws_lb_target_group_attachment" "test" {
  count             = module.ec2_cluster.instance_count
  target_group_arn  = aws_lb_target_group.this.arn
  target_id         = module.ec2_cluster.id[count.index]
  port              = 80
}

resource "aws_security_group" "this" {
  vpc_id = data.terraform_remote_state.network.outputs.vpc.vpc_id

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