variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the load balancer and auto scaling group"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs to attach to instances and load balancer"
  type        = list(string)
}

variable "key_name" {
  description = "EC2 Key Pair name for SSH access"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "min_size" {
  description = "Minimum number of instances in the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances in the Auto Scaling Group"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Desired number of instances in the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "user_data" {
  description = "User data script to run on EC2 instances at launch"
  type        = string
  default     = ""
}

variable "ami_id" {
  description = "AMI ID to use for EC2 instances (optional - will use latest Amazon Linux 2 if not provided)"
  type        = string
  default     = ""
}

variable "target_group_arns" {
  description = "List of target group ARNs for the Auto Scaling Group"
  type        = list(string)
  default     = []
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for the load balancer"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}