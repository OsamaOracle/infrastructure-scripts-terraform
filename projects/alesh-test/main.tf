module "ec2_cluster" {
  source                 = "../../modules/aws/ec2_cluster/0.1"
  name                   = "alesh-test"
  instance_type          = "t3a.micro"
  key_name               = "alesh-rsa"
  ami                    = data.aws_ami.centos7-x86_64-latest.id
  common_tags            = var.common_tags
  ansible_managed = false
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
  source                  = "../../modules/aws/ebs/0.1"
  common_tags             = var.common_tags
  instance_ids            = module.ec2_cluster.ec2_instance_ids
  data_volume_size        = 2
  data_volume_name        = "docker"
  data_volume_device_name = "xvdb"
}

resource "aws_iam_role_policy" "ec2_list_access" {
  role = module.ec2_cluster.default_role_id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
