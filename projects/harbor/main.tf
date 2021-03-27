module "ec2_cluster" {
  source                 = "../../modules/aws/ec2_cluster/0.1"
  name                   = "harbor"
  instance_type          = "t3a.xlarge"
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
  source                  = "../../modules/aws/ebs/0.1"
  common_tags             = var.common_tags
  instance_ids            = module.ec2_cluster.ec2_instance_ids
  data_volume_size        = 200
  data_volume_name        = "docker"
  data_volume_device_name = "xvdb"
  data_volume_type        = "gp2"
  data_volume_encrypted  = false
}

module "alb_default" {
  source            = "../../modules/aws/alb/0.3"
  external          = true
  services          = [
    { name: "harbor", port: 8080 },
    { name: "docker", port: 8080 },
  ]
  instance_ids      = module.ec2_cluster.ec2_instance_ids
  security_group_id = module.ec2_cluster.alb_security_group_id
  common_tags       = var.common_tags
}

module "ec2_cluster_new" {
  source                 = "../../modules/aws/ec2_cluster/0.1"
  name                   = "harbor2"
  instance_type          = "t3a.xlarge"
  ami                    = data.aws_ami.centos7-x86_64-latest.id
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

module "ebs_docker_new" {
  source                  = "../../modules/aws/ebs/0.1"
  common_tags             = var.common_tags
  instance_ids            = module.ec2_cluster_new.ec2_instance_ids
  data_volume_size        = 5
  data_volume_name        = "docker"
  data_volume_device_name = "xvdb"
}

module "alb_default_new" {
  source            = "../../modules/aws/alb/0.3"
  services          = [
    { name: "harbor2", port: 8080 },
    { name: "docker2", port: 8080 },
  ]
  instance_ids      = module.ec2_cluster_new.ec2_instance_ids
  security_group_id = module.ec2_cluster_new.alb_security_group_id
  common_tags       = var.common_tags
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "storage.harbor.osamaoracle.com"
  acl    = "private"

  lifecycle {
    prevent_destroy = true
  }

  versioning {
    enabled = true
  }

}

resource "aws_iam_role_policy" "s3-harbor-storage" {
  role        = module.ec2_cluster_new.default_role_id

  policy = <<EOP
{
  "Statement": [
    {
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketLocation",
        "s3:ListBucketMultipartUploads",
        "s3:ListBucketVersions"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::storage.harbor.osamaoracle.com"
      ]
    },
    {
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:GetObjectTagging",
        "s3:PutObjectTagging",
        "s3:DeleteObject",
        "s3:AbortMultipartUpload",
        "s3:ListMultipartUploadParts"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::storage.harbor.osamaoracle.com/*"
      ]
    }
  ],
  "Version": "2012-10-17"
}
  EOP

}