provider "aws" {
  region = var.aws_region
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = var.vpc_cidr
  tags         = var.tags
}

# KMS Module
module "kms" {
  source = "./modules/kms"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = data.aws_region.current.name
  tags         = var.tags
}

# EKS Module
module "eks" {
  source = "./modules/eks"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnet_ids

  kubernetes_version    = var.kubernetes_version
  enable_public_access  = var.enable_public_access
  cluster_ingress_cidrs = var.cluster_ingress_cidrs

  # Node group configuration
  node_ami_id = var.node_ami_id
  instance_types = var.eks_instance_types
  desired_size = var.eks_desired_size
  max_size = var.eks_max_size
  min_size = var.eks_min_size
  node_disk_size = var.node_disk_size

  kms_key_arn = module.kms.kms_key_arn
  tags = var.tags
} 