#!/bin/bash

# validate.sh - Validation script for pharmaceutical infrastructure
# This script validates Terraform configurations and performs pre-deployment checks

set -e

# Load environment variables
source ./scripts/utils/load-env.sh

# Function to display usage
usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -e, --environment    Environment to validate (dev|staging|prod)"
    echo "  -m, --module        Specific module to validate"
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
        -m|--module)
            MODULE="$2"
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

echo "Starting validation process..."

# Initialize Terraform
echo "Initializing Terraform..."
terraform init -backend-config="environments/$ENVIRONMENT/backend.tfvars"

# Select workspace
echo "Selecting workspace: $ENVIRONMENT"
terraform workspace select $ENVIRONMENT || terraform workspace new $ENVIRONMENT

# Validate Terraform configuration
echo "Validating Terraform configuration..."
terraform validate

# Format check
echo "Checking Terraform formatting..."
terraform fmt -check -recursive

# Run tflint
echo "Running tflint..."
tflint

# Run tfsec
echo "Running security checks..."
tfsec .

# Validate variables
echo "Validating variables..."
terraform plan -var-file="environments/$ENVIRONMENT/terraform.tfvars" -detailed-exitcode > /dev/null

# Check for drift
echo "Checking for configuration drift..."
terraform plan -var-file="environments/$ENVIRONMENT/terraform.tfvars" -detailed-exitcode > /dev/null
DRIFT_STATUS=$?

if [ $DRIFT_STATUS -eq 2 ]; then
    echo "Warning: Configuration drift detected!"
    exit 1
elif [ $DRIFT_STATUS -eq 0 ]; then
    echo "No configuration drift detected."
else
    echo "Error: Validation failed!"
    exit 1
fi

echo "Validation completed successfully!" 