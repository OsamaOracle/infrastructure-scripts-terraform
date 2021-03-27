module "ec2_cluster" {
  source                 = "../../modules/aws/ec2_cluster/0.1"
  name                   = "hume-documentation"
  instance_type          = "t3a.micro"
  ami                    = "ami-0d4002a13019b7703"
  common_tags            = var.common_tags
  roles = [
    "common",
    "users",
    "docker",
    "docker_disk",
    "hume_documentation",
  ]
  extra_tags = {
    "docker_disk_device_name" = "xvdb"
  }
}

module "ebs_docker" {
  source                  = "../../modules/aws/ebs/0.1"
  common_tags             = var.common_tags
  instance_ids            = module.ec2_cluster.ec2_instance_ids
  data_volume_size        = 2
  data_volume_name        = "docker"
  data_volume_device_name = "xvdb"
}

module "alb" {
  source                 = "../../modules/aws/alb/0.3"
  external               = true
  instance_ids           = module.ec2_cluster.ec2_instance_ids
  security_group_id      = module.ec2_cluster.alb_security_group_id
  services = [
    { name = "docs.hume",  port = 80 },
  ]
  common_tags            = var.common_tags
}
