variable "name" {
  description = "service name"
  type        = string
}

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

variable "app_port" {
  type = number
}

variable "internal" {
  type = bool
  default = false
}

variable "extra_tags" {
  type = map(string)
  default = {}
}

variable "common_tags" {
  type = map(string)
}

variable "alb_name" {
  type        = string
  default     = ""
}
