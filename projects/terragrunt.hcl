remote_state {
  backend = "s3"
  config = {
    bucket = "terraform-state.common.osamaoracle.com"
    key    = "state/${path_relative_to_include()}"

    region         = "eu-west-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}

generate "common_resources" {
  path = "resources.terragrunt-generated.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
# Provider
provider "aws" {
  region  = "eu-west-1"
  profile = "ga"
  allowed_account_ids = ["600347145726"]
}

# Backend
terraform {
  backend "s3" {}
}

# Variables
variable "common_tags" {
  type = map(string)
}

# AMIs
data "aws_ami" "centos7-x86_64-latest" {
  owners      = ["125523088429"]
  most_recent = true

  filter {
    name   = "name"
    values = ["CentOS 7.9.2009*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ami" "centos7-arm64-latest" {
  owners      = ["125523088429"]
  most_recent = true

  filter {
    name   = "name"
    values = ["CentOS 7.9.2009*"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ami" "amazon-linux2-x86_64-latest" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "image-id"
    values = ["ami-01720b5f421cf0179"]
  }

}

EOF
}

generate "common_tfvars" {
  path = "common.terragrunt-generated.auto.tfvars"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
common_tags = {
  "terraform_managed" = "true"
  "terraform_project" = "${path_relative_to_include()}"
}
EOF
}
