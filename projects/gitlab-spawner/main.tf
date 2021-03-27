module "ec2_cluster" {
  source                 = "../../modules/aws/ec2_cluster/0.1"
  name                   = "gitlab-spawner"
  instance_type          = "t4g.micro"
  ami                    = data.aws_ami.centos7-arm64-latest.id
  key_name               = "alesh-rsa"
  common_tags            = var.common_tags

  roles = [
    "common",
    "users",
  ]
  extra_tags = {
    "team" = "infra",
  }
}

resource "aws_iam_role_policy" "ec2_admin_access" {
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

resource "aws_iam_instance_profile" "runner" {
  name = "gitlab-runner-role-profile"
  role = aws_iam_role.runner.name
}

resource "aws_iam_role" "runner" {
  name = "gitlab-runner-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "gitlab_runner_ec2_list_access" {
  role = aws_iam_role.runner.id

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

resource "aws_iam_role_policy" "gitlab_runner_s3_cache_access" {
  role = aws_iam_role.runner.id

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
