module "ec2_cluster" {
  source                 = "../../modules/aws/ec2_cluster/0.1"
  name                   = "graphgen"
  instance_type          = "t3a.micro"
  ami                    = data.aws_ami.centos7-x86_64-latest.id
  common_tags            = var.common_tags
  roles = [
    "common",
    "users",
    "docker",
    "docker_disk",
    "graphgen",
  ]
  extra_tags = {
    "docker_disk_device_name" = "xvdb"
  }
}

module "ebs_docker" {
  source                  = "../../modules/aws/ebs/0.1"
  common_tags             = var.common_tags
  instance_ids            = module.ec2_cluster.ec2_instance_ids
  data_volume_size        = 1
  data_volume_name        = "docker"
  data_volume_device_name = "xvdb"
}