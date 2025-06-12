output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = aws_nat_gateway.main[*].id
}

output "nat_public_ips" {
  description = "List of allocation IDs of Elastic IPs created for NAT Gateway"
  value       = aws_eip.nat[*].public_ip
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = aws_route_table.private[*].id
}

output "public_route_table_ids" {
  description = "List of IDs of public route tables"
  value       = aws_route_table.public.id
}

output "default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"
  value       = aws_vpc.main.default_security_group_id
}

output "vpc_flow_log_id" {
  description = "The ID of the Flow Log resource"
  value       = aws_flow_log.main.id
}

output "vpc_flow_log_cloudwatch_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group where VPC Flow Logs are sent"
  value       = aws_cloudwatch_log_group.flow_log.arn
} 