output "ec2_instance_ids" {
  value       = aws_instance.this.*.id
}

output "ec2_instance_count" {
  value       = var.instance_count
}

output "alb_security_group_id" {
  value       = aws_security_group.alb.id
}

output "default_security_group_id" {
  value       = aws_security_group.service.id
}

output "default_role_id" {
  value       = aws_iam_role.this.id
}
