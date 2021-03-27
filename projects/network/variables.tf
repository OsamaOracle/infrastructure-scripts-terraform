variable "region" {
  default = "eu-west-1"
}

variable "basename" {
  default = "networking"
}

variable "alb_default_dns_zone" {
  default = "osamaoracle.com"
  type    = string
}

variable "alb_default_fqdn" {
  default = "lb.osamaoracle.com"
  type    = string
}
