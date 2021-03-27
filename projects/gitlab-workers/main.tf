module "ec2_cluster" {
  source                 = "../../modules/aws/ec2_cluster/0.1"
  name                   = "gitlab-runner"
  instance_type          = "t3a.2xlarge"
  ami                    = data.aws_ami.centos7-x86_64-latest.id
  key_name               = "alesh-rsa"
  root_size              = 50
  instance_count         = 1
  common_tags            = var.common_tags
  roles = [
    "common",
    "users",
    "docker",
    "docker_disk",
    "gitlab_runner",
  ]

  extra_tags = {
    "docker_disk_device_name" = "xvdb"
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

data "aws_s3_bucket" "cache" {
  bucket = "cache.gitlab-workers.osamaoracle.com"
}

resource "aws_iam_role_policy" "ec2_list_access" {
  role = module.ec2_cluster.default_role_id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "s3-gitlab-runner-cache" {
  role        = module.ec2_cluster.default_role_id

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
        "arn:aws:s3:::cache.gitlab-workers.osamaoracle.com"
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
        "arn:aws:s3:::cache.gitlab-workers.osamaoracle.com/*"
      ]
    }
  ],
  "Version": "2012-10-17"
}
  EOP

}
