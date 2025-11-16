#!/bin/bash

# Viatra Secret Manager Seeding Script
# This script populates Google Cloud Secret Manager with initial secret values
#
# IMPORTANT: Secret Management Strategy
# =====================================
# TERRAFORM-MANAGED SECRETS (DO NOT MODIFY WITH THIS SCRIPT):
#   - db-password-${ENVIRONMENT}: Database password tightly coupled to Cloud SQL user
#   - jwt-secret-${ENVIRONMENT}: JWT signing key (also managed by Terraform)
#
# SCRIPT-MANAGED SECRETS (Safe to create/update):
#   - redis-auth-${ENVIRONMENT}: Redis authentication
#   - api-keys-${ENVIRONMENT}: Third-party API keys
#   - app-config-${ENVIRONMENT}: Application configuration
#   - oauth-config-${ENVIRONMENT}: OAuth provider configuration
#   - database-url-${ENVIRONMENT}: Complete database connection URL
#   - redis-config-${ENVIRONMENT}: Redis connection configuration
#
# To rotate Terraform-managed secrets, use: terraform taint <resource_name>

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
DEFAULT_ENVIRONMENT="dev"

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Generate secure random string
generate_secret() {
    local length=${1:-32}
    openssl rand -base64 "$length" | tr -d "=+/" | cut -c1-$length
}

# Generate JWT secret (longer for better security)
generate_jwt_secret() {
    openssl rand -base64 64 | tr -d "=+/"
}

# Check if secret exists
secret_exists() {
    local secret_name="$1"
    gcloud secrets describe "$secret_name" >/dev/null 2>&1
}

# Create or update secret
create_or_update_secret() {
    local secret_name="$1"
    local secret_value="$2"
    local description="$3"
    
    if secret_exists "$secret_name"; then
        log_warning "Secret '$secret_name' already exists. Updating with new value..."
        echo "$secret_value" | gcloud secrets versions add "$secret_name" --data-file=-
        log_success "Updated secret: $secret_name"
    else
        log_info "Creating new secret: $secret_name"
        gcloud secrets create "$secret_name" \
            --replication-policy="automatic" \
            --labels="environment=$ENVIRONMENT,service=viatra,managed-by=script"
        
        echo "$secret_value" | gcloud secrets versions add "$secret_name" --data-file=-
        log_success "Created secret: $secret_name"
    fi
}

# Show usage
show_usage() {
    echo "Usage: $0 [ENVIRONMENT] [OPTIONS]"
    echo
    echo "ENVIRONMENT:"
    echo "  dev         Seed secrets for development environment (default)"
    echo "  staging     Seed secrets for staging environment"
    echo "  prod        Seed secrets for production environment"
    echo
    echo "OPTIONS:"
    echo "  --project   GCP project ID (uses current gcloud config if not specified)"
    echo "  --force     Force update existing secrets without confirmation"
    echo "  --help      Show this help message"
    echo
    echo "Examples:"
    echo "  $0 dev"
    echo "  $0 prod --project=my-project-id"
    echo "  $0 staging --force"
}

# Parse command line arguments
parse_args() {
    ENVIRONMENT="$DEFAULT_ENVIRONMENT"
    PROJECT_ID=""
    FORCE_UPDATE=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            dev|staging|prod)
                ENVIRONMENT="$1"
                shift
                ;;
            --project=*)
                PROJECT_ID="${1#*=}"
                shift
                ;;
            --force)
                FORCE_UPDATE=true
                shift
                ;;
            --help)
                show_usage
                exit 0
                ;;
            *)
                log_error "Unknown argument: $1"
                show_usage
                exit 1
                ;;
        esac
    done
}

# Get project ID
get_project_id() {
    if [ -z "$PROJECT_ID" ]; then
        PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
        if [ -z "$PROJECT_ID" ]; then
            log_error "No GCP project ID configured. Please run 'gcloud config set project YOUR_PROJECT_ID' or use --project flag"
            exit 1
        fi
    fi
    log_info "Using GCP project: $PROJECT_ID"
}

# Confirmation for production
confirm_production() {
    if [ "$ENVIRONMENT" = "prod" ] && [ "$FORCE_UPDATE" = false ]; then
        echo
        log_warning "⚠️  You are about to seed secrets for PRODUCTION!"
        echo "This will create or update secrets used by the live application."
        echo
        read -p "Are you sure you want to continue? (yes/no): " -r
        if [[ ! $REPLY =~ ^yes$ ]]; then
            log_info "Operation cancelled by user"
            exit 0
        fi
    fi
}

