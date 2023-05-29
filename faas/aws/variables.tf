variable "account_id" {
  description = "AWS account ID"
  type        = string
  default     = "536751478443"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "FaaS"
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


