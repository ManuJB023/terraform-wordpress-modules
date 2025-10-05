# Compute Module Outputs

# Load Balancer outputs
output "load_balancer_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.wordpress.dns_name
}

output "load_balancer_zone_id" {
  description = "Zone ID of the load balancer"
  value       = aws_lb.wordpress.zone_id
}

output "load_balancer_arn" {
  description = "ARN of the load balancer"
  value       = aws_lb.wordpress.arn
}

output "load_balancer_url" {
  description = "URL of the load balancer"
  value       = "http://${aws_lb.wordpress.dns_name}"
}

# Target Group outputs
output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.wordpress.arn
}

output "target_group_name" {
  description = "Name of the target group"
  value       = aws_lb_target_group.wordpress.name
}

# Auto Scaling Group outputs
output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.wordpress.name
}

output "autoscaling_group_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.wordpress.arn
}

# Launch Template outputs
output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.wordpress.id
}

output "launch_template_version" {
  description = "Latest version of the launch template"
  value       = aws_launch_template.wordpress.latest_version
}

# Scaling Policy outputs
output "scale_up_policy_arn" {
  description = "ARN of the scale up policy"
  value       = aws_autoscaling_policy.scale_up.arn
}

output "scale_down_policy_arn" {
  description = "ARN of the scale down policy"
  value       = aws_autoscaling_policy.scale_down.arn
}