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

##### GitHub Repository Setup

**Prerequisites:**
1. **GitHub Repository Connection**: Connect your GitHub repository in GCP Console:
   - Navigate to Cloud Build > Triggers > Connect Repository
   - Select your GitHub account and authorize access
   - Choose the repository: `${var.github_owner}/${var.github_repo}` (configured in `terraform/variables.tf`)
   - Install the Google Cloud Build GitHub app if prompted

2. **Required Terraform Variables**: Ensure these are set in your `terraform.tfvars`:
   ```hcl
   github_owner = "your-github-username"
   github_repo  = "VIATRA"
   ```

##### Trigger Service Account Configuration

The Viatra platform uses dedicated service accounts for secure CI/CD operations:

- **Cloud Build Service Account** (`viatra-cloud-build-${environment}@${PROJECT_ID}.iam.gserviceaccount.com`): Used for build operations, image pushing, and deployment commands
- **Cloud Run Service Account** (`viatra-cloud-run-${environment}@${PROJECT_ID}.iam.gserviceaccount.com`): Used at runtime by the deployed backend service

**Terraform manages the trigger configuration automatically.** When you run `terraform apply`, it creates:
- Cloud Build triggers for main branch and pull requests
- Proper service account bindings
- Environment-specific substitutions

**To verify trigger configuration:**
```bash
# List triggers
gcloud builds triggers list --region=${REGION}

# Describe specific trigger
gcloud builds triggers describe viatra-backend-main-${ENVIRONMENT} --region=${REGION}

# Check service account binding
gcloud iam service-accounts get-iam-policy viatra-cloud-build-${ENVIRONMENT}@${PROJECT_ID}.iam.gserviceaccount.com
```

**Manual trigger creation (if not using Terraform):**
```bash
# Set environment variables
export PROJECT_ID="your-project-id"
export ENVIRONMENT="dev"
export REPO_OWNER="your-github-username"
export REPO_NAME="VIATRA"
export REGION="us-central1"

# Create trigger with custom service account
gcloud beta builds triggers create github \
  --name=viatra-backend-main-${ENVIRONMENT} \
  --repo-name=${REPO_NAME} \
  --repo-owner=${REPO_OWNER} \
  --branch-pattern="^main$" \
  --build-config=cloudbuild.yaml \
  --service-account=viatra-cloud-build-${ENVIRONMENT}@${PROJECT_ID}.iam.gserviceaccount.com \
  --region=${REGION}
```

##### Deployment Process

Push to the main branch to trigger automatic deployment:

```bash
git add .
git commit -m "Deploy to production"
git push origin main
```

**Build Pipeline Steps:**
1. **Build Steps 1-3**: Install dependencies, lint, and test (using Cloud Build SA)
2. **Build Steps 4-5**: Build and push Docker image to Artifact Registry (using Cloud Build SA)
3. **Build Step 6**: Deploy to Cloud Run with runtime service account (Cloud Build SA deploys, but specifies Cloud Run SA for the service)
4. **Build Steps 7-12**: Flutter testing and building
5. **Build Step 13**: Integration tests against deployed backend

### 2. Mobile App Deployment

#### Android (Google Play Store)
```bash
cd mobile

# Build release APK
flutter build apk --release --obfuscate --split-debug-info=build/symbols

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release

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

### 3. Secrets Management

The platform implements a comprehensive secrets management workflow using Google Secret Manager:

#### Secret Creation and Initial Population
```bash
# Create and populate secrets for an environment
./scripts/seed-secrets.sh [environment]

# Examples
./scripts/seed-secrets.sh dev
./scripts/seed-secrets.sh prod --project=my-production-project
```

#### Secret Backup and Export
```bash
# Create encrypted backups for disaster recovery
./scripts/backup-secrets.sh prod

# With additional options
./scripts/backup-secrets.sh prod ./backup-dir --upload --kms-key=projects/PROJECT/locations/LOCATION/keyRings/RING/cryptoKeys/KEY
```

#### Secret Rotation
```bash
# Rotate script-managed secrets (adds new versions while preserving old ones for audit)
./scripts/seed-secrets.sh prod --rotate

# Rotate Terraform-managed secrets (db-password, jwt-secret, redis-auth)
terraform taint random_password.db_password
terraform taint random_password.jwt_secret  
terraform taint random_password.redis_auth
terraform apply
```

#### Access Audit and Monitoring
```bash
# Check secret access permissions
gcloud secrets get-iam-policy SECRET_NAME

# View access logs
gcloud logging read 'resource.type="secret_manager_secret" AND protoPayload.serviceName="secretmanager.googleapis.com"' --limit=50
```

**Important Notes:**
- **Terraform-managed secrets** (`db-password-*`, `jwt-secret-*`, `redis-auth-*`) are excluded from backups as they can be regenerated via Terraform
- **Operational secrets** include API keys, OAuth configs, SSL certificates, and manually configured values
- The `seed-secrets.sh` script does not modify Terraform-managed secrets to prevent configuration conflicts
- All backup operations create encrypted files safe for off-site storage
- Use Cloud Audit Logs to monitor secret access patterns and detect unauthorized usage

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

## Managing Deployment Drift

### Infrastructure vs. Application Deployment

The Viatra platform uses a **Terraform-first deployment model**:
- **Terraform manages**: All infrastructure configuration (CPU, memory, scaling, VPC, env vars, IAM policies, authentication settings, service definitions)
- **CI/CD manages**: Only application images and traffic routing (no authentication flags or infrastructure config)

### Cloud Run Configuration Management

**Ownership Model**: Terraform owns all runtime configuration to maintain declarative infrastructure.

**Solution**: The Cloud Run service uses `lifecycle.ignore_changes` to ignore only image and traffic updates:

```hcl
lifecycle {
  ignore_changes = [
    template[0].spec[0].containers[0].image,  # CI/CD manages the image
    traffic[0].latest_revision                # CI/CD manages traffic
  ]
}
```

### When to Use Each Method

**Use `terraform apply` for:**
- Environment variables (NODE_ENV, ENVIRONMENT, GCP_PROJECT_ID, etc.)
- Secret Manager integration 
- Scaling configuration (min/max instances) 
- VPC or networking changes
- CPU and memory limits
- Concurrency settings
- Any infrastructure configuration

**Use Cloud Build/CI/CD for:**
- Container image updates only
- Traffic routing between revisions

> **Important**: The Cloud Build deployment step (`cloudbuild.yaml` Step 6) deliberately omits all infrastructure flags including `--memory`, `--cpu`, `--vpc-connector`, `--allow-unauthenticated`, etc. These are managed exclusively by Terraform to prevent configuration drift. IAM policies and authentication settings are controlled by Terraform-managed `google_cloud_run_service_iam_binding` resources.

### Verifying No Configuration Drift

After a CI/CD build completes, verify Terraform maintains configuration ownership:
- IAM permissions and authentication policies
- Resource limits (CPU, memory)
- Environment variables and runtime configuration

**Use CI/CD (`git push`) for:**
- Application code deployments
- Container image updates  
- Version rollbacks
- Traffic management

### Validation Commands

```bash
# Verify no configuration drift after CI/CD build
terraform plan -var-file="terraform.tfvars"  # Should show no changes

# Verify Terraform-managed configuration remains intact
gcloud run services describe viatra-backend-${ENVIRONMENT} --region=${REGION} \
  --format="value(spec.template.spec.containerConcurrency,spec.template.spec.containers[0].resources.limits.memory)" 
# Should match Terraform values (e.g., 100, 512Mi)

# Check health
curl https://viatra-backend-${ENVIRONMENT}-uc.a.run.app/health
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
