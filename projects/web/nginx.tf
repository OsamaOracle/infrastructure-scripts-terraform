data "template_file" "user_data" {
  template = file("../../scripts/add-osamaoracle-user.yml")
}

module "ec2_cluster" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 2.0"

  name                   = "web-nginx"
  use_num_suffix         = "true"
  num_suffix_format      = "-%03d"

  ami                    = "ami-0d4002a13019b7703"
  instance_type          = "t3a.micro"
  key_name               = "alesh-rsa"
  vpc_security_group_ids = [
    data.terraform_remote_state.network.outputs.security_group_default.this_security_group_id,
    aws_security_group.nginx-80.id,
  ]
  subnet_ids             = [
    data.terraform_remote_state.network.outputs.private_subnets[0],
  ]

  user_data              = data.template_file.user_data.rendered

  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = 10
    },
  ]

  tags = {
    terraform_managed    = "true"
    ansible_managed      = "true"
    role_common          = "enabled"
    role_users           = "enabled"
    role_docker          = "enabled"
    role_web_nginx       = "enabled"
  }
}

data "aws_route53_zone" "public" {
  name         = "aws.osamaoracle.com"
  private_zone = false
}

resource "aws_route53_record" "this" {
  count   = module.ec2_cluster.instance_count
  zone_id = data.aws_route53_zone.public.zone_id
  name    = join(".", [join("", ["web-nginx", format("-%03d", count.index + 1)]), data.aws_route53_zone.public.name])
  type    = "A"
  ttl     = 300
  records = [element(module.ec2_cluster.private_ip, count.index)]
}
