#!/bin/bash

# backup-state.sh - State backup script for pharmaceutical infrastructure
# This script creates backups of Terraform state files

set -e

# Load environment variables
source ./scripts/utils/load-env.sh

# Function to display usage
usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -e, --environment    Environment to backup (dev|staging|prod)"
    echo "  -b, --bucket        S3 bucket for backups"
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
        -b|--bucket)
            BACKUP_BUCKET="$2"
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

# Set default backup bucket if not provided
if [ -z "$BACKUP_BUCKET" ]; then
    BACKUP_BUCKET="pharma-infra-state-backups"
fi

# Create backup directory
BACKUP_DIR="backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "Starting state backup process..."

# Initialize Terraform
echo "Initializing Terraform..."
terraform init -backend-config="environments/$ENVIRONMENT/backend.tfvars"

# Select workspace
echo "Selecting workspace: $ENVIRONMENT"
terraform workspace select $ENVIRONMENT || terraform workspace new $ENVIRONMENT

# Backup state file
echo "Backing up state file..."
terraform state pull > "$BACKUP_DIR/terraform.tfstate"

# Backup state file to S3
echo "Uploading backup to S3..."
aws s3 cp "$BACKUP_DIR/terraform.tfstate" "s3://$BACKUP_BUCKET/$ENVIRONMENT/$(date +%Y%m%d_%H%M%S)_terraform.tfstate"

# Cleanup local backup
echo "Cleaning up local backup..."
rm -rf "$BACKUP_DIR"

# List recent backups
echo "Recent backups:"
aws s3 ls "s3://$BACKUP_BUCKET/$ENVIRONMENT/" --recursive | sort -r | head -n 5

echo "Backup completed successfully!" 