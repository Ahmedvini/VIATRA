# Terraform Infrastructure Documentation

This directory contains the Terraform configuration for deploying the Viatra Health Platform infrastructure on Google Cloud Platform (GCP).

## Prerequisites

Before using these Terraform configurations, ensure you have:

1. **Terraform** installed (version 1.5 or later)
   ```bash
   # Install via package manager or download from https://terraform.io
   terraform version
   ```

2. **Google Cloud CLI** installed and configured
   ```bash
   # Install gcloud CLI
   curl https://sdk.cloud.google.com | bash
   exec -l $SHELL
   
   # Login and set project
   gcloud auth login
   gcloud auth application-default login
   gcloud config set project YOUR_PROJECT_ID
   ```

3. **Required GCP Permissions**
   Your user account or service account needs the following IAM roles:
   - Project Editor or Owner
   - Service Account Admin
   - Security Admin
   - Or a custom role with these permissions:
     - Cloud SQL Admin
     - Cloud Run Admin
     - Storage Admin
     - VPC Admin
     - Secret Manager Admin
     - Service Account Admin

4. **Terraform Backend Setup**
   Create a GCS bucket for storing Terraform state:
   ```bash
   gsutil mb gs://YOUR_PROJECT_ID-terraform-state
   gsutil versioning set on gs://YOUR_PROJECT_ID-terraform-state
   ```

## Configuration

1. **Copy the example variables file:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit terraform.tfvars with your project-specific values:**
   ```bash
   # Update the following variables
   project_id = "your-actual-project-id"
   region     = "us-central1"  # or your preferred region
   environment = "dev"         # dev, staging, or prod
   ```

3. **Configure the Terraform backend:**
   Edit the backend configuration in `main.tf` or provide it during init:
   ```bash
   terraform init -backend-config="bucket=YOUR_PROJECT_ID-terraform-state"
   ```

## Deployment Steps

### 1. Initialize Terraform
```bash
terraform init
```

### 2. Review the Plan
```bash
terraform plan
```

### 3. Apply the Configuration
```bash
terraform apply
```

### 4. Verify Deployment
```bash
# Check Cloud Run service
gcloud run services list

# Check Cloud SQL instance
gcloud sql instances list

# Check Redis instance
gcloud redis instances list --region=us-central1
```

## Infrastructure Components

The Terraform configuration creates the following resources:

### Core Services
- **Cloud SQL**: PostgreSQL 15 database with automated backups
- **Redis Memorystore**: In-memory cache for session storage
- **Cloud Storage**: Object storage for user uploads and assets
- **Cloud Run**: Serverless container platform for the backend API

### Networking
- **VPC Network**: Private network for secure communication
- **Subnet**: Regional subnet with secondary IP ranges
- **VPC Connector**: Allows Cloud Run to access VPC resources
- **Cloud NAT**: Outbound internet access for Cloud Run
- **Firewall Rules**: Security rules for network traffic

### Security
- **Service Accounts**: Dedicated accounts for Cloud Run and Cloud Build
- **IAM Roles**: Least-privilege access permissions
- **Secret Manager**: Secure storage for passwords and API keys

### CI/CD
- **Artifact Registry**: Container image repository
- **Service Accounts**: For Cloud Build automation
- **Cloud Build Triggers**: Terraform-managed triggers for main branch deployment and PR validation

## Cloud Build Triggers

The Terraform configuration automatically creates and manages Cloud Build triggers for CI/CD automation:

### Managed Triggers

1. **Main Branch Trigger** (`main_branch`)
   - Automatically deploys to the target environment when code is pushed to main branch
   - Uses `cloudbuild.yaml` configuration file
   - Requires approval for production deployments
   - Outputs: `cloud_build_trigger_main_id`, `cloud_build_trigger_main_name`

2. **Pull Request Trigger** (`pull_request`)
   - Runs validation builds (lint, test) on pull requests targeting main branch
   - Does not deploy - validation only
   - Provides fast feedback on code quality
   - Outputs: `cloud_build_trigger_pr_id`, `cloud_build_trigger_pr_name`

### Configuration

Triggers are configured via Terraform variables:
- `github_owner`: GitHub repository owner/organization
- `github_repo`: GitHub repository name  
- `environment`: Target deployment environment
- `region`: GCP region for trigger execution
- `enable_cloudbuild_triggers`: Boolean flag to enable/disable Terraform management (default: true)

### Manual Management

If you need to manage triggers manually instead of via Terraform:
1. Set `enable_cloudbuild_triggers = false` in your `terraform.tfvars`
2. The trigger outputs will automatically become inert (return null values)
3. Create triggers via GCP Console or gcloud CLI
4. No manual editing of outputs is required - they handle the disabled state automatically

## Environment-Specific Configurations

### Development
- Minimal resource allocation for cost optimization
- Single-zone deployments
- Relaxed security settings for easier development

### Staging
- Production-like configuration with reduced capacity
- Regional deployments for reliability testing
- Moderate security settings

### Production
- High availability and performance configurations
- Regional deployments with backups
- Strict security and monitoring settings

## Managing Multiple Environments

Use Terraform workspaces or separate directories:

```bash
# Using workspaces
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod

# Switch between environments
terraform workspace select prod
terraform plan -var-file="prod.tfvars"
terraform apply -var-file="prod.tfvars"
```

## Outputs

After successful deployment, Terraform outputs important information:

```bash
# View all outputs
terraform output

# View specific output
terraform output cloud_run_service_url
terraform output db_instance_connection_name
```

## Maintenance

### Updating Infrastructure
1. Modify the Terraform files as needed
2. Run `terraform plan` to review changes
3. Run `terraform apply` to apply changes

### Backing Up State
```bash
# Download current state
terraform state pull > terraform.tfstate.backup

# List all resources
terraform state list
```

### Destroying Resources
```bash
# Destroy all resources (be careful!)
terraform destroy

# Destroy specific resources
terraform destroy -target=resource_type.resource_name
```

## Troubleshooting

### Common Issues

1. **Authentication Errors**
   ```bash
   gcloud auth application-default login
   export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account-key.json
   ```

2. **API Not Enabled**
   ```bash
   gcloud services enable cloudbuild.googleapis.com
   gcloud services enable run.googleapis.com
   ```

3. **Quota Limits**
   - Check your GCP quotas in the console
   - Request quota increases if needed

4. **State Lock Issues**
   ```bash
   terraform force-unlock LOCK_ID
   ```

5. **Resource Already Exists**
   ```bash
   terraform import resource_type.resource_name existing_resource_id
   ```

### Getting Help

- Check Terraform logs: `export TF_LOG=DEBUG`
- Validate configuration: `terraform validate`
- Format code: `terraform fmt`
- Check syntax: `terraform plan`

## Security Considerations

- Never commit `terraform.tfvars` with sensitive data
- Use least-privilege IAM roles
- Enable audit logging for all resources
- Regularly rotate secrets and service account keys
- Monitor resource usage and costs

## Cost Optimization

- Use appropriate machine types for each environment
- Enable autoscaling with proper min/max limits
- Set up budget alerts in GCP Console
- Review and cleanup unused resources regularly
