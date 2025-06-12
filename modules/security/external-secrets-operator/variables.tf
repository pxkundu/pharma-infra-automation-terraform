variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_oidc_provider_arn" {
  description = "ARN of the EKS cluster OIDC provider"
  type        = string
}

variable "cluster_oidc_issuer_url" {
  description = "URL of the EKS cluster OIDC issuer"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS key used for encryption"
  type        = string
}

variable "chart_version" {
  description = "Version of the External Secrets Operator Helm chart"
  type        = string
  default     = "0.9.5"
}

variable "create_example_secret" {
  description = "Whether to create an example ExternalSecret resource"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
} 