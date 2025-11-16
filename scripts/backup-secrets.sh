#!/bin/bash

# Viatra Secret Manager Backup Script
# This script creates encrypted backups of Google Cloud Secret Manager values
# for disaster recovery and audit purposes.
#
# Focuses on operational secrets that contain manually entered values.
# Excludes auto-generated secrets that can be recreated via Terraform.

set -euo pipefail  # Exit on any error, undefined variables, or pipe failures

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
DEFAULT_ENVIRONMENT="dev"
DEFAULT_OUTPUT_DIR="./backups"

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

# Show usage
show_usage() {
    echo "Usage: $0 [ENVIRONMENT] [OUTPUT_DIR] [OPTIONS]"
    echo
    echo "ENVIRONMENT:"
    echo "  dev         Backup secrets for development environment (default)"
    echo "  staging     Backup secrets for staging environment"
    echo "  prod        Backup secrets for production environment"
    echo
    echo "OUTPUT_DIR:"
    echo "  Directory to store encrypted backup files (default: ./backups)"
    echo
    echo "OPTIONS:"
    echo "  --project   GCP project ID (uses current gcloud config if not specified)"
    echo "  --kms-key   KMS key for encryption (optional, uses GPG if not specified)"
    echo "  --upload    Upload to GCS bucket after backup"
    echo "  --help      Show this help message"
    echo
    echo "Examples:"
    echo "  $0 dev"
    echo "  $0 prod ./prod-backup"
    echo "  $0 staging --project=my-project --upload"
    echo
    echo "Note: This script backs up secrets with operational values."
    echo "Auto-generated secrets (db-password, jwt-secret, redis-auth) are excluded"
    echo "as they can be recreated via Terraform or seed-secrets.sh."
}

# Parse command line arguments
parse_args() {
    ENVIRONMENT="$DEFAULT_ENVIRONMENT"
    OUTPUT_DIR="$DEFAULT_OUTPUT_DIR"
    PROJECT_ID=""
    KMS_KEY=""
    UPLOAD_TO_GCS=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            dev|staging|prod)
                ENVIRONMENT="$1"
                shift
                ;;
            --project)
                PROJECT_ID="$2"
                shift 2
                ;;
            --kms-key)
                KMS_KEY="$2"
                shift 2
                ;;
            --upload)
                UPLOAD_TO_GCS=true
                shift
                ;;
            --help)
                show_usage
                exit 0
                ;;
            -*)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
            *)
                if [ -z "${OUTPUT_DIR_SET:-}" ]; then
                    OUTPUT_DIR="$1"
                    OUTPUT_DIR_SET=true
                else
                    log_error "Too many positional arguments: $1"
                    show_usage
                    exit 1
                fi
                shift
                ;;
        esac
    done
}

# Validate prerequisites
validate_prerequisites() {
    log_info "Validating prerequisites..."
    
    # Check if gcloud is installed and authenticated
    if ! command -v gcloud >/dev/null 2>&1; then
        log_error "gcloud CLI is not installed or not in PATH"
        exit 1
    fi
    
    # Check authentication
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q "@"; then
        log_error "No active gcloud authentication found. Run 'gcloud auth login' first."
        exit 1
    fi
    
    # Get project ID if not provided
    if [ -z "$PROJECT_ID" ]; then
        PROJECT_ID=$(gcloud config get-value project 2>/dev/null || true)
        if [ -z "$PROJECT_ID" ]; then
            log_error "No project ID specified and no default project configured"
            log_error "Use --project flag or run 'gcloud config set project PROJECT_ID'"
            exit 1
        fi
    fi
    
    # Check if project exists and is accessible
    if ! gcloud projects describe "$PROJECT_ID" >/dev/null 2>&1; then
        log_error "Project '$PROJECT_ID' not found or not accessible"
        exit 1
    fi
    
    # Check GPG if no KMS key specified
    if [ -z "$KMS_KEY" ]; then
        if ! command -v gpg >/dev/null 2>&1; then
            log_error "GPG is required for encryption when KMS key is not specified"
            log_error "Install GPG or specify --kms-key option"
            exit 1
        fi
        
        # Check if we have a GPG key for encryption
        if ! gpg --list-secret-keys >/dev/null 2>&1; then
            log_warning "No GPG secret keys found. Generating a new key pair..."
            generate_gpg_key
        fi
    fi
    
    # Check gsutil if upload is requested
    if [ "$UPLOAD_TO_GCS" = true ]; then
        if ! command -v gsutil >/dev/null 2>&1; then
            log_error "gsutil is required for GCS upload but not found"
            exit 1
        fi
    fi
    
    log_success "Prerequisites validated successfully"
}

