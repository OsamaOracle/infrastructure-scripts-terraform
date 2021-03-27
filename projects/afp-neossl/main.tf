module "ec2_cluster" {
  source                 = "../../modules/aws/ec2_cluster/0.1"
  name                   = "afp-neossl"
  instance_type          = "t3a.xlarge"
  ami                    = "ami-0d4002a13019b7703"
  root_size              = 30
  common_tags            = var.common_tags
  roles = [
    "common",
    "users",
    "certbot",
  ]
}

resource "aws_security_group_rule" "ingress_http" {
  type              = "ingress"
  security_group_id = module.ec2_cluster.alb_security_group_id
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}
