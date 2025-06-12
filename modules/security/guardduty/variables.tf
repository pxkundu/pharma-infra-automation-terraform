variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (e.g., dev, staging, prod)"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "threat_intel_bucket" {
  description = "S3 bucket containing the threat intelligence set"
  type        = string
}

variable "threat_intel_key" {
  description = "S3 key for the threat intelligence set"
  type        = string
}

variable "trusted_ips_bucket" {
  description = "S3 bucket containing the trusted IPs set"
  type        = string
}

variable "trusted_ips_key" {
  description = "S3 key for the trusted IPs set"
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for GuardDuty findings"
  type        = string
} 