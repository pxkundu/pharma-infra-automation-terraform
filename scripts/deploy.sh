#!/bin/bash

# deploy.sh - Main deployment script for pharmaceutical infrastructure
# This script handles the deployment of infrastructure components across environments

set -e

# Load environment variables
source ./scripts/utils/load-env.sh

# Function to display usage
usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -e, --environment    Environment to deploy (dev|staging|prod)"
    echo "  -m, --module        Specific module to deploy"
    echo "  -v, --version       Version to deploy"
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
        -v|--version)
            VERSION="$2"
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

# Initialize Terraform
echo "Initializing Terraform..."
terraform init -backend-config="environments/$ENVIRONMENT/backend.tfvars"

# Select workspace
echo "Selecting workspace: $ENVIRONMENT"
terraform workspace select $ENVIRONMENT || terraform workspace new $ENVIRONMENT

# Plan deployment
echo "Planning deployment..."
if [ -n "$MODULE" ]; then
    terraform plan -var-file="environments/$ENVIRONMENT/terraform.tfvars" -target="module.$MODULE" -out=tfplan
else
    terraform plan -var-file="environments/$ENVIRONMENT/terraform.tfvars" -out=tfplan
fi

# Confirm deployment
read -p "Do you want to apply these changes? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled"
    exit 1
fi

# Apply changes
echo "Applying changes..."
terraform apply tfplan

# Cleanup
rm -f tfplan

echo "Deployment completed successfully!" 