# Check for existing secrets
check_existing_secrets() {
    log_info "Checking for existing secrets..."
    
    # NOTE: db-password and jwt-secret are excluded as they're managed by Terraform
    local secrets=(
        "redis-auth-${ENVIRONMENT}"
        "api-keys-${ENVIRONMENT}"
        "app-config-${ENVIRONMENT}"
        "oauth-config-${ENVIRONMENT}"
        "database-url-${ENVIRONMENT}"
        "redis-config-${ENVIRONMENT}"
    )
    
    local existing_secrets=()
    for secret in "${secrets[@]}"; do
        if secret_exists "$secret"; then
            existing_secrets+=("$secret")
        fi
    done
    
    if [ ${#existing_secrets[@]} -gt 0 ] && [ "$FORCE_UPDATE" = false ]; then
        log_warning "The following secrets already exist:"
        for secret in "${existing_secrets[@]}"; do
            echo "  - $secret"
        done
        echo
        read -p "Do you want to update existing secrets? (yes/no): " -r
        if [[ ! $REPLY =~ ^yes$ ]]; then
            log_info "Skipping existing secrets. Only new secrets will be created."
            SKIP_EXISTING=true
        fi
    fi
}

# DISABLED: Database password is managed by Terraform
# This function is kept for reference but should not be used as it can desynchronize
# the Cloud SQL user password from the Terraform-managed secret.
# The db-password-${ENVIRONMENT} secret is created and managed by Terraform in cloud_sql.tf
seed_db_password() {
    local secret_name="db-password-${ENVIRONMENT}"
    
    log_error "DISABLED: $secret_name is managed by Terraform and should not be modified by this script"
    log_error "To rotate the database password, use Terraform with 'terraform taint' on the random_password resource"
    return 1
}

# Seed Redis auth
seed_redis_auth() {
    local secret_name="redis-auth-${ENVIRONMENT}"
    
    if [ "$SKIP_EXISTING" = true ] && secret_exists "$secret_name"; then
        log_info "Skipping existing secret: $secret_name"
        return
    fi
    
    log_info "Generating Redis authentication string..."
    local redis_auth
    redis_auth=$(generate_secret 32)
    create_or_update_secret "$secret_name" "$redis_auth" "Redis authentication string for $ENVIRONMENT environment"
}

# DISABLED: JWT secret is managed by Terraform
# This function is kept for reference but should not be used as it can desynchronize
# the JWT secret from the Terraform-managed secret.
# The jwt-secret-${ENVIRONMENT} secret is created and managed by Terraform in secret_manager.tf
seed_jwt_secret() {
    local secret_name="jwt-secret-${ENVIRONMENT}"
    
    log_error "DISABLED: $secret_name is managed by Terraform and should not be modified by this script"
    log_error "To rotate the JWT secret, use Terraform with 'terraform taint' on the random_password resource"
    return 1
}

# Seed API keys
seed_api_keys() {
    local secret_name="api-keys-${ENVIRONMENT}"
    
    if [ "$SKIP_EXISTING" = true ] && secret_exists "$secret_name"; then
        log_info "Skipping existing secret: $secret_name"
        return
    fi
    
    log_info "Creating API keys configuration..."
    
    # For development, use placeholder values
    # For production, these should be manually updated with real values
    local api_keys_json
    if [ "$ENVIRONMENT" = "prod" ]; then
        api_keys_json='{
            "stripe_api_key": "sk_live_REPLACE_WITH_REAL_KEY",
            "twilio_auth_token": "REPLACE_WITH_REAL_TOKEN",
            "sendgrid_api_key": "SG.REPLACE_WITH_REAL_KEY",
            "firebase_key": "REPLACE_WITH_REAL_KEY"
        }'
        log_warning "Created API keys with placeholder values. Please update with real production keys!"
    else
        api_keys_json='{
            "stripe_api_key": "sk_test_placeholder_stripe_key",
            "twilio_auth_token": "placeholder_twilio_token",
            "sendgrid_api_key": "SG.placeholder_sendgrid_key",
            "firebase_key": "placeholder_firebase_key"
        }'
    fi
    
    create_or_update_secret "$secret_name" "$api_keys_json" "Third-party API keys for $ENVIRONMENT environment"
}

# Seed app configuration
seed_app_config() {
    local secret_name="app-config-${ENVIRONMENT}"
    
    if [ "$SKIP_EXISTING" = true ] && secret_exists "$secret_name"; then
        log_info "Skipping existing secret: $secret_name"
        return
    fi
    
    log_info "Creating application configuration..."
    
    local encryption_key
    encryption_key=$(generate_secret 32)
    local session_secret
    session_secret=$(generate_secret 32)
    local password_pepper
    password_pepper=$(generate_secret 16)
    
    local app_config_json
    app_config_json=$(cat <<EOF
{
    "encryption_key": "$encryption_key",
    "session_secret": "$session_secret",
    "password_pepper": "$password_pepper",
    "file_upload_max_size": "10485760",
    "rate_limit_max": "100",
    "rate_limit_window": "900000"
}
EOF
)
    
    create_or_update_secret "$secret_name" "$app_config_json" "Application configuration for $ENVIRONMENT environment"
}

