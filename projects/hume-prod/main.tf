module "ec2_cluster" {
  source                 = "../../modules/aws/ec2_cluster/0.1"
  name                   = "hume-prod"
  instance_type          = "t3a.2xlarge"
  ami                    = data.aws_ami.centos7-x86_64-latest.id
  root_size              = 30
  common_tags            = var.common_tags
  roles = [
    "common",
    "users",
    "docker",
    "docker_disk",
    "hume_prod_annotation_service",
    "hume_prod_demo",
  ]

  extra_tags = {
    "docker_disk_device_name" = "xvdb"
  }
}

resource "aws_security_group_rule" "ingress_7474" {
  type              = "ingress"
  security_group_id = module.ec2_cluster.default_security_group_id
  from_port         = 7474
  to_port           = 7474
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ingress_7687" {
  type              = "ingress"
  security_group_id = module.ec2_cluster.default_security_group_id
  from_port         = 7687
  to_port           = 7687
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

module "ebs_docker" {
source                 = "../../modules/aws/ebs/0.1"
  common_tags          = var.common_tags
instance_ids           = module.ec2_cluster.ec2_instance_ids
data_volume_size       = 5
data_volume_name       = "docker"
data_volume_device_name = "xvdb"
}

module "ebs_data" {
  source                 = "../../modules/aws/ebs/0.1"
  common_tags            = var.common_tags
  instance_ids           = module.ec2_cluster.ec2_instance_ids
  data_volume_size       = 100
  data_volume_name       = "data"
  data_volume_device_name = "sdc"
}

module "alb_default" {
  source            = "../../modules/aws/alb/0.3"
  services          = [
    { name: "demo.hume",         port:   80 },
    { name: "api.demo.hume",     port: 8080 },
    { name: "id.demo.hume",      port: 8090 },
    { name: "grafana.demo.hume", port: 3000 },
  ]
  instance_ids      = module.ec2_cluster.ec2_instance_ids
  security_group_id = module.ec2_cluster.alb_security_group_id
  common_tags       = var.common_tags
}
