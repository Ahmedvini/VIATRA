# Deployment Guide

This document provides comprehensive instructions for deploying the Viatra Health Platform to Google Cloud Platform.

## Prerequisites

Before deploying, ensure you have:

### Required Tools
- **Google Cloud CLI** (gcloud) installed and configured
- **Terraform** 1.5+ installed
- **Docker** installed for local builds
- **Node.js** 20+ and npm for backend development
- **Flutter SDK** 3.x+ for mobile development

### Required Permissions
Your GCP user account needs these IAM roles:
- Project Editor or Owner
- Service Account Admin
- Security Admin
- Cloud SQL Admin
- Cloud Run Admin

### GCP Project Setup
1. Create a new GCP project or use existing one
2. Enable billing on the project
3. Set up a billing budget and alerts

## Environment Overview

The platform supports three environments:

| Environment | Purpose | Resources | Availability |
|-------------|---------|-----------|-------------|
| **Development** | Local dev & testing | Minimal | Single zone |
| **Staging** | Pre-production testing | Moderate | Single region |
| **Production** | Live application | Full scale | Multi-region |

## Initial Setup

### 1. Project Initialization

```bash
# Clone the repository
git clone <repository-url>
cd viatra-platform

# Run the setup script
chmod +x scripts/setup.sh
./scripts/setup.sh
```

The setup script will:
- Verify prerequisites
- Authenticate with GCP
- Enable required APIs
- Create environment files
- Install dependencies
- Initialize Terraform

### 2. Configuration

#### Backend Configuration
Edit `backend/.env`:
```bash
# Copy from template
cp backend/.env.example backend/.env

# Edit with your values
NODE_ENV=production
GCP_PROJECT_ID=your-project-id
# ... other variables
```

#### Mobile Configuration  
Edit `mobile/.env`:
```bash
# Copy from template
cp mobile/.env.example mobile/.env

# Edit with your values
API_BASE_URL=https://your-api-domain.com
ENVIRONMENT=production
# ... other variables
```

#### Terraform Configuration
Edit `terraform/terraform.tfvars`:
```bash
# Copy from template
cp terraform/terraform.tfvars.example terraform/terraform.tfvars

# Edit with your values
project_id = "your-gcp-project-id"
region = "us-central1"
environment = "prod"
# ... other variables
```

## Infrastructure Deployment

### 1. Terraform State Backend

Create a GCS bucket for Terraform state:

```bash
# Set your project ID
export PROJECT_ID="your-gcp-project-id"

# Create bucket
gsutil mb gs://${PROJECT_ID}-terraform-state

# Enable versioning
gsutil versioning set on gs://${PROJECT_ID}-terraform-state

# Set lifecycle policy
cat > lifecycle.json << 'EOF'
{
  "rule": [
    {
      "action": {"type": "Delete"},
      "condition": {"age": 30, "isLive": false}
    }
  ]
}
EOF
gsutil lifecycle set lifecycle.json gs://${PROJECT_ID}-terraform-state
```

### 2. Deploy Infrastructure

```bash
cd terraform

# Initialize Terraform with remote backend
terraform init -backend-config="bucket=${PROJECT_ID}-terraform-state"

# Review the deployment plan
terraform plan -var-file="terraform.tfvars"

# Apply the infrastructure
terraform apply -var-file="terraform.tfvars"
```

This will create:
- VPC network with subnets and firewall rules
- Cloud SQL PostgreSQL instance
- Redis Memorystore instance  
- Cloud Storage buckets
- Cloud Run service (placeholder)
- Service accounts and IAM bindings
- Secret Manager secrets

### 3. Initialize Secrets

Populate Secret Manager with initial values:

```bash
# Run the secrets seeding script
chmod +x scripts/seed-secrets.sh
./scripts/seed-secrets.sh prod
```

For production, update these secrets manually:
- API keys (Stripe, Twilio, SendGrid, Firebase)
- OAuth credentials (Google, Apple, Facebook)
- Database passwords (if needed)

## Application Deployment

### 1. Backend Deployment

#### Option A: Manual Deployment
```bash
# Use the deployment script
chmod +x scripts/deploy.sh
./scripts/deploy.sh prod
```

#### Option B: CI/CD Pipeline
Push to the main branch to trigger automatic deployment:

