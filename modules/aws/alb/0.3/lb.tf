data "aws_instance" "ec2_instance" {
  count       = length(var.instance_ids)
  instance_id = var.instance_ids[count.index]
}

data "aws_vpc" "default" {
  tags = {
    Name = "networking"
  }
}

data "aws_security_group" "default" {
  name = "tf-alb-shared-default-sg"
}

locals {
  shared_alb_name = var.external ? "tf-alb-shared-external" : "tf-alb-shared-internal"
}

data "aws_alb" "shared" {
  name = local.shared_alb_name
}

data "aws_alb_listener" "shared_https" {
  load_balancer_arn = data.aws_alb.shared.arn
  port              = 443
}

resource "aws_lb_target_group" "this" {
  count   = length(var.services)
  port     = element(var.services.*.port, count.index)
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
  lifecycle {
    create_before_destroy = true
  }
  health_check {
    interval            = 10
    path                = "/"
  }
}

resource "aws_lb_target_group_attachment" "test" {
  count             = length(var.instance_ids) * length(var.services)
  target_group_arn  = element(aws_lb_target_group.this.*.arn, floor(count.index / length(var.instance_ids)) )
  target_id         = var.instance_ids[count.index % length(var.instance_ids)]
  port              = element(var.services.*.port, floor(count.index / length(var.instance_ids)) )
}

resource "aws_lb_listener_certificate" "additional_service_certificate" {
  count           = length(var.services)
  listener_arn    = data.aws_alb_listener.shared_https.arn
  certificate_arn = element(aws_acm_certificate_validation.service.*.certificate_arn, count.index)
}

resource "aws_lb_listener_rule" "https_service" {
  count        = length(var.services)
  listener_arn = data.aws_alb_listener.shared_https.arn

  action {
    type             = "forward"
    target_group_arn = element(aws_lb_target_group.this.*.arn, count.index)
  }

  condition {
    host_header {
      values = [element(aws_route53_record.service.*.fqdn, count.index)]
    }
  }
}

resource "aws_security_group_rule" "ingress_http" {
  count             = length(distinct(var.services.*.port))
  type              = "ingress"
  security_group_id = var.security_group_id
  from_port         = element(distinct(var.services.*.port), count.index)
  to_port           = element(distinct(var.services.*.port), count.index)
  protocol          = "tcp"
  source_security_group_id = data.aws_security_group.default.id
}
