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

resource "aws_lb_target_group" "this" {
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group_attachment" "test" {
  count             = length(var.instance_ids)
  target_group_arn  = aws_lb_target_group.this.arn
  target_id         = var.instance_ids[count.index]
  port              = var.app_port
}

resource "aws_alb" "this" {
  subnets         = var.internal ? data.terraform_remote_state.network.outputs.vpc.private_subnets : data.terraform_remote_state.network.outputs.vpc.public_subnets
  internal        = var.internal
  security_groups = [aws_security_group.this.id]
  name            = format("tf-alb-%s", length(var.alb_name) > 0 ? var.alb_name : var.name)
  tags = merge(
    var.common_tags,
    {
      "Name" = var.name,
    },
    var.extra_tags,
  )
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_alb.this.arn
  certificate_arn   = aws_acm_certificate_validation.primary.certificate_arn
  port              = "443"
  protocol          = "HTTPS"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
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
  type              = "ingress"
  security_group_id = var.security_group_id
  from_port         = var.app_port
  to_port           = var.app_port
  protocol          = "tcp"
  source_security_group_id = aws_security_group.this.id
}