```bash
git add .
git commit -m "Deploy to production"
git push origin main
```

### 2. Mobile App Deployment

#### Android (Google Play Store)
```bash
cd mobile

# Build release APK
flutter build apk --release --obfuscate --split-debug-info=build/symbols

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols

# Upload to Google Play Console
# Follow the Google Play Console upload process
```

#### iOS (App Store)
```bash
cd mobile

# Build for iOS
flutter build ios --release --obfuscate --split-debug-info=build/symbols

# Open Xcode to archive and upload
open ios/Runner.xcworkspace
```

## Environment-Specific Deployments

### Development Environment

```bash
# Deploy development infrastructure
terraform apply -var="environment=dev" -var-file="dev.tfvars"

# Deploy backend to development
./scripts/deploy.sh dev

# Seed development secrets
./scripts/seed-secrets.sh dev
```

### Staging Environment

```bash
# Deploy staging infrastructure  
terraform apply -var="environment=staging" -var-file="staging.tfvars"

# Deploy backend to staging
./scripts/deploy.sh staging

# Run integration tests
npm run test:integration
```

### Production Environment

```bash
# Deploy production infrastructure
terraform apply -var="environment=prod" -var-file="prod.tfvars"

# Deploy backend to production
./scripts/deploy.sh prod

# Verify deployment
curl https://your-api-domain.com/health
```

## Post-Deployment Configuration

### 1. Database Setup

Run database migrations and seed data:

```bash
# Connect to Cloud SQL instance
gcloud sql connect viatra-db-prod --user=viatra_app

# Run migrations (if implemented)
cd backend
npm run migrate

# Seed initial data (if needed)
npm run seed
```

### 2. Domain Configuration

#### Custom Domain for API
```bash
# Map custom domain to Cloud Run service
gcloud run domain-mappings create \
    --service=viatra-backend-prod \
    --domain=api.yourdomain.com \
    --region=us-central1
```

#### SSL Certificate Setup
```bash
# Create managed SSL certificate
gcloud compute ssl-certificates create viatra-ssl-cert \
    --domains=api.yourdomain.com,yourdomain.com
```

### 3. Monitoring Setup

#### Uptime Monitoring
```bash
# Create uptime check
gcloud alpha monitoring uptime create \
    --hostname=api.yourdomain.com \
    --path=/health \
    --display-name="Viatra API Health Check"
```

#### Alerting Policies
```bash
# Create alerting policy for high error rate
gcloud alpha monitoring policies create \
    --policy-from-file=monitoring/error-rate-policy.yaml
```

## Verification and Testing

### 1. Infrastructure Verification

```bash
# Check Cloud Run service
gcloud run services list --region=us-central1

# Check Cloud SQL instance
gcloud sql instances list

# Check Redis instance  
gcloud redis instances list --region=us-central1

# Check Secret Manager
gcloud secrets list --filter="labels.environment=prod"
```

### 2. Application Health Checks

```bash
# API health check
curl https://your-api-domain.com/health

# Database connectivity test
curl https://your-api-domain.com/api/v1/health/database

# Redis connectivity test  
curl https://your-api-domain.com/api/v1/health/redis
```

### 3. End-to-End Testing

```bash
# Run integration tests against production
cd backend
npm run test:integration:prod

# Load testing
npm run test:load
```

## Monitoring and Maintenance

### 1. Log Monitoring

```bash
# View application logs
gcloud logs read --filter="resource.type=cloud_run_revision" --limit=50

# View error logs only
gcloud logs read --filter="severity>=ERROR" --limit=20

# Stream logs in real-time
gcloud logs tail --filter="resource.type=cloud_run_revision"
```

### 2. Performance Monitoring

Access Google Cloud Console:
- Cloud Run → Your Service → Metrics
- Cloud SQL → Your Instance → Monitoring  
- Redis → Your Instance → Monitoring

### 3. Security Monitoring

```bash
# Check IAM policy changes
gcloud logging read 'protoPayload.serviceName="cloudresourcemanager.googleapis.com"' \
    --limit=20 --format=json

# Check unusual access patterns
gcloud logging read 'severity>=WARNING AND resource.type="cloud_run_revision"' \
    --limit=20
```

## Backup and Disaster Recovery

