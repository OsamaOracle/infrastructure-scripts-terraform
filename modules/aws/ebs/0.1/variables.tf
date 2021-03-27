variable "instance_ids" {
  type        = list(string)
  description = "Id of instances we want to create the EBS volume for"
}

variable "data_volume_size" {
  type        = number
  description = "Size in GB of the data volume"
}

variable "data_volume_type" {
  type        = string
  default     = "gp3"
}

variable "data_volume_encrypted" {
  type        = bool
  default     = true
}

variable "data_volume_device_name" {
  type    = string
}

variable "data_volume_name" {
  default = "data"
  type    = string
}

variable "availability_zones" {
  type        = list(string)
  default     = ["eu-west-1a"]
}

variable "common_tags" {
  type = map(string)
}
