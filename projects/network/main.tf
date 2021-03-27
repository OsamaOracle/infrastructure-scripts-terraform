data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.0"

  name = var.basename
  cidr = "10.10.0.0/16"

  azs             = data.aws_availability_zones.available.names
  public_subnets  = [
    "10.10.0.0/24",
    "10.10.2.0/24",
  ]
  private_subnets = [
    "10.10.1.0/24",
    "10.10.3.0/24",
  ]

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Terraform   = "true"
    Environment = var.basename
  }
}

module "default_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "default-ssh-sg"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
}
