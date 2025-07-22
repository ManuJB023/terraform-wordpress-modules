variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "wordpress"
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed to SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "public_key" {
  description = "Public key for EC2 access"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "wordpress"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "wp_title" {
  description = "WordPress site title"
  type        = string
  default     = "My WordPress Site"
}

variable "wp_admin" {
  description = "WordPress admin username"
  type        = string
  default     = "admin"
}

variable "wp_password" {
  description = "WordPress admin password"
  type        = string
  sensitive   = true
}

variable "wp_email" {
  description = "WordPress admin email"
  type        = string
}