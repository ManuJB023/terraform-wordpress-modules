variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed to SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "create_key_pair" {
  description = "Whether to create a key pair"
  type        = bool
  default     = false
}

variable "public_key" {
  description = "Public key for EC2 key pair"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}