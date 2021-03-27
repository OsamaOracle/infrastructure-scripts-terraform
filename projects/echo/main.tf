module "ec2_cluster" {
  source                 = "../../modules/aws/ec2_cluster/0.1"
  name                   = "echo"
  instance_type          = "t3a.micro"
  key_name = "alesh-rsa"
  ami                    = data.aws_ami.centos7-x86_64-latest.id
  common_tags            = var.common_tags
  roles = [
    "common",
    "users",
    "docker",
    "docker_disk",
    "echo",
  ]
  extra_tags = {
    "docker_disk_device_name" = "xvdb"
  }
}

module "alb_echo" {
  source                 = "../../modules/aws/alb/0.3"
  instance_ids           = module.ec2_cluster.ec2_instance_ids
  security_group_id      = module.ec2_cluster.alb_security_group_id
  services = [
    { name = "echo",  port = 8080 },
  ]
  common_tags            = var.common_tags
}

module "ebs_docker" {
  source                  = "../../modules/aws/ebs/0.1"
  common_tags             = var.common_tags
  instance_ids            = module.ec2_cluster.ec2_instance_ids
  data_volume_size        = 2
  data_volume_name        = "docker"
  data_volume_device_name = "xvdb"
}
