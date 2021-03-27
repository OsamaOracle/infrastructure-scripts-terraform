data "template_file" "user_data" {
  template = file("${path.module}/scripts/add-osamaoracle-user.yml")
}

data "aws_vpc" "default" {
  tags = {
    Name = "networking"
  }
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_subnet_ids" "networking-private-eu-west-1a" {
  vpc_id = data.aws_vpc.default.id
  tags = {
    Name = "networking-private-eu-west-1a"
  }
}

data "aws_subnet_ids" "networking-public-eu-west-1a" {
  vpc_id = data.aws_vpc.default.id
  tags = {
    Name = "networking-public-eu-west-1a"
  }
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = var.name
  vpc_id      = data.aws_vpc.default.id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
}

locals {
  role_based_tags = {
    for role in var.roles:
      format("role_%s", role) => "enabled"
  }
}

resource "aws_instance" "this" {
  count = var.instance_count

  ami              = var.ami
  instance_type    = var.instance_type
  user_data        = data.template_file.user_data.rendered
  subnet_id        = tolist(var.public ? data.aws_subnet_ids.networking-public-eu-west-1a.ids : data.aws_subnet_ids.networking-private-eu-west-1a.ids)[0]

  key_name               = var.key_name
  vpc_security_group_ids = [
    module.security_group.this_security_group_id,
    aws_security_group.service.id,
    aws_security_group.alb.id,
  ]
  iam_instance_profile   = aws_iam_instance_profile.this.name
  root_block_device {
    volume_type = var.root_type
    volume_size = var.root_size
    tags = {
      "Name" = format("%s${var.name_suffix}", var.name, count.index + 1)
    }
  }

  lifecycle {
    ignore_changes = [
      ami,
      key_name,
    ]
  }

  tags = merge(
    var.common_tags,
    {
      "Name" = format("%s${var.name_suffix}", var.name, count.index + 1)
    },
    {
      ansible_managed      = var.ansible_managed
    },
    local.role_based_tags,
    var.extra_tags,
  )
}

resource "aws_security_group" "service" {
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_security_group" "alb" {
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_iam_instance_profile" "this" {
  role = aws_iam_role.this.name
}

resource "aws_iam_role" "this" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}
