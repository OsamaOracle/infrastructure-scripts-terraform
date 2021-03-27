module "ec2_cluster" {
  source                 = "../../modules/aws/ec2_cluster/0.1"
  name                   = "hume-dev"
  instance_type          = "t3a.2xlarge"
  ami                    = data.aws_ami.centos7-x86_64-latest.id
  root_size              = 30
  common_tags            = var.common_tags
  roles = [
    "common",
    "users",
    "docker",
    "docker_disk",
    "elastic",
    "hume_cloud_annotation_service",
    "hume_cloud_discovery",
    "hume_cloud_gateway",
    "hume_cloud_monitoring",
    "hume_cloud_textrank_service",
    "hume_cloud_web",
    "minio",
    "minio_disk",
  ]
  extra_tags = {
    "docker_disk_device_name" = "xvdb"
    "minio_disk_device_name" = "xvdc"
  }
}

module "ebs_docker" {
  source                 = "../../modules/aws/ebs/0.1"
  common_tags            = var.common_tags
  instance_ids           = module.ec2_cluster.ec2_instance_ids
  data_volume_size       = 5
  data_volume_name       = "docker"
  data_volume_device_name = "xvdb"
}

module "ebs_minio" {
  source                 = "../../modules/aws/ebs/0.1"
  common_tags            = var.common_tags
  instance_ids           = module.ec2_cluster.ec2_instance_ids
  data_volume_size       = 120
  data_volume_name       = "minio"
  data_volume_device_name = "xvdc"
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

resource "aws_security_group_rule" "ingress_8085" {
  type              = "ingress"
  security_group_id = module.ec2_cluster.default_security_group_id
  from_port         = 8085
  to_port           = 8085
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ingress_8100" {
  type              = "ingress"
  security_group_id = module.ec2_cluster.default_security_group_id
  from_port         = 8100
  to_port           = 8100
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ingress_8761" {
  type              = "ingress"
  security_group_id = module.ec2_cluster.default_security_group_id
  from_port         = 8761
  to_port           = 8761
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ingress_10000" {
  type              = "ingress"
  security_group_id = module.ec2_cluster.default_security_group_id
  from_port         = 10000
  to_port           = 10000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

module "alb_default" {
  source            = "../../modules/aws/alb/0.3"
  services          = [
    { name: "elastic.dev.hume", port: 9200 },
    { name: "kibana.dev.hume", port: 5601 },
    { name: "discovery.dev.hume", port: 8761 },
    { name: "gateway.dev.hume", port: 10000 },
    { name: "minio.dev.hume", port: 9000 },
    { name: "dev.hume", port: 80 },
    { name: "api.dev.hume", port: 8080 },
    { name: "id.dev.hume", port: 8090 },
    { name: "orchestra.dev.hume", port: 8100 },
    { name: "grafana.dev.hume", port: 3000 },
  ]
  instance_ids      = module.ec2_cluster.ec2_instance_ids
  security_group_id = module.ec2_cluster.alb_security_group_id
  common_tags       = var.common_tags
}
