#!/bin/bash

# cleanup.sh - Cleanup script for pharmaceutical infrastructure
# This script handles cleanup of resources and temporary files

set -e

# Load environment variables
source ./scripts/utils/load-env.sh

# Function to display usage
usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -e, --environment    Environment to cleanup (dev|staging|prod)"
    echo "  -t, --type          Type of cleanup (all|temp|logs|state)"
    echo "  -f, --force         Force cleanup without confirmation"
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
            CLEANUP_TYPE="$2"
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

# Validate cleanup type
if [[ ! "$CLEANUP_TYPE" =~ ^(all|temp|logs|state)$ ]]; then
    echo "Error: Invalid cleanup type. Must be one of: all, temp, logs, state"
    exit 1
fi

# Function to confirm cleanup
confirm_cleanup() {
    if [ "$FORCE" = true ]; then
        return 0
    fi
    
    read -p "Are you sure you want to proceed with cleanup? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cleanup cancelled"
        exit 1
    fi
}

echo "Starting cleanup process..."

# Cleanup temporary files
if [[ "$CLEANUP_TYPE" == "temp" || "$CLEANUP_TYPE" == "all" ]]; then
    echo "Cleaning up temporary files..."
    confirm_cleanup
    rm -rf .terraform
    rm -f .terraform.lock.hcl
    rm -f terraform.tfstate*
    rm -f *.tfplan
fi

# Cleanup logs
if [[ "$CLEANUP_TYPE" == "logs" || "$CLEANUP_TYPE" == "all" ]]; then
    echo "Cleaning up log files..."
    confirm_cleanup
    rm -rf logs/*
fi

# Cleanup state
if [[ "$CLEANUP_TYPE" == "state" || "$CLEANUP_TYPE" == "all" ]]; then
    echo "Cleaning up state files..."
    confirm_cleanup
    
    # Initialize Terraform
    echo "Initializing Terraform..."
    terraform init -backend-config="environments/$ENVIRONMENT/backend.tfvars"
    
    # Select workspace
    echo "Selecting workspace: $ENVIRONMENT"
    terraform workspace select $ENVIRONMENT || terraform workspace new $ENVIRONMENT
    
    # Remove state file
    echo "Removing state file..."
    terraform state rm 'module.*' || true
fi

echo "Cleanup completed successfully!" 