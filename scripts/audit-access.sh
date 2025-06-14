#!/bin/bash

# audit-access.sh - Access audit script for pharmaceutical infrastructure
# This script performs security audits and access reviews

set -e

# Load environment variables
source ./scripts/utils/load-env.sh

# Function to display usage
usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -e, --environment    Environment to audit (dev|staging|prod)"
    echo "  -t, --type          Audit type (iam|s3|eks|all)"
    echo "  -o, --output        Output format (json|text|csv)"
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
        -t|--type)
            AUDIT_TYPE="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_FORMAT="$2"
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

# Validate audit type
if [[ ! "$AUDIT_TYPE" =~ ^(iam|s3|eks|all)$ ]]; then
    echo "Error: Invalid audit type. Must be one of: iam, s3, eks, all"
    exit 1
fi

# Validate output format
if [[ ! "$OUTPUT_FORMAT" =~ ^(json|text|csv)$ ]]; then
    echo "Error: Invalid output format. Must be one of: json, text, csv"
    exit 1
fi

echo "Starting access audit process..."

# Function to audit IAM
audit_iam() {
    echo "Auditing IAM access..."
    
    # Get IAM users
    aws iam list-users --query "Users[*].[UserName,CreateDate,PasswordLastUsed]" --output $OUTPUT_FORMAT
    
    # Get IAM roles
    aws iam list-roles --query "Roles[*].[RoleName,CreateDate,LastUsedDate]" --output $OUTPUT_FORMAT
    
    # Get IAM policies
    aws iam list-policies --scope Local --query "Policies[*].[PolicyName,CreateDate,UpdateDate]" --output $OUTPUT_FORMAT
}

# Function to audit S3
audit_s3() {
    echo "Auditing S3 access..."
    
    # Get bucket policies
    aws s3api get-bucket-policy --bucket "pharma-${ENVIRONMENT}-data" --output $OUTPUT_FORMAT
    
    # Get bucket ACLs
    aws s3api get-bucket-acl --bucket "pharma-${ENVIRONMENT}-data" --output $OUTPUT_FORMAT
    
    # Get bucket logging
    aws s3api get-bucket-logging --bucket "pharma-${ENVIRONMENT}-data" --output $OUTPUT_FORMAT
}

# Function to audit EKS
audit_eks() {
    echo "Auditing EKS access..."
    
    # Get cluster access
    aws eks describe-cluster --name "pharma-${ENVIRONMENT}-cluster" --query "cluster.resourcesVpcConfig.securityGroupIds" --output $OUTPUT_FORMAT
    
    # Get node group IAM roles
    aws eks list-nodegroups --cluster-name "pharma-${ENVIRONMENT}-cluster" --query "nodegroups[*]" --output $OUTPUT_FORMAT
    
    # Get cluster IAM roles
    aws eks describe-cluster --name "pharma-${ENVIRONMENT}-cluster" --query "cluster.roleArn" --output $OUTPUT_FORMAT
}

# Perform audit based on type
if [ "$AUDIT_TYPE" = "all" ]; then
    audit_iam
    audit_s3
    audit_eks
else
    case "$AUDIT_TYPE" in
        "iam")
            audit_iam
            ;;
        "s3")
            audit_s3
            ;;
        "eks")
            audit_eks
            ;;
    esac
fi

echo "Access audit completed successfully!" 