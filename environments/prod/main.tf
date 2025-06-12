provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
    }
  }
}

data "aws_caller_identity" "current" {}

locals {
  sns_topic_arn = "arn:aws:sns:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${var.sns_topic_name}"
}

module "vpc" {
  source = "../../modules/network/vpc"

  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = var.vpc_cidr

  availability_zones = var.availability_zones
  private_subnets    = var.private_subnets
  public_subnets     = var.public_subnets

  tags = var.tags
}

module "kms" {
  source = "../../modules/security/kms"

  project_name = var.project_name
  environment  = var.environment
  description  = "KMS key for ${var.project_name}-${var.environment}"

  tags = var.tags
}

module "eks" {
  source = "../../modules/compute/eks"

  project_name = var.project_name
  environment  = var.environment

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  kubernetes_version = var.kubernetes_version
  instance_types     = var.eks_instance_types
  desired_size       = var.eks_desired_size
  max_size          = var.eks_max_size
  min_size          = var.eks_min_size

  kms_key_arn = module.kms.key_arn

  tags = var.tags
}

module "cloudtrail" {
  source = "../../modules/security/cloudtrail"

  project_name = var.project_name
  environment  = var.environment

  kms_key_arn = module.kms.key_arn

  tags = var.tags
}

module "config" {
  source = "../../modules/security/config"

  project_name = var.project_name
  environment  = var.environment

  tags = var.tags
}

module "guardduty" {
  source = "../../modules/security/guardduty"

  project_name = var.project_name
  environment  = var.environment

  threat_intel_bucket = var.threat_intel_bucket
  threat_intel_key    = var.threat_intel_key
  trusted_ips_bucket  = var.trusted_ips_bucket
  trusted_ips_key     = var.trusted_ips_key
  sns_topic_arn       = local.sns_topic_arn

  tags = var.tags
} 