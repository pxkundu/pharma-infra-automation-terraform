#!/bin/bash
set -e

# Configuration
ENVIRONMENT=${1:-dev}
WORKSPACE="pharma-infra-${ENVIRONMENT}"
SLACK_WEBHOOK_URL=${SLACK_WEBHOOK_URL:-""}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to send Slack notification
send_slack_notification() {
    if [ -n "$SLACK_WEBHOOK_URL" ]; then
        curl -X POST -H 'Content-type: application/json' \
            --data "{
                \"text\": \"$1\",
                \"attachments\": [
                    {
                        \"color\": \"$2\",
                        \"text\": \"$3\"
                    }
                ]
            }" \
            "$SLACK_WEBHOOK_URL"
    fi
}

# Function to check if there are any changes
check_drift() {
    echo -e "${YELLOW}Checking for infrastructure drift in ${ENVIRONMENT} environment...${NC}"
    
    # Initialize Terraform
    terraform init
    
    # Select workspace
    terraform workspace select $WORKSPACE || terraform workspace new $WORKSPACE
    
    # Run terraform plan
    PLAN_OUTPUT=$(terraform plan -detailed-exitcode 2>&1)
    EXIT_CODE=$?
    
    case $EXIT_CODE in
        0)
            echo -e "${GREEN}No infrastructure drift detected in ${ENVIRONMENT} environment.${NC}"
            send_slack_notification "Infrastructure Drift Check - ${ENVIRONMENT}" "good" "✅ No infrastructure drift detected."
            ;;
        1)
            echo -e "${RED}Error running terraform plan:${NC}"
            echo "$PLAN_OUTPUT"
            send_slack_notification "Infrastructure Drift Check - ${ENVIRONMENT}" "danger" "❌ Error running terraform plan."
            exit 1
            ;;
        2)
            echo -e "${RED}Infrastructure drift detected in ${ENVIRONMENT} environment:${NC}"
            echo "$PLAN_OUTPUT"
            send_slack_notification "Infrastructure Drift Check - ${ENVIRONMENT}" "warning" "⚠️ Infrastructure drift detected. Please review the changes."
            exit 2
            ;;
    esac
}

# Main execution
echo "Starting drift detection for ${ENVIRONMENT} environment..."

# Check if environment is valid
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
    echo -e "${RED}Invalid environment. Please use dev, staging, or prod.${NC}"
    exit 1
fi

# Run drift detection
check_drift

echo "Drift detection completed." 