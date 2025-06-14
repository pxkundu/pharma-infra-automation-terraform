#!/bin/bash

# check-health.sh - Health check script for pharmaceutical infrastructure
# This script performs health checks on the infrastructure components

set -e

# Load environment variables
source ./scripts/utils/load-env.sh

# Function to display usage
usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -e, --environment    Environment to check (dev|staging|prod)"
    echo "  -c, --component     Specific component to check"
    echo "  -h, --help          Display this help message"
    exit 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -c|--component)
            COMPONENT="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
    echo "Error: Invalid environment. Must be one of: dev, staging, prod"
    exit 1
fi

echo "Starting health check process..."

# Function to check EKS cluster health
check_eks_health() {
    echo "Checking EKS cluster health..."
    aws eks describe-cluster --name "pharma-${ENVIRONMENT}-cluster" --query "cluster.status"
}

# Function to check RDS health
check_rds_health() {
    echo "Checking RDS instance health..."
    aws rds describe-db-instances --db-instance-identifier "pharma-${ENVIRONMENT}-db" --query "DBInstances[0].DBInstanceStatus"
}

# Function to check S3 bucket health
check_s3_health() {
    echo "Checking S3 bucket health..."
    aws s3api get-bucket-versioning --bucket "pharma-${ENVIRONMENT}-data"
}

# Function to check Lambda functions
check_lambda_health() {
    echo "Checking Lambda functions health..."
    aws lambda list-functions --query "Functions[?starts_with(FunctionName, 'pharma-${ENVIRONMENT}')].FunctionName"
}

# Function to check CloudWatch alarms
check_cloudwatch_health() {
    echo "Checking CloudWatch alarms..."
    aws cloudwatch describe-alarms --alarm-name-prefix "pharma-${ENVIRONMENT}"
}

# Perform health checks based on component
if [ -n "$COMPONENT" ]; then
    case "$COMPONENT" in
        "eks")
            check_eks_health
            ;;
        "rds")
            check_rds_health
            ;;
        "s3")
            check_s3_health
            ;;
        "lambda")
            check_lambda_health
            ;;
        "cloudwatch")
            check_cloudwatch_health
            ;;
        *)
            echo "Error: Unknown component: $COMPONENT"
            exit 1
            ;;
    esac
else
    # Check all components
    check_eks_health
    check_rds_health
    check_s3_health
    check_lambda_health
    check_cloudwatch_health
fi

echo "Health check completed successfully!" 