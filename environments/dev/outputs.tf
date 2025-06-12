output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnet_ids
}

output "eks_cluster_id" {
  description = "The ID of the EKS cluster"
  value       = module.eks.cluster_id
}

output "eks_cluster_arn" {
  description = "The ARN of the EKS cluster"
  value       = module.eks.cluster_arn
}

output "eks_cluster_endpoint" {
  description = "The endpoint for the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "eks_node_group_id" {
  description = "The ID of the EKS node group"
  value       = module.eks.node_group_id
}

output "kms_key_arn" {
  description = "The ARN of the KMS key"
  value       = module.kms.key_arn
}

output "cloudtrail_id" {
  description = "The ID of the CloudTrail trail"
  value       = module.cloudtrail.cloudtrail_id
}

output "cloudtrail_s3_bucket_name" {
  description = "The name of the S3 bucket where CloudTrail logs are stored"
  value       = module.cloudtrail.cloudtrail_s3_bucket_name
}

output "config_recorder_id" {
  description = "The ID of the AWS Config recorder"
  value       = module.config.config_recorder_id
}

output "config_s3_bucket_name" {
  description = "The name of the S3 bucket where AWS Config logs are stored"
  value       = module.config.config_s3_bucket_name
}

output "guardduty_detector_id" {
  description = "The ID of the GuardDuty detector"
  value       = module.guardduty.detector_id
}

output "guardduty_detector_arn" {
  description = "The ARN of the GuardDuty detector"
  value       = module.guardduty.detector_arn
} 