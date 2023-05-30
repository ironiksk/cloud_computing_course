variable "account_id" {
  description = "AWS account ID"
  type        = string
  default     = "536751478443"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "faas"
}

variable "env" {
  description = "Environment"
  type        = string
  default     = "prod"
}

variable "region" {
  description = "AWS region ID"
  default     = "us-west-2"
}

variable "log_retention_period" {
  description = "Retention period"
  type        = number
  default     = 30
}

variable "vpc_cidr" {
  description = "Network address block for VPC"
  type        = string
  default     = "10.20.0.0/20"
}
