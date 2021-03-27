module "ec2_cluster" {
  source                 = "../../modules/aws/ec2_cluster/0.1"
  name                   = "jumpbox"
  instance_type          = "t3a.micro"
  ami                    = data.aws_ami.centos7-x86_64-latest.id
  key_name               = "alesh-rsa"
  common_tags            = var.common_tags
  public                 = true

  roles = [
    "common",
    "users",
    "wireguard",
  ]

  extra_tags = {
    "team" = "infra",
  }
}

resource "aws_eip" "this" {
  instance = module.ec2_cluster.ec2_instance_ids[0]
  vpc      = true
  tags = {
    Name = "jumpbox-eip",
  }
}

resource "aws_security_group_rule" "ingress_wireguard" {
  type              = "ingress"
  security_group_id = module.ec2_cluster.default_security_group_id
  from_port         = 51820
  to_port           = 51820
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
}
