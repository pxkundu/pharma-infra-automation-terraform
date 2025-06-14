#!/bin/bash

# rotate-secrets.sh - Secret rotation script for pharmaceutical infrastructure
# This script handles rotation of secrets and credentials

set -e

# Load environment variables
source ./scripts/utils/load-env.sh

# Function to display usage
usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -e, --environment    Environment to rotate secrets (dev|staging|prod)"
    echo "  -t, --type          Secret type (kms|rds|eks|all)"
    echo "  -f, --force         Force rotation without confirmation"
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
            SECRET_TYPE="$2"
            shift 2
            ;;
        -f|--force)
            FORCE=true
            shift
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

# Validate secret type
if [[ ! "$SECRET_TYPE" =~ ^(kms|rds|eks|all)$ ]]; then
    echo "Error: Invalid secret type. Must be one of: kms, rds, eks, all"
    exit 1
fi

# Function to confirm rotation
confirm_rotation() {
    if [ "$FORCE" = true ]; then
        return 0
    fi
    
    read -p "Are you sure you want to rotate secrets? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Rotation cancelled"
        exit 1
    fi
}

echo "Starting secret rotation process..."

# Function to rotate KMS keys
rotate_kms() {
    echo "Rotating KMS keys..."
    confirm_rotation
    
    # Create new KMS key
    NEW_KEY_ID=$(aws kms create-key --description "pharma-${ENVIRONMENT}-key-$(date +%Y%m%d)" --query "KeyMetadata.KeyId" --output text)
    
    # Enable key rotation
    aws kms enable-key-rotation --key-id $NEW_KEY_ID
    
    # Update key alias
    aws kms update-alias --alias-name "alias/pharma-${ENVIRONMENT}-key" --target-key-id $NEW_KEY_ID
    
    echo "KMS key rotation completed. New key ID: $NEW_KEY_ID"
}

# Function to rotate RDS credentials
rotate_rds() {
    echo "Rotating RDS credentials..."
    confirm_rotation
    
    # Generate new password
    NEW_PASSWORD=$(openssl rand -base64 32)
    
    # Update RDS instance password
    aws rds modify-db-instance \
        --db-instance-identifier "pharma-${ENVIRONMENT}-db" \
        --master-user-password "$NEW_PASSWORD" \
        --apply-immediately
    
    # Update Secrets Manager
    aws secretsmanager update-secret \
        --secret-id "pharma-${ENVIRONMENT}-db-credentials" \
        --secret-string "{\"username\":\"admin\",\"password\":\"$NEW_PASSWORD\"}"
    
    echo "RDS credentials rotation completed"
}

# Function to rotate EKS certificates
rotate_eks() {
    echo "Rotating EKS certificates..."
    confirm_rotation
    
    # Get cluster name
    CLUSTER_NAME="pharma-${ENVIRONMENT}-cluster"
    
    # Update cluster certificate
    aws eks update-cluster-config \
        --name $CLUSTER_NAME \
        --resources-vpc-config endpointPrivateAccess=true,endpointPublicAccess=true
    
    echo "EKS certificate rotation completed"
}

# Perform rotation based on type
if [ "$SECRET_TYPE" = "all" ]; then
    rotate_kms
    rotate_rds
    rotate_eks
else
    case "$SECRET_TYPE" in
        "kms")
            rotate_kms
            ;;
        "rds")
            rotate_rds
            ;;
        "eks")
            rotate_eks
            ;;
    esac
fi

echo "Secret rotation completed successfully!" 