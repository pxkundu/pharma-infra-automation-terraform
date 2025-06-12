output "external_secrets_role_arn" {
  description = "ARN of the IAM role for External Secrets Operator"
  value       = aws_iam_role.external_secrets.arn
}

output "external_secrets_role_name" {
  description = "Name of the IAM role for External Secrets Operator"
  value       = aws_iam_role.external_secrets.name
}

output "external_secrets_namespace" {
  description = "Namespace where External Secrets Operator is installed"
  value       = helm_release.external_secrets.namespace
}

output "external_secrets_release_name" {
  description = "Name of the Helm release for External Secrets Operator"
  value       = helm_release.external_secrets.name
}

output "external_secrets_version" {
  description = "Version of External Secrets Operator installed"
  value       = helm_release.external_secrets.version
} 