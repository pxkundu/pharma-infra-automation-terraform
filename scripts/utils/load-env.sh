#!/bin/bash

# load-env.sh - Environment loading utility script
# This script loads environment variables for the pharmaceutical infrastructure

# Set default AWS region
export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-"us-east-1"}

# Load environment-specific variables
if [ -f "environments/${ENVIRONMENT}/.env" ]; then
    source "environments/${ENVIRONMENT}/.env"
fi

# Set common variables
export PROJECT_NAME="pharma-infra"
export ENVIRONMENT=${ENVIRONMENT:-"dev"}
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

# Validate required variables
required_vars=(
    "AWS_ACCESS_KEY_ID"
    "AWS_SECRET_ACCESS_KEY"
    "AWS_DEFAULT_REGION"
)

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: Required environment variable $var is not set"
        exit 1
    fi
done 