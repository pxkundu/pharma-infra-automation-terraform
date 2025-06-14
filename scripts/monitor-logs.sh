#!/bin/bash

# monitor-logs.sh - Log monitoring script for pharmaceutical infrastructure
# This script monitors and analyzes logs from various infrastructure components

set -e

# Load environment variables
source ./scripts/utils/load-env.sh

# Function to display usage
usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -e, --environment    Environment to monitor (dev|staging|prod)"
    echo "  -s, --service       Service to monitor (eks|rds|lambda|all)"
    echo "  -t, --time          Time range (1h|6h|12h|24h|7d)"
    echo "  -f, --filter        Log filter pattern"
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
        -s|--service)
            SERVICE="$2"
            shift 2
            ;;
        -t|--time)
            TIME_RANGE="$2"
            shift 2
            ;;
        -f|--filter)
            FILTER="$2"
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

# Validate service
if [[ ! "$SERVICE" =~ ^(eks|rds|lambda|all)$ ]]; then
    echo "Error: Invalid service. Must be one of: eks, rds, lambda, all"
    exit 1
fi

# Validate time range
if [[ ! "$TIME_RANGE" =~ ^(1h|6h|12h|24h|7d)$ ]]; then
    echo "Error: Invalid time range. Must be one of: 1h, 6h, 12h, 24h, 7d"
    exit 1
fi

# Set default filter if not provided
if [ -z "$FILTER" ]; then
    FILTER="ERROR|WARN|CRITICAL"
fi

echo "Starting log monitoring process..."

# Function to get log group name
get_log_group() {
    local service=$1
    case "$service" in
        "eks")
            echo "/aws/eks/pharma-${ENVIRONMENT}-cluster/cluster"
            ;;
        "rds")
            echo "/aws/rds/pharma-${ENVIRONMENT}-db"
            ;;
        "lambda")
            echo "/aws/lambda/pharma-${ENVIRONMENT}-*"
            ;;
    esac
}

# Function to monitor logs
monitor_logs() {
    local service=$1
    local log_group=$(get_log_group "$service")
    
    echo "Monitoring logs for $service..."
    aws logs filter-log-events \
        --log-group-name "$log_group" \
        --start-time $(date -u -v-${TIME_RANGE} +%s000) \
        --filter-pattern "$FILTER" \
        --query "events[*].[timestamp,message]" \
        --output text
}

# Monitor logs based on service
if [ "$SERVICE" = "all" ]; then
    monitor_logs "eks"
    monitor_logs "rds"
    monitor_logs "lambda"
else
    monitor_logs "$SERVICE"
fi

echo "Log monitoring completed successfully!" 