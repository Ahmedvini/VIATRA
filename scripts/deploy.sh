#!/bin/bash

# Viatra Health Platform Deployment Script
# This script handles manual deployment of the backend service to Google Cloud Run

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
DEFAULT_ENVIRONMENT="dev"
DEFAULT_REGION="us-central1"

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

# Show usage information
show_usage() {
    echo "Usage: $0 [ENVIRONMENT] [OPTIONS]"
    echo
    echo "ENVIRONMENT:"
    echo "  dev         Deploy to development environment (default)"
    echo "  staging     Deploy to staging environment"
    echo "  prod        Deploy to production environment"
    echo
    echo "OPTIONS:"
    echo "  --region    GCP region (default: us-central1)"
    echo "  --project   GCP project ID (uses current gcloud config if not specified)"
    echo "  --no-build  Skip Docker image build (use existing image)"
    echo "  --help      Show this help message"
    echo
    echo "Examples:"
    echo "  $0 dev"
    echo "  $0 staging --region=us-east1"
    echo "  $0 prod --project=my-project-id"
}

# Parse command line arguments
parse_args() {
    ENVIRONMENT="$DEFAULT_ENVIRONMENT"
    REGION="$DEFAULT_REGION"
    PROJECT_ID=""
    SKIP_BUILD=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            dev|staging|prod)
                ENVIRONMENT="$1"
                shift
                ;;
            --region=*)
                REGION="${1#*=}"
                shift
                ;;
            --project=*)
                PROJECT_ID="${1#*=}"
                shift
                ;;
            --no-build)
                SKIP_BUILD=true
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

# Validate environment
validate_environment() {
    case $ENVIRONMENT in
        dev|staging|prod)
            log_info "Deploying to environment: $ENVIRONMENT"
            ;;
        *)
            log_error "Invalid environment: $ENVIRONMENT"
            log_error "Valid environments: dev, staging, prod"
            exit 1
            ;;
    esac
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

# Generate version tag
generate_version() {
    # Use git commit hash if available, otherwise use timestamp
    if command -v git >/dev/null 2>&1 && [ -d .git ]; then
        VERSION=$(git rev-parse --short HEAD)
    else
        VERSION=$(date +%Y%m%d-%H%M%S)
    fi
    log_info "Using version tag: $VERSION"
}

# Confirmation prompt for production
confirm_production() {
    if [ "$ENVIRONMENT" = "prod" ]; then
        echo
        log_warning "⚠️  You are about to deploy to PRODUCTION!"
        echo "This will update the live application used by real users."
        echo
        read -p "Are you sure you want to continue? (yes/no): " -r
        if [[ ! $REPLY =~ ^yes$ ]]; then
            log_info "Deployment cancelled by user"
            exit 0
        fi
    fi
}

# Build Docker image
build_image() {
    if [ "$SKIP_BUILD" = true ]; then
        log_info "Skipping Docker build (--no-build flag specified)"
        return
    fi
    
    log_info "Building Docker image..."
    
    # Change to backend directory
    cd backend
    
    # Build image with multiple tags
    IMAGE_NAME="${REGION}-docker.pkg.dev/${PROJECT_ID}/viatra-repo/backend"
    
    docker build \
        -t "${IMAGE_NAME}:${VERSION}" \
        -t "${IMAGE_NAME}:${ENVIRONMENT}-latest" \
        -t "${IMAGE_NAME}:latest" \
        .
    
    log_success "Docker image built successfully"
    cd ..
}

# Push image to registry
push_image() {
    if [ "$SKIP_BUILD" = true ]; then
        log_info "Skipping image push (--no-build flag specified)"
        return
    fi
    
    log_info "Pushing image to Google Artifact Registry..."
    
    IMAGE_NAME="${REGION}-docker.pkg.dev/${PROJECT_ID}/viatra-repo/backend"
    
    # Configure Docker authentication
    gcloud auth configure-docker "${REGION}-docker.pkg.dev" --quiet
    
    # Push all tags
    docker push "${IMAGE_NAME}:${VERSION}"
    docker push "${IMAGE_NAME}:${ENVIRONMENT}-latest"
    
    if [ "$ENVIRONMENT" = "prod" ]; then
        docker push "${IMAGE_NAME}:latest"
    fi
    
    log_success "Image pushed to registry"
}

