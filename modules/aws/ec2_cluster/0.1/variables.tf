variable "name" {
  description = "prefix of the instance name"
  type        = string
}

variable "name_suffix" {
  description = "suffix of the instance name"
  default     = "-%03d"
  type        = string
}

variable "ami" {
  default = "ami-01720b5f421cf0179"
  type    = string
}

variable "instance_type" {
  default = "t3a.micro"
  type    = string
}

variable "key_name" {
  default = "bot-ci-ansible-rsa"
  type    = string
}

variable "root_size" {
  default = 10
  type    = number
}

variable "root_type" {
  default = "gp3"
  type    = string
}

variable "instance_count" {
  default = 1
  type    = number
}

variable "dns_zone" {
  default = "aws.osamaoracle.com"
  type    = string
}

variable "roles" {
  default = []
  type    = list(string)
}

variable "extra_tags" {
  type = map(string)
  default = {}
}

variable "common_tags" {
  type = map(string)
}

variable "ansible_managed" {
  type    = bool
  default = true
}

variable "public" {
  type    = bool
  default = false
}


