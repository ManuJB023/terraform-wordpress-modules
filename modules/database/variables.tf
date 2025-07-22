variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the database subnet group"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs to attach to the database"
  type        = list(string)
}

variable "database_name" {
  description = "Name of the database to create"
  type        = string
}

variable "master_username" {
  description = "Master username for the database"
  type        = string
  default     = "admin"
}

variable "master_password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GB for the database"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum allocated storage for auto scaling"
  type        = number
  default     = 100
}

variable "engine" {
  description = "Database engine"
  type        = string
  default     = "mysql"
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
  default     = "8.0"
}

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Backup window"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Maintenance window"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "multi_az" {
  description = "Enable multi-AZ deployment"
  type        = bool
  default     = false
}

variable "storage_encrypted" {
  description = "Enable storage encryption"
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot when destroying"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}