# Deploy to Cloud Run
deploy_service() {
    log_info "Deploying to Cloud Run..."
    
    SERVICE_NAME="viatra-backend-${ENVIRONMENT}"
    IMAGE_NAME="${REGION}-docker.pkg.dev/${PROJECT_ID}/viatra-repo/backend:${VERSION}"
    
    # Set environment-specific configurations
    case $ENVIRONMENT in
        dev)
            MIN_INSTANCES=0
            MAX_INSTANCES=5
            MEMORY="512Mi"
            CPU=1
            CONCURRENCY=100
            ;;
        staging)
            MIN_INSTANCES=1
            MAX_INSTANCES=8
            MEMORY="1Gi"
            CPU=1
            CONCURRENCY=100
            ;;
        prod)
            MIN_INSTANCES=2
            MAX_INSTANCES=20
            MEMORY="1Gi"
            CPU=2
            CONCURRENCY=100
            ;;
    esac
    
    # Deploy service
    gcloud run deploy "$SERVICE_NAME" \
        --image="$IMAGE_NAME" \
        --region="$REGION" \
        --service-account="viatra-cloud-run-${ENVIRONMENT}@${PROJECT_ID}.iam.gserviceaccount.com" \
        --set-env-vars="NODE_ENV=production,ENVIRONMENT=${ENVIRONMENT},GCP_PROJECT_ID=${PROJECT_ID}" \
        --vpc-connector="viatra-connector-${ENVIRONMENT}" \
        --vpc-egress=private-ranges-only \
        --memory="$MEMORY" \
        --cpu="$CPU" \
        --concurrency="$CONCURRENCY" \
        --max-instances="$MAX_INSTANCES" \
        --min-instances="$MIN_INSTANCES" \
        --port=8080 \
        --allow-unauthenticated \
        --quiet
    
    # Get service URL
    SERVICE_URL=$(gcloud run services describe "$SERVICE_NAME" --region="$REGION" --format="value(status.url)")
    
    log_success "Service deployed successfully!"
    log_success "Service URL: $SERVICE_URL"
}

# Health check
health_check() {
    log_info "Performing health check..."
    
    SERVICE_NAME="viatra-backend-${ENVIRONMENT}"
    SERVICE_URL=$(gcloud run services describe "$SERVICE_NAME" --region="$REGION" --format="value(status.url)" 2>/dev/null || echo "")
    
    if [ -z "$SERVICE_URL" ]; then
        log_error "Could not get service URL"
        return 1
    fi
    
    # Wait a moment for service to be ready
    sleep 5
    
    # Check health endpoint
    if command -v curl >/dev/null 2>&1; then
        HEALTH_URL="${SERVICE_URL}/health"
        if curl -f -s "$HEALTH_URL" >/dev/null; then
            log_success "Health check passed ✅"
            log_info "Service is healthy and responding"
        else
            log_warning "Health check failed ❌"
            log_warning "Service may still be starting up"
        fi
    else
        log_warning "curl not available, skipping health check"
    fi
}

# Rollback function
rollback() {
    log_warning "Rolling back to previous revision..."
    
    SERVICE_NAME="viatra-backend-${ENVIRONMENT}"
    
    # Get previous revision
    PREVIOUS_REVISION=$(gcloud run revisions list \
        --service="$SERVICE_NAME" \
        --region="$REGION" \
        --format="value(metadata.name)" \
        --limit=2 \
        --sort-by="~metadata.creationTimestamp" | tail -n1)
    
    if [ -n "$PREVIOUS_REVISION" ]; then
        gcloud run services update-traffic "$SERVICE_NAME" \
            --to-revisions="$PREVIOUS_REVISION=100" \
            --region="$REGION"
        log_success "Rolled back to revision: $PREVIOUS_REVISION"
    else
        log_error "No previous revision found for rollback"
    fi
}

# Cleanup old revisions
cleanup() {
    log_info "Cleaning up old revisions..."
    
    SERVICE_NAME="viatra-backend-${ENVIRONMENT}"
    
    # Keep only the last 5 revisions
    OLD_REVISIONS=$(gcloud run revisions list \
        --service="$SERVICE_NAME" \
        --region="$REGION" \
        --format="value(metadata.name)" \
        --sort-by="~metadata.creationTimestamp" \
        --limit=100 | tail -n +6)
    
    if [ -n "$OLD_REVISIONS" ]; then
        echo "$OLD_REVISIONS" | while read -r revision; do
            gcloud run revisions delete "$revision" --region="$REGION" --quiet
        done
        log_success "Cleaned up old revisions"
    else
        log_info "No old revisions to clean up"
    fi
}

# Main deployment function
main() {
    echo "🚀 Viatra Backend Deployment"
    echo "============================="
    echo
    
    # Change to project root directory
    cd "$(dirname "$0")/.."
    
    parse_args "$@"
    validate_environment
    get_project_id
    generate_version
    confirm_production
    
    echo
    log_info "Deployment Configuration:"
    log_info "  Environment: $ENVIRONMENT"
    log_info "  Region: $REGION"
    log_info "  Project: $PROJECT_ID"
    log_info "  Version: $VERSION"
    echo
    
    # Deployment steps
    build_image
    push_image
    deploy_service
    health_check
    cleanup
    
    echo
    log_success "🎉 Deployment completed successfully!"
    
    # Show service information
    SERVICE_URL=$(gcloud run services describe "viatra-backend-${ENVIRONMENT}" --region="$REGION" --format="value(status.url)")
    echo
    log_info "Service Information:"
    log_info "  Service URL: $SERVICE_URL"
    log_info "  Health Check: ${SERVICE_URL}/health"
    log_info "  Environment: $ENVIRONMENT"
    echo
    log_info "Monitor your deployment:"
    log_info "  Logs: gcloud logs read --format=json --resource=\"gce_instance\""
    log_info "  Metrics: Google Cloud Console > Cloud Run > ${SERVICE_NAME}"
}

# Handle script interruption
trap 'log_error "Deployment interrupted"; exit 1' INT TERM

# Run main function with all arguments
main "$@"
