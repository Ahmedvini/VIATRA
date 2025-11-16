#!/bin/bash

# Viatra Health Platform Setup Script
# This script sets up the development environment for the Viatra platform

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    local missing_tools=()
    
    # Check Node.js
    if command_exists node; then
        NODE_VERSION=$(node --version)
        log_success "Node.js found: $NODE_VERSION"
        
        # Check if version is >= 20
        MAJOR_VERSION=$(echo "$NODE_VERSION" | sed 's/v//' | cut -d. -f1)
        if [ "$MAJOR_VERSION" -lt 20 ]; then
            log_warning "Node.js version should be 20 or higher. Current: $NODE_VERSION"
        fi
    else
        missing_tools+=("Node.js 20+")
    fi
    
    # Check npm
    if command_exists npm; then
        NPM_VERSION=$(npm --version)
        log_success "npm found: $NPM_VERSION"
    else
        missing_tools+=("npm")
    fi
    
    # Check Flutter
    if command_exists flutter; then
        FLUTTER_VERSION=$(flutter --version | head -n1)
        log_success "Flutter found: $FLUTTER_VERSION"
    else
        missing_tools+=("Flutter SDK 3.x+")
    fi
    
    # Check gcloud
    if command_exists gcloud; then
        GCLOUD_VERSION=$(gcloud version --format="value(Google Cloud SDK)")
        log_success "gcloud CLI found: $GCLOUD_VERSION"
    else
        missing_tools+=("Google Cloud CLI")
    fi
    
    # Check Terraform
    if command_exists terraform; then
        TERRAFORM_VERSION=$(terraform version | head -n1)
        log_success "Terraform found: $TERRAFORM_VERSION"
    else
        missing_tools+=("Terraform 1.5+")
    fi
    
    # Check Docker
    if command_exists docker; then
        DOCKER_VERSION=$(docker --version)
        log_success "Docker found: $DOCKER_VERSION"
    else
        log_warning "Docker not found (optional for local development)"
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        log_error "Missing required tools:"
        for tool in "${missing_tools[@]}"; do
            echo "  - $tool"
        done
        log_info "Please install missing tools and run this script again."
        exit 1
    fi
    
    log_success "All prerequisites met!"
}

# Setup GCP authentication
setup_gcp() {
    log_info "Setting up Google Cloud Platform..."
    
    # Check if already authenticated
    if gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n1 > /dev/null 2>&1; then
        ACTIVE_ACCOUNT=$(gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n1)
        log_success "Already authenticated with GCP as: $ACTIVE_ACCOUNT"
    else
        log_info "Authenticating with Google Cloud..."
        gcloud auth login
    fi
    
    # Set project
    echo
    read -p "Enter your GCP Project ID: " PROJECT_ID
    if [ -n "$PROJECT_ID" ]; then
        gcloud config set project "$PROJECT_ID"
        log_success "GCP project set to: $PROJECT_ID"
    else
        log_error "Project ID cannot be empty"
        exit 1
    fi
    
    # Set default region
    echo
    read -p "Enter your preferred GCP region [us-central1]: " REGION
    REGION=${REGION:-us-central1}
    gcloud config set compute/region "$REGION"
    log_success "GCP region set to: $REGION"
    
    # Enable required APIs
    log_info "Enabling required GCP APIs..."
    gcloud services enable \
        cloudbuild.googleapis.com \
        run.googleapis.com \
        sqladmin.googleapis.com \
        redis.googleapis.com \
        storage.googleapis.com \
        secretmanager.googleapis.com \
        compute.googleapis.com \
        vpcaccess.googleapis.com \
        artifactregistry.googleapis.com \
        cloudresourcemanager.googleapis.com \
        iam.googleapis.com \
        logging.googleapis.com \
        monitoring.googleapis.com
    
    log_success "GCP APIs enabled successfully!"
}

# Setup environment files
setup_environment() {
    log_info "Setting up environment configuration..."
    
    # Backend .env
    if [ ! -f "backend/.env" ]; then
        cp backend/.env.example backend/.env
        log_success "Created backend/.env from template"
        log_warning "Please edit backend/.env with your configuration"
    else
        log_info "backend/.env already exists"
    fi
    
    # Mobile .env
    if [ ! -f "mobile/.env" ]; then
        cp mobile/.env.example mobile/.env
        log_success "Created mobile/.env from template"
        log_warning "Please edit mobile/.env with your configuration"
    else
        log_info "mobile/.env already exists"
    fi
    
    # Terraform tfvars
    if [ ! -f "terraform/terraform.tfvars" ]; then
        cp terraform/terraform.tfvars.example terraform/terraform.tfvars
        log_success "Created terraform/terraform.tfvars from template"
        log_warning "Please edit terraform/terraform.tfvars with your project values"
    else
        log_info "terraform/terraform.tfvars already exists"
    fi
}

# Install dependencies
install_dependencies() {
    log_info "Installing project dependencies..."
    
    # Root dependencies
    log_info "Installing root dependencies..."
    npm install
    
    # Backend dependencies
    log_info "Installing backend dependencies..."
    cd backend
    npm install
    cd ..
    
    # Flutter dependencies
    log_info "Installing Flutter dependencies..."
    cd mobile
    flutter pub get
    cd ..
    
    log_success "Dependencies installed successfully!"
}

# Initialize Terraform
init_terraform() {
    log_info "Initializing Terraform..."
    
    cd terraform
    
    # Create GCS bucket for Terraform state if it doesn't exist
    PROJECT_ID=$(gcloud config get-value project)
    BUCKET_NAME="${PROJECT_ID}-terraform-state"
    
    if ! gsutil ls "gs://${BUCKET_NAME}" >/dev/null 2>&1; then
        log_info "Creating Terraform state bucket: $BUCKET_NAME"
        gsutil mb "gs://${BUCKET_NAME}"
        gsutil versioning set on "gs://${BUCKET_NAME}"
    fi
    
    # Initialize Terraform with backend configuration
    terraform init -backend-config="bucket=${BUCKET_NAME}"
    
    cd ..
    log_success "Terraform initialized successfully!"
}

# Verify setup
verify_setup() {
    log_info "Verifying setup..."
    
    # Check backend
    cd backend
    if npm run lint >/dev/null 2>&1; then
        log_success "Backend linting passed"
    else
        log_warning "Backend linting failed - check your code"
    fi
    cd ..
    
    # Check mobile
    cd mobile
    if flutter analyze >/dev/null 2>&1; then
        log_success "Flutter analysis passed"
    else
        log_warning "Flutter analysis failed - check your code"
    fi
    cd ..
    
    # Check Terraform
    cd terraform
    if terraform validate >/dev/null 2>&1; then
        log_success "Terraform configuration is valid"
    else
        log_warning "Terraform configuration has issues - check your .tfvars file"
    fi
    cd ..
    
    log_success "Setup verification completed!"
}

# Main setup function
main() {
    echo "🏥 Viatra Health Platform Setup"
    echo "================================"
    echo
    
    # Change to project root directory
    cd "$(dirname "$0")/.."
    
    check_prerequisites
    echo
    setup_gcp
    echo
    setup_environment
    echo
    install_dependencies
    echo
    init_terraform
    echo
    verify_setup
    echo
    
    log_success "🎉 Setup completed successfully!"
    echo
    log_info "Next steps:"
    echo "1. Edit configuration files (backend/.env, mobile/.env, terraform/terraform.tfvars)"
    echo "2. Deploy infrastructure: cd terraform && terraform plan && terraform apply"
    echo "3. Start development: npm run dev"
    echo
    log_info "For more information, see the README.md file"
}

# Run main function
main "$@"