# Seed OAuth configuration
seed_oauth_config() {
    local secret_name="oauth-config-${ENVIRONMENT}"
    
    if [ "$SKIP_EXISTING" = true ] && secret_exists "$secret_name"; then
        log_info "Skipping existing secret: $secret_name"
        return
    fi
    
    log_info "Creating OAuth configuration..."
    
    local oauth_config_json
    if [ "$ENVIRONMENT" = "prod" ]; then
        oauth_config_json='{
            "google_client_id": "REPLACE_WITH_REAL_CLIENT_ID",
            "google_client_secret": "REPLACE_WITH_REAL_CLIENT_SECRET",
            "apple_client_id": "REPLACE_WITH_REAL_CLIENT_ID",
            "apple_client_secret": "REPLACE_WITH_REAL_CLIENT_SECRET",
            "facebook_app_id": "REPLACE_WITH_REAL_APP_ID",
            "facebook_app_secret": "REPLACE_WITH_REAL_APP_SECRET"
        }'
        log_warning "Created OAuth config with placeholder values. Please update with real production credentials!"
    else
        oauth_config_json='{
            "google_client_id": "placeholder_google_client_id",
            "google_client_secret": "placeholder_google_client_secret",
            "apple_client_id": "placeholder_apple_client_id",
            "apple_client_secret": "placeholder_apple_client_secret",
            "facebook_app_id": "placeholder_facebook_app_id",
            "facebook_app_secret": "placeholder_facebook_app_secret"
        }'
    fi
    
    create_or_update_secret "$secret_name" "$oauth_config_json" "OAuth configuration for $ENVIRONMENT environment"
}

# Set IAM permissions
set_iam_permissions() {
    log_info "Setting IAM permissions for Cloud Run service account..."
    
    local service_account="viatra-cloud-run-${ENVIRONMENT}@${PROJECT_ID}.iam.gserviceaccount.com"
    
    local secrets=(
        "db-password-${ENVIRONMENT}"
        "redis-auth-${ENVIRONMENT}"
        "jwt-secret-${ENVIRONMENT}"
        "api-keys-${ENVIRONMENT}"
        "app-config-${ENVIRONMENT}"
        "oauth-config-${ENVIRONMENT}"
        "database-url-${ENVIRONMENT}"
        "redis-config-${ENVIRONMENT}"
    )
    
    for secret in "${secrets[@]}"; do
        if secret_exists "$secret"; then
            gcloud secrets add-iam-policy-binding "$secret" \
                --member="serviceAccount:$service_account" \
                --role="roles/secretmanager.secretAccessor" \
                --quiet >/dev/null 2>&1 || log_warning "Failed to set IAM permission for $secret (may already exist)"
        fi
    done
    
    log_success "IAM permissions configured"
}

# Main function
main() {
    echo "🔐 Viatra Secret Manager Setup"
    echo "=============================="
    echo
    
    parse_args "$@"
    get_project_id
    confirm_production
    check_existing_secrets
    
    echo
    log_info "Seeding secrets for environment: $ENVIRONMENT"
    log_info "Project: $PROJECT_ID"
    echo
    
    # Seed all secrets (excluding Terraform-managed secrets)
    log_warning "SKIPPING db-password-${ENVIRONMENT}: This secret is managed by Terraform and should not be overwritten"
    log_warning "SKIPPING jwt-secret-${ENVIRONMENT}: This secret is managed by Terraform and should not be overwritten"
    seed_redis_auth
    seed_api_keys
    seed_app_config
    seed_oauth_config
    
    # Set permissions
    set_iam_permissions
    
    echo
    log_success "🎉 Secret seeding completed!"
    
    if [ "$ENVIRONMENT" = "prod" ]; then
        echo
        log_warning "⚠️  IMPORTANT: Production secrets have been created with placeholder values."
        log_warning "Please update the following secrets with real production values:"
        log_warning "  - api-keys-${ENVIRONMENT} (Stripe, Twilio, SendGrid, Firebase keys)"
        log_warning "  - oauth-config-${ENVIRONMENT} (Google, Apple, Facebook credentials)"
        echo
        log_info "You can update secrets using:"
        log_info "  gcloud secrets versions add SECRET_NAME --data-file=value.txt"
    fi
    
    echo
    log_info "View created secrets:"
    log_info "  gcloud secrets list --filter=\"labels.environment=$ENVIRONMENT\""
}

# Run main function
main "$@"
