variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "pharma-infra"
}

variable "environment" {
  description = "Environment (e.g., dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.2.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.2.101.0/24", "10.2.102.0/24", "10.2.103.0/24"]
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.27"
}

variable "eks_instance_types" {
  description = "List of instance types for EKS nodes"
  type        = list(string)
  default     = ["t3.xlarge"]
}

variable "eks_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 4
}

variable "eks_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 8
}

variable "eks_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 3
}

variable "threat_intel_bucket" {
  description = "S3 bucket containing threat intelligence data"
  type        = string
}

variable "threat_intel_key" {
  description = "S3 key for threat intelligence data"
  type        = string
}

variable "trusted_ips_bucket" {
  description = "S3 bucket containing trusted IPs"
  type        = string
}

variable "trusted_ips_key" {
  description = "S3 key for trusted IPs"
  type        = string
}

variable "sns_topic_name" {
  description = "Name of the SNS topic for GuardDuty findings"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
} 