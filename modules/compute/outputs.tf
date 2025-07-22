# Load Balancer outputs
output "load_balancer_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "load_balancer_zone_id" {
  description = "The zone ID of the load balancer"
  value       = aws_lb.main.zone_id
}

output "load_balancer_arn" {
  description = "The ARN of the load balancer"
  value       = aws_lb.main.arn
}

# Target Group outputs
output "target_group_arn" {
  description = "The ARN of the target group"
  value       = aws_lb_target_group.main.arn
}

# Auto Scaling Group outputs
output "autoscaling_group_name" {
  description = "The name of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.name
}

output "autoscaling_group_arn" {
  description = "The ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.arn
}

# Launch Template outputs
output "launch_template_id" {
  description = "The ID of the launch template"
  value       = aws_launch_template.main.id
}

output "launch_template_version" {
  description = "The version of the launch template"
  value       = aws_launch_template.main.latest_version
}