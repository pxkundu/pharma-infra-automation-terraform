output "cloudtrail_id" {
  description = "The name of the trail"
  value       = aws_cloudtrail.main.id
}

output "cloudtrail_arn" {
  description = "The Amazon Resource Name (ARN) of the trail"
  value       = aws_cloudtrail.main.arn
}

output "cloudtrail_home_region" {
  description = "The region in which the trail was created"
  value       = aws_cloudtrail.main.home_region
}

output "cloudtrail_s3_bucket_name" {
  description = "The name of the S3 bucket where CloudTrail logs are stored"
  value       = aws_s3_bucket.cloudtrail.id
}

output "cloudtrail_cloudwatch_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group where CloudTrail logs are sent"
  value       = aws_cloudwatch_log_group.cloudtrail.arn
}

output "cloudtrail_cloudwatch_role_arn" {
  description = "The ARN of the IAM role used by CloudTrail to write to CloudWatch Logs"
  value       = aws_iam_role.cloudtrail_cloudwatch.arn
} 