### 1. Database Backups

```bash
# Create on-demand backup
gcloud sql backups create --instance=viatra-db-prod

# List available backups
gcloud sql backups list --instance=viatra-db-prod

# Restore from backup (if needed)
gcloud sql backups restore BACKUP_ID --restore-instance=viatra-db-prod
```

### 2. Configuration Backups

```bash
# Export current Terraform state
terraform show -json > backup/terraform-state-$(date +%Y%m%d).json

# Backup secret values (encrypted)
./scripts/backup-secrets.sh prod
```

## Rollback Procedures

### 1. Application Rollback

```bash
# Rollback to previous Cloud Run revision
gcloud run services update-traffic viatra-backend-prod \
    --to-revisions=PREVIOUS_REVISION=100 \
    --region=us-central1

# Or use the deployment script with rollback flag
./scripts/deploy.sh prod --rollback
```

### 2. Infrastructure Rollback

```bash
# Rollback Terraform changes
cd terraform
terraform apply -var-file="terraform.tfvars" -target=previous_state
```

## Troubleshooting

### Common Issues

#### 1. Cloud Run Deployment Fails
```bash
# Check service logs
gcloud logs read --filter="resource.type=cloud_run_revision" \
    --filter="severity>=ERROR" --limit=10

# Check service status
gcloud run services describe viatra-backend-prod --region=us-central1
```

#### 2. Database Connection Issues
```bash
# Test Cloud SQL connectivity
gcloud sql connect viatra-db-prod --user=viatra_app

# Check VPC connector
gcloud compute networks vpc-access connectors list --region=us-central1
```

#### 3. Secret Manager Access Issues
```bash
# Check IAM permissions
gcloud secrets get-iam-policy jwt-secret-prod

# Test secret access
gcloud secrets versions access latest --secret=jwt-secret-prod
```

#### 4. Mobile App Build Issues
```bash
# Clean Flutter cache
cd mobile
flutter clean
flutter pub get

# Check Flutter doctor
flutter doctor -v
```

### Performance Issues

#### 1. High Response Times
- Check Cloud Run metrics in GCP Console
- Review database query performance
- Check Redis cache hit rates
- Monitor VPC connector performance

#### 2. High Error Rates
- Review application logs for specific errors
- Check database connection pool status
- Verify secret manager access
- Monitor resource utilization

### Security Issues

#### 1. Unauthorized Access
- Review IAM policies and service account permissions
- Check firewall rules and VPC configuration
- Monitor authentication logs
- Verify Secret Manager access patterns

#### 2. Data Breaches
- Immediately rotate all secrets and API keys
- Review access logs for suspicious activity
- Check database audit logs
- Notify security team and stakeholders

## Scaling Considerations

### 1. Horizontal Scaling

Cloud Run automatically scales, but you can adjust:

```bash
# Update Cloud Run scaling settings
gcloud run services update viatra-backend-prod \
    --min-instances=5 \
    --max-instances=50 \
    --region=us-central1
```

### 2. Database Scaling

```bash
# Scale up Cloud SQL instance
gcloud sql instances patch viatra-db-prod \
    --tier=db-n1-standard-4

# Add read replicas
gcloud sql instances create viatra-db-read-replica \
    --master-instance-name=viatra-db-prod \
    --tier=db-n1-standard-2 \
    --region=us-east1
```

### 3. Cache Scaling

```bash
# Scale up Redis instance
gcloud redis instances update viatra-redis-prod \
    --size=4 \
    --region=us-central1
```

## Cost Optimization

### 1. Resource Right-Sizing
- Monitor actual resource usage
- Adjust Cloud Run CPU and memory allocation
- Optimize database tier based on usage
- Review storage classes and lifecycle policies

### 2. Cost Monitoring
```bash
# Set up budget alerts
gcloud billing budgets create \
    --billing-account=BILLING_ACCOUNT_ID \
    --display-name="Viatra Platform Budget" \
    --budget-amount=1000USD
```

### 3. Reserved Instances
Consider committed use discounts for:
- Cloud SQL instances (production)
- Compute Engine instances (if using)
- Storage volumes

This deployment guide provides the foundation for reliably deploying and maintaining the Viatra Health Platform. Regular review and updates of these procedures ensure smooth operations and optimal performance.
