module "ec2_cluster" {
  source                 = "../../modules/aws/ec2_cluster/0.1"
  name                   = "artifactory"
  instance_type          = "t3a.medium"
  ami                    = data.aws_ami.centos7-x86_64-latest.id
  root_size              = 10
  common_tags            = var.common_tags
  roles = [
    "common",
    "users",
    "docker",
    "docker_disk",
  ]
  extra_tags = {
    "docker_disk_device_name" = "xvdb"
  }
}

module "ebs_docker" {
  source                 = "../../modules/aws/ebs/0.1"
  common_tags            = var.common_tags
  instance_ids           = module.ec2_cluster.ec2_instance_ids
  data_volume_size       = 100
  data_volume_name       = "docker"
  data_volume_device_name = "xvdb"
}

module "alb_default" {
  source            = "../../modules/aws/alb/0.3"
  services          = [
    { name: "artifactory", port: 8082 },
    { name: "mvn", port: 8082 },
  ]
  instance_ids      = module.ec2_cluster.ec2_instance_ids
  security_group_id = module.ec2_cluster.alb_security_group_id
  common_tags       = var.common_tags
}
