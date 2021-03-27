//todo: don't use hardcoded state to get network data
data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket         = "terraform-state.common.osamaoracle.com"
    key            = "state/network"
    region         = "eu-west-1"
  }
}

data "aws_instance" "ec2_instance" {
  count       = length(var.instance_ids)
  instance_id = var.instance_ids[count.index]
}

data "aws_vpc" "default" {
  tags = {
    Name = "networking"
  }
}

resource "aws_alb" "this" {
  subnets         = var.internal ? data.terraform_remote_state.network.outputs.vpc.private_subnets : data.terraform_remote_state.network.outputs.vpc.public_subnets
  internal        = var.internal
  security_groups = [aws_security_group.this.id]
  name            = format("tf-alb-%s", var.name)
  tags = merge(
    var.common_tags,
    {
      "Name" = var.name,
    },
    var.extra_tags,
  )
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

resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_alb.this.arn
  certificate_arn   = element(aws_acm_certificate_validation.service.*.certificate_arn, 0)
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

resource "aws_lb_listener_certificate" "additional_service_certificate" {
  count           = length(var.services) - 1
  listener_arn    = aws_alb_listener.https.arn
  certificate_arn = element(aws_acm_certificate_validation.service.*.certificate_arn, count.index + 1)
}

resource "aws_lb_listener_rule" "https_service" {
  count        = length(var.services)
  listener_arn = aws_alb_listener.https.arn

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

resource "aws_security_group" "this" {
  vpc_id = data.aws_vpc.default.id

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

resource "aws_security_group_rule" "ingress_http" {
  count             = length(distinct(var.services.*.port))
  type              = "ingress"
  security_group_id = var.security_group_id
  from_port         = element(distinct(var.services.*.port), count.index)
  to_port           = element(distinct(var.services.*.port), count.index)
  protocol          = "tcp"
  source_security_group_id = aws_security_group.this.id
}
