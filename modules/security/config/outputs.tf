output "config_recorder_id" {
  description = "The name of the configuration recorder"
  value       = aws_config_configuration_recorder.main.id
}

output "config_recorder_arn" {
  description = "The Amazon Resource Name (ARN) of the configuration recorder"
  value       = aws_config_configuration_recorder.main.arn
}

output "config_delivery_channel_id" {
  description = "The name of the delivery channel"
  value       = aws_config_delivery_channel.main.id
}

output "config_s3_bucket_name" {
  description = "The name of the S3 bucket where AWS Config logs are stored"
  value       = aws_s3_bucket.config.id
}

output "config_role_arn" {
  description = "The ARN of the IAM role used by AWS Config"
  value       = aws_iam_role.config.arn
} 