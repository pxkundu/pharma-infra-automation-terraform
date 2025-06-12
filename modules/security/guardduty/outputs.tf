output "detector_id" {
  description = "The ID of the GuardDuty detector"
  value       = aws_guardduty_detector.main.id
}

output "detector_arn" {
  description = "The ARN of the GuardDuty detector"
  value       = aws_guardduty_detector.main.arn
}

output "filter_id" {
  description = "The ID of the GuardDuty filter"
  value       = aws_guardduty_filter.high_severity.id
}

output "threat_intel_set_id" {
  description = "The ID of the GuardDuty threat intel set"
  value       = aws_guardduty_threatintelset.known_bad_ips.id
}

output "ipset_id" {
  description = "The ID of the GuardDuty IP set"
  value       = aws_guardduty_ipset.trusted_ips.id
}

output "cloudwatch_event_rule_arn" {
  description = "The ARN of the CloudWatch Event Rule for GuardDuty findings"
  value       = aws_cloudwatch_event_rule.guardduty_findings.arn
}

output "guardduty_sns_role_arn" {
  description = "The ARN of the IAM role for GuardDuty to publish to SNS"
  value       = aws_iam_role.guardduty_sns.arn
} 