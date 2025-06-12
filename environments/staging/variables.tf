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
  default     = "staging"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.27"
}

variable "eks_instance_types" {
  description = "List of instance types for EKS nodes"
  type        = list(string)
  default     = ["t3.large"]
}

variable "eks_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 3
}

variable "eks_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 6
}

variable "eks_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 2
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

variable "sns_topic_name" {
  description = "Name of the SNS topic for GuardDuty findings"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    Environment = "staging"
    Project     = "pharma-infra"
    ManagedBy   = "terraform"
  }
} 