# Generate GPG key for encryption
generate_gpg_key() {
    log_info "Generating GPG key pair for secret encryption..."
    
    cat > /tmp/gpg_batch <<EOF
%echo Generating a GPG key for Viatra secrets backup
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: Viatra Secrets Backup
Name-Email: secrets-backup@viatra.local
Expire-Date: 2y
Passphrase: 
%commit
%echo GPG key generation complete
EOF
    
    gpg --batch --generate-key /tmp/gpg_batch
    rm -f /tmp/gpg_batch
    
    log_success "GPG key pair generated successfully"
}

# Get list of secrets to backup (operational values only)
get_secrets_list() {
    log_info "Getting list of secrets to backup for environment: $ENVIRONMENT"
    
    # Secrets commonly updated with operational values (worth backing up)
    # Excludes auto-generated secrets that can be recreated (jwt-secret, db-password, redis-auth)
    # These are secrets that contain manually entered or externally sourced values
    local secrets=(
        "api-keys-${ENVIRONMENT}"
        "app-config-${ENVIRONMENT}"
        "oauth-config-${ENVIRONMENT}"
        "database-url-${ENVIRONMENT}"
        "redis-config-${ENVIRONMENT}"
        "ssl-certificates-${ENVIRONMENT}"
    )
    
    # Filter to only existing secrets
    EXISTING_SECRETS=()
    for secret in "${secrets[@]}"; do
        if gcloud secrets describe "$secret" --project="$PROJECT_ID" >/dev/null 2>&1; then
            EXISTING_SECRETS+=("$secret")
        else
            log_warning "Secret '$secret' not found, skipping"
        fi
    done
    
    if [ ${#EXISTING_SECRETS[@]} -eq 0 ]; then
        log_error "No secrets found to backup for environment '$ENVIRONMENT'"
        exit 1
    fi
    
    log_info "Found ${#EXISTING_SECRETS[@]} secrets to backup"
}

# Create output directory
create_output_dir() {
    log_info "Creating output directory: $OUTPUT_DIR"
    
    # Create timestamped subdirectory
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_DIR="${OUTPUT_DIR}/${ENVIRONMENT}_${TIMESTAMP}"
    
    mkdir -p "$BACKUP_DIR"
    chmod 700 "$BACKUP_DIR"  # Restrict access to owner only
    
    log_success "Created backup directory: $BACKUP_DIR"
}

# Backup secrets
backup_secrets() {
    log_info "Starting secrets backup..."
    
    local backup_manifest="$BACKUP_DIR/backup-manifest.json"
    local manifest_data="{"
    manifest_data+='"timestamp":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'",'
    manifest_data+='"environment":"'$ENVIRONMENT'",'
    manifest_data+='"project_id":"'$PROJECT_ID'",'
    manifest_data+='"backup_method":"'$([ -n "$KMS_KEY" ] && echo "kms" || echo "gpg")'",'
    manifest_data+='"secrets":['
    
    local first=true
    for secret in "${EXISTING_SECRETS[@]}"; do
        log_info "Backing up secret: $secret"
        
        # Get latest version
        local secret_value
        if ! secret_value=$(gcloud secrets versions access latest --secret="$secret" --project="$PROJECT_ID" 2>/dev/null); then
            log_error "Failed to access secret: $secret"
            continue
        fi
        
        # Get version info
        local version_info
        version_info=$(gcloud secrets versions list "$secret" --limit=1 --format="value(name,createTime)" --project="$PROJECT_ID")
        local version_name=$(echo "$version_info" | cut -f1)
        local create_time=$(echo "$version_info" | cut -f2)
        
        # Encrypt secret
        local encrypted_file="${BACKUP_DIR}/${secret}.encrypted"
        if [ -n "$KMS_KEY" ]; then
            # Use Cloud KMS for encryption
            echo -n "$secret_value" | gcloud kms encrypt \
                --plaintext-file=- \
                --ciphertext-file="$encrypted_file" \
                --key="$KMS_KEY" \
                --project="$PROJECT_ID"
        else
            # Use GPG for encryption
            echo -n "$secret_value" | gpg --trust-model always --encrypt -r "secrets-backup@viatra.local" --armor --output "$encrypted_file"
        fi
        
        # Calculate checksum of encrypted file
        local checksum
        if command -v sha256sum >/dev/null 2>&1; then
            checksum=$(sha256sum "$encrypted_file" | cut -d' ' -f1)
        else
            checksum=$(shasum -a 256 "$encrypted_file" | cut -d' ' -f1)
        fi
        
        # Add to manifest
        [ "$first" = true ] && first=false || manifest_data+=","
        manifest_data+='{"secret_id":"'$secret'","version":"'$version_name'","created":"'$create_time'","checksum":"'$checksum'","file":"'$(basename "$encrypted_file")'"}'
        
        # Clear secret from memory
        unset secret_value
        
        log_success "Backed up secret: $secret (version: $version_name)"
    done
    
    manifest_data+=']}'
    echo "$manifest_data" | jq . > "$backup_manifest" 2>/dev/null || echo "$manifest_data" > "$backup_manifest"
    
    log_success "Backup completed. Manifest: $backup_manifest"
}

# Upload to GCS
upload_to_gcs() {
    if [ "$UPLOAD_TO_GCS" != true ]; then
        return 0
    fi
    
    log_info "Uploading backup to Google Cloud Storage..."
    
    local bucket_name="${PROJECT_ID}-secrets-backup"
    local gcs_path="gs://${bucket_name}/viatra-secrets/${ENVIRONMENT}/$(basename "$BACKUP_DIR")"
    
    # Create bucket if it doesn't exist
    if ! gsutil ls "gs://${bucket_name}" >/dev/null 2>&1; then
        log_info "Creating GCS bucket: $bucket_name"
        gsutil mb -p "$PROJECT_ID" "gs://${bucket_name}"
        gsutil versioning set on "gs://${bucket_name}"
        
        # Set lifecycle policy to delete old backups after 90 days
        cat > /tmp/lifecycle.json <<EOF
{
  "rule": [
    {
      "action": {"type": "Delete"},
      "condition": {"age": 90}
    }
  ]
}
EOF
        gsutil lifecycle set /tmp/lifecycle.json "gs://${bucket_name}"
        rm -f /tmp/lifecycle.json
    fi
    
    # Upload backup directory
    if gsutil cp -r "$BACKUP_DIR" "$gcs_path"; then
        log_success "Backup uploaded to: $gcs_path"
        
        # Set appropriate permissions (project-private)
        gsutil iam ch "projectEditor:${PROJECT_ID}:objectViewer" "$gcs_path/**"
    else
        log_error "Failed to upload backup to GCS"
        return 1
    fi
}

# Cleanup and security
cleanup() {
    log_info "Performing cleanup..."
    
    # Secure delete sensitive files (overwrite with random data)
    if command -v shred >/dev/null 2>&1; then
        find "$BACKUP_DIR" -name "*.tmp" -exec shred -vfz -n 3 {} \; 2>/dev/null || true
    fi
    
    # Set restrictive permissions on backup directory
    chmod -R 600 "$BACKUP_DIR"/* 2>/dev/null || true
    chmod 700 "$BACKUP_DIR"
    
    log_success "Cleanup completed"
}

# Generate summary report
generate_report() {
    log_info "Generating backup report..."
    
    local report_file="${BACKUP_DIR}/backup-report.txt"
    
    cat > "$report_file" <<EOF
Viatra Secrets Backup Report
============================

Timestamp: $(date -u +%Y-%m-%d\ %H:%M:%S\ UTC)
Environment: $ENVIRONMENT
Project ID: $PROJECT_ID
Backup Directory: $BACKUP_DIR
Encryption Method: $([ -n "$KMS_KEY" ] && echo "Cloud KMS ($KMS_KEY)" || echo "GPG")

Secrets Backed Up:
$(printf "%s\n" "${EXISTING_SECRETS[@]}" | sed 's/^/  - /')

Files Created:
$(ls -la "$BACKUP_DIR" | tail -n +2 | awk '{print "  " $9 " (" $5 " bytes)"}')

$([ "$UPLOAD_TO_GCS" = true ] && echo "GCS Upload: Completed" || echo "GCS Upload: Skipped")

Notes:
- Auto-generated secrets (db-password, jwt-secret, redis-auth) are excluded
- Use corresponding decryption method to restore secrets if needed
- Backup files are encrypted and safe for off-site storage
- Verify backup integrity using checksums in backup-manifest.json

EOF
    
    log_success "Backup report generated: $report_file"
    
    # Display summary
    echo
    log_success "🎉 Secrets backup completed successfully!"
    echo
    log_info "Summary:"
    echo "  Environment: $ENVIRONMENT"
    echo "  Secrets backed up: ${#EXISTING_SECRETS[@]}"
    echo "  Backup location: $BACKUP_DIR"
    echo "  Encryption: $([ -n "$KMS_KEY" ] && echo "Cloud KMS" || echo "GPG")"
    echo "  GCS upload: $([ "$UPLOAD_TO_GCS" = true ] && echo "Yes" || echo "No")"
    echo
    log_info "To restore secrets, use the backup-manifest.json file and decrypt the .encrypted files"
}

# Main function
main() {
    echo "Viatra Secret Manager Backup Script"
    echo "=================================="
    echo
    
    parse_args "$@"
    
    log_info "Starting backup for environment: $ENVIRONMENT"
    log_info "Project ID: $PROJECT_ID"
    log_info "Output directory: $OUTPUT_DIR"
    echo
    
    validate_prerequisites
    get_secrets_list
    create_output_dir
    backup_secrets
    upload_to_gcs
    cleanup
    generate_report
}

# Trap to ensure cleanup on exit
trap 'cleanup 2>/dev/null || true' EXIT

# Run main function
main "$@"
