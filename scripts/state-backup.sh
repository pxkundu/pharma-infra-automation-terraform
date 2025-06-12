#!/bin/bash
set -e

# Configuration
ENVIRONMENT=${1:-dev}
WORKSPACE="pharma-infra-${ENVIRONMENT}"
BACKUP_BUCKET="pharma-infra-terraform-state-backup"
BACKUP_PREFIX="state-backups"
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

# Function to backup state file
backup_state() {
    echo -e "${YELLOW}Starting state backup for ${ENVIRONMENT} environment...${NC}"
    
    # Get current timestamp
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_KEY="${BACKUP_PREFIX}/${ENVIRONMENT}/${TIMESTAMP}.tfstate"
    
    # Initialize Terraform
    terraform init
    
    # Select workspace
    terraform workspace select $WORKSPACE || terraform workspace new $WORKSPACE
    
    # Get state file
    STATE_FILE=$(terraform state pull)
    
    # Upload to S3
    echo "$STATE_FILE" | aws s3 cp - "s3://${BACKUP_BUCKET}/${BACKUP_KEY}"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}State backup completed successfully.${NC}"
        echo "Backup location: s3://${BACKUP_BUCKET}/${BACKUP_KEY}"
        send_slack_notification "Terraform State Backup - ${ENVIRONMENT}" "good" "✅ State backup completed successfully."
    else
        echo -e "${RED}Error backing up state file.${NC}"
        send_slack_notification "Terraform State Backup - ${ENVIRONMENT}" "danger" "❌ Error backing up state file."
        exit 1
    fi
}

# Function to clean up old backups
cleanup_old_backups() {
    echo -e "${YELLOW}Cleaning up old state backups...${NC}"
    
    # Keep backups for 30 days
    aws s3 ls "s3://${BACKUP_BUCKET}/${BACKUP_PREFIX}/${ENVIRONMENT}/" | \
    while read -r line; do
        createDate=$(echo $line | awk {'print $1" "$2'})
        createDate=$(date -d "$createDate" +%s)
        olderThan=$(date -d "-30 days" +%s)
        if [[ $createDate -lt $olderThan ]]; then
            fileName=$(echo $line | awk {'print $4'})
            aws s3 rm "s3://${BACKUP_BUCKET}/${BACKUP_PREFIX}/${ENVIRONMENT}/$fileName"
        fi
    done
    
    echo -e "${GREEN}Cleanup completed.${NC}"
}

# Main execution
echo "Starting state backup process for ${ENVIRONMENT} environment..."

# Check if environment is valid
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
    echo -e "${RED}Invalid environment. Please use dev, staging, or prod.${NC}"
    exit 1
fi

# Check if AWS credentials are configured
if ! aws sts get-caller-identity &>/dev/null; then
    echo -e "${RED}AWS credentials not configured. Please configure AWS credentials.${NC}"
    exit 1
fi

# Create backup bucket if it doesn't exist
if ! aws s3api head-bucket --bucket $BACKUP_BUCKET 2>/dev/null; then
    echo -e "${YELLOW}Creating backup bucket...${NC}"
    aws s3api create-bucket \
        --bucket $BACKUP_BUCKET \
        --region us-east-1
    
    # Enable versioning
    aws s3api put-bucket-versioning \
        --bucket $BACKUP_BUCKET \
        --versioning-configuration Status=Enabled
fi

# Run backup
backup_state

# Cleanup old backups
cleanup_old_backups

echo "State backup process completed." 