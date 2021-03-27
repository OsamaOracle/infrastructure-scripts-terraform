variable "dns_zone" {
  default = "osamaoracle.com"
  type    = string
}

variable "security_group_id" {
  type    = string
}

variable "instance_ids" {
  type        = list(string)
  description = "Id of instances we want to create the EBS volume for"
}

variable "internal" {
  type = bool
  default = false
}

variable "services" {
  type = list(object({ name = string, port = number }))
}

variable "name" {
  type = string
  default = "alb"
}

variable "extra_tags" {
  type = map(string)
  default = {}
}

variable "common_tags" {
  type = map(string)
}
