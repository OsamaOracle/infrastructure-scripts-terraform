output "public_subnets" {
  value       = module.vpc.public_subnets
  description = "Public subnets"
}

output "private_subnets" {
  value       = module.vpc.private_subnets
  description = "Public subnets"
}

output "security_group_default" {
  value       = module.default_security_group
  description = "Security group: SSH"
}

output "vpc" {
  value       = module.vpc
  description = "VPC"
}
