variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "pharma-infra"
}

variable "environment" {
  description = "Environment (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.27"
}

variable "eks_instance_types" {
  description = "List of instance types for EKS nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "eks_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "eks_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 4
}

variable "eks_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "threat_intel_bucket" {
  description = "S3 bucket containing the threat intelligence set"
  type        = string
  default     = "pharma-infra-threat-intel"
}

variable "threat_intel_key" {
  description = "S3 key for the threat intelligence set"
  type        = string
  default     = "threat-intel/known-bad-ips.txt"
}

variable "trusted_ips_bucket" {
  description = "S3 bucket containing the trusted IPs set"
  type        = string
  default     = "pharma-infra-trusted-ips"
}

variable "trusted_ips_key" {
  description = "S3 key for the trusted IPs set"
  type        = string
  default     = "trusted-ips/allowed-ips.txt"
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for GuardDuty findings"
  type        = string
  default     = "arn:aws:sns:us-east-1:123456789012:pharma-infra-security-alerts"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "pharma-infra"
    ManagedBy   = "terraform"
  }
} 