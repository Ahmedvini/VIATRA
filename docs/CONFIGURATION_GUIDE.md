# VIATRA Health Platform Configuration Guide

This comprehensive guide covers all configuration requirements for the VIATRA Health Platform across all components: backend, mobile app, infrastructure, Docker, CI/CD, and deployment scripts.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Backend Configuration](#backend-configuration)
3. [Mobile App Configuration](#mobile-app-configuration)
4. [Infrastructure Configuration (Terraform)](#infrastructure-configuration)
5. [Docker Configuration](#docker-configuration)
6. [CI/CD Configuration](#cicd-configuration)
7. [Scripts Configuration](#scripts-configuration)
8. [Environment-Specific Setup](#environment-specific-setup)
9. [Security Best Practices](#security-best-practices)
10. [Troubleshooting](#troubleshooting)

---

## Quick Start

### Prerequisites

- **Node.js**: v20.x or higher
- **Flutter**: v3.16.0 or higher
- **Docker & Docker Compose**: Latest stable version
- **Terraform**: v1.5.0 or higher
- **GCP Account**: With billing enabled (for production)
- **Git**: Latest version

### Initial Setup Commands

```bash
# 1. Clone the repository
git clone https://github.com/your-org/VIATRA.git
cd VIATRA

# 2. Run the setup script
chmod +x scripts/setup.sh
./scripts/setup.sh

# 3. Configure environment files (see sections below)
cp backend/.env.example backend/.env
cp mobile/.env.example mobile/.env
cp terraform/terraform.tfvars.example terraform/terraform.tfvars

# 4. Start Docker services (for local development)
docker-compose up -d

# 5. Initialize backend database
cd backend
npm install
npx sequelize-cli db:migrate
npx sequelize-cli db:seed:all

# 6. Run backend
npm run dev

# 7. In a new terminal, run mobile app
cd mobile
flutter pub get
flutter run
```

---

## Backend Configuration

### 1. Environment Variables (`backend/.env`)

Copy `backend/.env.example` to `backend/.env` and configure:

#### Required for All Environments

```bash
# Node.js Environment
NODE_ENV=development           # Options: development, staging, production
PORT=8080                      # Backend server port

# Database Configuration (Choose ONE approach)
# Approach 1: Single URL (recommended for production)
DATABASE_URL=postgresql://username:password@host:5432/database_name

# Approach 2: Discrete configuration (recommended for development)
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_NAME=viatra_dev
DATABASE_USER=postgres
DATABASE_PASSWORD=your_secure_password

# Redis Configuration
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_AUTH=your_redis_password
REDIS_DATABASE=0

# Authentication & Security
JWT_SECRET=your-very-long-and-secure-jwt-secret-key-at-least-32-characters-long
JWT_EXPIRES_IN=7d
BCRYPT_ROUNDS=12
SESSION_SECRET=your-session-secret-key-at-least-32-characters
```

#### Required for Production

```bash
# GCP Configuration
GCP_PROJECT_ID=your-gcp-project-id
GCS_BUCKET_NAME=your-storage-bucket-name
USE_GCP_SECRETS=true           # Enable GCP Secret Manager

# Production Database (managed by Cloud SQL)
DATABASE_URL=postgresql://user:password@/database?host=/cloudsql/project:region:instance

# CORS Configuration
CORS_ORIGIN=https://yourdomain.com,https://www.yourdomain.com
```

#### Third-Party Services (Development Only)

**Note**: In production, these are automatically loaded from GCP Secret Manager.

```bash
# Stripe (Payment Processing)
STRIPE_API_KEY=sk_test_your_stripe_key

# Twilio (SMS/Phone Verification)
TWILIO_ACCOUNT_SID=your_twilio_account_sid
TWILIO_AUTH_TOKEN=your_twilio_auth_token

# SendGrid (Email Service)
SENDGRID_API_KEY=SG.your_sendgrid_api_key

# Firebase (Push Notifications)
FIREBASE_API_KEY=your_firebase_api_key
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_PRIVATE_KEY_PATH=./config/firebase-service-account.json
FIREBASE_CLIENT_EMAIL=firebase-adminsdk@your-project.iam.gserviceaccount.com
```

#### OAuth Configuration (Development Only)

```bash
# Google OAuth
GOOGLE_CLIENT_ID=your_google_client_id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your_google_client_secret

# Apple OAuth
APPLE_CLIENT_ID=com.viatra.health
APPLE_CLIENT_SECRET=your_apple_client_secret

# Facebook OAuth
FACEBOOK_APP_ID=your_facebook_app_id
FACEBOOK_APP_SECRET=your_facebook_app_secret
```

#### Email Configuration

```bash
# SMTP Configuration
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your_email@gmail.com
SMTP_PASS=your_app_specific_password

# Email Settings
EMAIL_FROM=noreply@viatra.health
EMAIL_FROM_NAME=Viatra Health
EMAIL_REPLY_TO=support@viatra.health
VERIFICATION_CODE_EXPIRY=86400000    # 24 hours in milliseconds
RESET_TOKEN_EXPIRY=3600000           # 1 hour in milliseconds
FRONTEND_URL=https://viatra.health
```

#### Feature Flags

```bash
ENABLE_REGISTRATION=true
ENABLE_EMAIL_VERIFICATION=true
ENABLE_SMS_VERIFICATION=false
ENABLE_SOCIAL_LOGIN=true
```

#### Development Settings

```bash
LOG_LEVEL=debug                # Options: error, warn, info, debug
DEBUG=true
MOCK_EXTERNAL_APIS=true        # Mock Stripe, Twilio, etc. for testing
```

#### Socket.io Configuration

```bash
SOCKET_IO_CORS_ORIGIN=http://localhost:3000,http://localhost:8080
SOCKET_IO_PING_TIMEOUT=60000
SOCKET_IO_PING_INTERVAL=25000
```

#### Chat Configuration

```bash
CHAT_MESSAGE_MAX_LENGTH=5000
CHAT_CONVERSATION_PAGE_SIZE=20
CHAT_MESSAGE_PAGE_SIZE=50
```

---

### 2. Sequelize Configuration

The backend uses **ES modules** for the main application and **CommonJS** for the Sequelize CLI.

- **`backend/src/config/database.config.js`**: Pure ESM, used by the application
- **`backend/src/config/database.config.cjs`**: Pure CJS, used by `sequelize-cli`
- **`backend/.sequelizerc`**: Points to the `.cjs` file for CLI operations

**No manual configuration needed** - these files are already set up to use environment variables from `.env`.

---

### 3. Firebase Service Account

For push notifications, you need a Firebase service account JSON file:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Project Settings** → **Service Accounts**
4. Click **Generate New Private Key**
5. Save the JSON file to `backend/src/config/firebase-service-account.json`
6. Or set `FIREBASE_PRIVATE_KEY` environment variable with the full key content

**Important**: Add this file to `.gitignore` (already configured).

---

## Mobile App Configuration

### 1. Environment Variables (`mobile/.env`)

Copy `mobile/.env.example` to `mobile/.env` and configure:

#### Required for All Environments

```bash
# API Configuration
API_BASE_URL=http://localhost:8080/api/v1    # Development
# API_BASE_URL=https://api.viatra.health/api/v1  # Production

WS_BASE_URL=ws://localhost:8080              # Development
# WS_BASE_URL=wss://api.viatra.health         # Production

# Environment
ENVIRONMENT=development           # Options: development, staging, production
```

#### Features

```bash
ENABLE_LOGGING=true               # Enable debug logging
ENABLE_CRASHLYTICS=false          # Enable Firebase Crashlytics (production only)
ENABLE_ANALYTICS=false            # Enable analytics (production only)
```

#### Firebase Configuration

```bash
FIREBASE_API_KEY=your_firebase_api_key
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_MESSAGING_SENDER_ID=your_fcm_sender_id
FIREBASE_APP_ID=your_firebase_app_id
```

#### Push Notifications

```bash
FCM_SENDER_ID=your_fcm_sender_id
APNS_TEAM_ID=your_apns_team_id    # iOS only
```

#### Deep Links

```bash
CUSTOM_URL_SCHEME=viatra
UNIVERSAL_LINK_DOMAIN=viatra.health
```

#### File Upload

```bash
MAX_FILE_SIZE_MB=10
ALLOWED_IMAGE_TYPES=jpg,jpeg,png,gif
ALLOWED_DOCUMENT_TYPES=pdf,doc,docx
```

#### UI Configuration

```bash
DEFAULT_LOCALE=en
SUPPORTED_LOCALES=en,ar
THEME_MODE=system                 # Options: light, dark, system
PRIMARY_COLOR=0xFF2196F3
ACCENT_COLOR=0xFF03DAC6
```

#### Development Settings

```bash
MOCK_API_ENABLED=false
SLOW_ANIMATIONS=false
SHOW_PERFORMANCE_OVERLAY=false
```

---

### 2. Firebase Setup (iOS & Android)

#### Android

1. Download `google-services.json` from Firebase Console
2. Place it in `mobile/android/app/google-services.json`
3. Ensure `mobile/android/build.gradle` includes:
   ```gradle
   classpath 'com.google.gms:google-services:4.3.15'
   ```
4. Ensure `mobile/android/app/build.gradle` includes:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

#### iOS

1. Download `GoogleService-Info.plist` from Firebase Console
2. Place it in `mobile/ios/Runner/GoogleService-Info.plist`
3. Open `mobile/ios/Runner.xcworkspace` in Xcode
4. Drag `GoogleService-Info.plist` into the project (ensure "Copy items if needed" is checked)
5. Configure push notifications:
   - Enable "Push Notifications" capability
   - Enable "Background Modes" → "Remote notifications"

---

### 3. Platform-Specific Configuration

#### iOS (`mobile/ios/Runner/Info.plist`)

```xml
<!-- URL Schemes for Deep Links -->
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>viatra</string>
    </array>
  </dict>
</array>

<!-- Universal Links -->
<key>com.apple.developer.associated-domains</key>
<array>
  <string>applinks:viatra.health</string>
</array>
```

#### Android (`mobile/android/app/src/main/AndroidManifest.xml`)

```xml
<!-- Deep Links -->
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="viatra" />
</intent-filter>

<!-- Universal Links -->
<intent-filter android:autoVerify="true">
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="https" android:host="viatra.health" />
</intent-filter>
```

---

### 4. Google Maps Setup

#### Android

1. Get API key from [Google Cloud Console](https://console.cloud.google.com/)
2. Add to `mobile/android/app/src/main/AndroidManifest.xml`:
   ```xml
   <meta-data
     android:name="com.google.android.geo.API_KEY"
     android:value="YOUR_API_KEY" />
   ```

#### iOS

1. Add to `mobile/ios/Runner/AppDelegate.swift`:
   ```swift
   GMSServices.provideAPIKey("YOUR_API_KEY")
   ```

---

## Infrastructure Configuration

### 1. Terraform Variables (`terraform/terraform.tfvars`)

Copy `terraform/terraform.tfvars.example` to `terraform/terraform.tfvars` and configure:

#### GCP Project Configuration

```hcl
project_id  = "viatra-health-platform"  # Your GCP project ID
region      = "us-central1"              # Your preferred region
environment = "dev"                      # Options: dev, staging, prod
```

#### Database Configuration

```hcl
db_instance_name = "viatra-db"
db_tier         = "db-f1-micro"         # Dev: db-f1-micro, Prod: db-n1-standard-2+
```

#### Redis Configuration

```hcl
redis_memory_size_gb = 1                # Dev: 1, Staging: 2, Prod: 8+
```

#### Storage Configuration

```hcl
storage_bucket_name = "viatra-storage"  # Must be globally unique
```

#### Cloud Run Configuration

```hcl
cloud_run_service_name  = "viatra-backend"
cloud_run_cpu           = "1000m"        # 1 vCPU (Prod: 2000m)
cloud_run_memory        = "512Mi"        # 512MB (Prod: 1Gi+)
cloud_run_max_instances = 10             # Max autoscaling (Prod: 20+)
cloud_run_min_instances = 0              # Min instances (Prod: 2+)
```

#### Network Configuration

```hcl
vpc_name           = "viatra-vpc"
subnet_name        = "viatra-subnet"
vpc_connector_name = "viatra-connector"
```

#### Resource Labels

```hcl
labels = {
  project     = "viatra-health"
  managed-by  = "terraform"
  team        = "platform"
  cost-center = "engineering"
}
```

#### CI/CD Configuration

```hcl
github_owner  = "your-github-username"   # Your GitHub username/org
github_repo   = "VIATRA"                 # Your repository name
region_suffix = "uc"                     # Short suffix for region
```

---

### 2. GCP Secret Manager Setup

Before running Terraform, set up secrets manually or use the provided scripts:

#### Using the Seed Script

```bash
cd scripts
chmod +x seed-secrets.sh
./seed-secrets.sh --project=viatra-health-platform --environment=dev
```

#### Manual Setup

```bash
# Database password
echo -n "your_db_password" | gcloud secrets create database-password-dev \
  --data-file=- --project=viatra-health-platform

# Redis auth
echo -n "your_redis_password" | gcloud secrets create redis-auth-dev \
  --data-file=- --project=viatra-health-platform

# JWT secret
echo -n "your_jwt_secret_very_long_and_secure" | gcloud secrets create jwt-secret-dev \
  --data-file=- --project=viatra-health-platform

# API keys (JSON format)
echo '{"stripe":"sk_live_...","twilio":"...","sendgrid":"..."}' | \
  gcloud secrets create api-keys-dev --data-file=- --project=viatra-health-platform

# OAuth config (JSON format)
echo '{"google":{"clientId":"...","clientSecret":"..."},"apple":{...}}' | \
  gcloud secrets create oauth-config-dev --data-file=- --project=viatra-health-platform

# App config (JSON format)
echo '{"rateLimitMax":100,"rateLimitWindow":900000,"fileUploadMaxSize":10485760}' | \
  gcloud secrets create app-config-dev --data-file=- --project=viatra-health-platform
```

---

### 3. Terraform Deployment

```bash
cd terraform

# Initialize Terraform
terraform init

# Plan changes
terraform plan -var-file=terraform.tfvars

# Apply changes
terraform apply -var-file=terraform.tfvars

# View outputs
terraform output
```

---

## Docker Configuration

### 1. Docker Compose (`docker-compose.yml`)

The provided `docker-compose.yml` is pre-configured for local development. Key services:

- **PostgreSQL**: Port 5432
- **Redis**: Port 6379
- **Backend API**: Port 8080
- **pgAdmin**: Port 5050 (Database UI)
- **Redis Commander**: Port 8081 (Redis UI)
- **Nginx**: Ports 80/443 (Reverse proxy)

#### Default Credentials

**PostgreSQL**:
- Database: `viatra_dev`
- User: `viatra_app`
- Password: `dev_password_123`

**Redis**:
- Password: `dev_redis_password`

**pgAdmin** (http://localhost:5050):
- Email: `admin@viatra.local`
- Password: `admin123`

**Redis Commander** (http://localhost:8081):
- Username: `admin`
- Password: `admin123`

---

### 2. Starting Docker Services

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down

# Stop and remove volumes (data reset)
docker-compose down -v
```

---

### 3. Docker Volumes

Data is persisted in local directories:

- `./docker/volumes/postgres` - PostgreSQL data
- `./docker/volumes/redis` - Redis data
- `./docker/volumes/pgadmin` - pgAdmin settings

Create these directories before starting:

```bash
mkdir -p docker/volumes/postgres docker/volumes/redis docker/volumes/pgadmin
```

---

### 4. Nginx Configuration

Nginx configuration files are in `docker/nginx/`:

- `nginx.conf` - Main configuration
- `conf.d/*.conf` - Virtual host configurations
- `ssl/` - SSL certificates (for HTTPS)

For local HTTPS development, generate self-signed certificates:

```bash
mkdir -p docker/nginx/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout docker/nginx/ssl/nginx.key \
  -out docker/nginx/ssl/nginx.crt \
  -subj "/CN=localhost"
```

---

## CI/CD Configuration

### 1. GitHub Actions

Configuration files in `.github/workflows/`:

- `ci.yml` - Continuous Integration (tests, linting)
- `cd-staging.yml` - Staging deployment
- `cd-production.yml` - Production deployment

#### Required GitHub Secrets

Navigate to **Settings** → **Secrets and variables** → **Actions** and add:

**GCP Authentication**:
```
GCP_PROJECT_ID          # Your GCP project ID
GCP_SERVICE_ACCOUNT     # Service account JSON key
GCP_WORKLOAD_IDENTITY   # Workload identity provider (recommended)
```

**Firebase**:
```
FIREBASE_PROJECT_ID
FIREBASE_TOKEN          # From: firebase login:ci
```

**Mobile App Signing**:
```
ANDROID_KEYSTORE_BASE64     # Base64-encoded keystore
ANDROID_KEYSTORE_PASSWORD
ANDROID_KEY_ALIAS
ANDROID_KEY_PASSWORD

IOS_CERTIFICATE_BASE64      # Base64-encoded certificate
IOS_CERTIFICATE_PASSWORD
IOS_PROVISIONING_PROFILE
```

**API Keys**:
```
SLACK_WEBHOOK_URL       # For deployment notifications
SENTRY_DSN              # Error monitoring
```

---

### 2. Cloud Build

Configuration in `cloudbuild.yaml` for GCP Cloud Build deployments.

#### Setup

1. Enable Cloud Build API
2. Grant Cloud Build service account permissions:
   ```bash
   gcloud projects add-iam-policy-binding viatra-health-platform \
     --member=serviceAccount:PROJECT_NUMBER@cloudbuild.gserviceaccount.com \
     --role=roles/run.admin
   
   gcloud projects add-iam-policy-binding viatra-health-platform \
     --member=serviceAccount:PROJECT_NUMBER@cloudbuild.gserviceaccount.com \
     --role=roles/iam.serviceAccountUser
   ```

3. Connect GitHub repository:
   ```bash
   gcloud builds triggers create github \
     --repo-name=VIATRA \
     --repo-owner=your-github-username \
     --branch-pattern=^main$ \
     --build-config=cloudbuild.yaml
   ```

---

## Scripts Configuration

### 1. Setup Script (`scripts/setup.sh`)

Initializes the entire project for local development.

**Usage**:
```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

**What it does**:
- Checks prerequisites (Node.js, Flutter, Docker, etc.)
- Creates `.env` files from examples
- Installs backend dependencies
- Installs mobile dependencies
- Sets up Docker volumes
- Runs database migrations
- Seeds test data

---

### 2. Seed Secrets Script (`scripts/seed-secrets.sh`)

Seeds GCP Secret Manager with required secrets for deployment.

**Usage**:
```bash
chmod +x scripts/seed-secrets.sh
./scripts/seed-secrets.sh --project=PROJECT_ID --environment=ENV
```

**Options**:
- `--project`: GCP project ID (required)
- `--environment`: Environment name - dev/staging/prod (required)
- `--dry-run`: Preview changes without applying

**Example**:
```bash
./scripts/seed-secrets.sh \
  --project=viatra-health-platform \
  --environment=dev
```

---

### 3. Backup Secrets Script (`scripts/backup-secrets.sh`)

Backs up GCP Secret Manager secrets to a local encrypted file.

**Usage**:
```bash
chmod +x scripts/backup-secrets.sh
./scripts/backup-secrets.sh --project=PROJECT_ID --environment=ENV --output=FILE
```

**Options**:
- `--project`: GCP project ID (required)
- `--environment`: Environment name (required)
- `--output`: Output file path (default: `secrets-backup-ENV-DATE.json.enc`)

**Restore**:
```bash
# Decrypt backup
openssl enc -d -aes-256-cbc -in backup.json.enc -out backup.json

# Restore secrets
./scripts/seed-secrets.sh --project=PROJECT_ID --environment=ENV --input=backup.json
```

---

### 4. Deploy Script (`scripts/deploy.sh`)

Deploys the backend to Google Cloud Run.

**Usage**:
```bash
chmod +x scripts/deploy.sh
./scripts/deploy.sh --environment=ENV [OPTIONS]
```

**Options**:
- `--environment`: Target environment - dev/staging/prod (required)
- `--project`: GCP project ID (optional, reads from terraform.tfvars)
- `--region`: GCP region (optional, default: us-central1)
- `--skip-tests`: Skip running tests before deployment
- `--skip-build`: Use existing Docker image

**Example**:
```bash
# Development deployment
./scripts/deploy.sh --environment=dev

# Production deployment with all checks
./scripts/deploy.sh --environment=prod --project=viatra-health-platform
```

---

## Environment-Specific Setup

### Development Environment

**Focus**: Local development with Docker, hot-reloading, debug logging.

**Configuration**:

1. **Backend** (`backend/.env`):
   ```bash
   NODE_ENV=development
   DATABASE_URL=postgresql://viatra_app:dev_password_123@localhost:5432/viatra_dev
   REDIS_HOST=localhost
   REDIS_AUTH=dev_redis_password
   JWT_SECRET=dev_jwt_secret_very_long_and_secure_for_local_development_only
   LOG_LEVEL=debug
   DEBUG=true
   MOCK_EXTERNAL_APIS=true
   CORS_ORIGIN=http://localhost:3000,http://localhost:8080
   ```

2. **Mobile** (`mobile/.env`):
   ```bash
   ENVIRONMENT=development
   API_BASE_URL=http://localhost:8080/api/v1
   WS_BASE_URL=ws://localhost:8080
   ENABLE_LOGGING=true
   MOCK_API_ENABLED=false
   ```

3. **Start Services**:
   ```bash
   docker-compose up -d
   cd backend && npm run dev
   cd mobile && flutter run
   ```

---

### Staging Environment

**Focus**: Pre-production testing, similar to production but isolated.

**Configuration**:

1. **Terraform** (`terraform/terraform.tfvars`):
   ```hcl
   environment              = "staging"
   db_tier                 = "db-g1-small"
   redis_memory_size_gb    = 2
   cloud_run_min_instances = 1
   cloud_run_max_instances = 8
   ```

2. **Deploy**:
   ```bash
   # Infrastructure
   cd terraform
   terraform apply -var-file=terraform.tfvars

   # Backend
   cd scripts
   ./deploy.sh --environment=staging

   # Mobile (build and upload to TestFlight/Internal Testing)
   cd mobile
   flutter build ios --release --flavor staging
   flutter build appbundle --release --flavor staging
   ```

3. **Backend runs on Cloud Run** - no local `.env` needed (uses Secret Manager)

4. **Mobile** (`mobile/.env.staging`):
   ```bash
   ENVIRONMENT=staging
   API_BASE_URL=https://staging-api.viatra.health/api/v1
   WS_BASE_URL=wss://staging-api.viatra.health
   ENABLE_CRASHLYTICS=true
   ENABLE_ANALYTICS=false
   ```

---

### Production Environment

**Focus**: High availability, security, monitoring, backups.

**Configuration**:

1. **Terraform** (`terraform/terraform.tfvars`):
   ```hcl
   environment              = "prod"
   db_tier                 = "db-n1-standard-2"
   redis_memory_size_gb    = 8
   cloud_run_cpu           = "2000m"
   cloud_run_memory        = "1Gi"
   cloud_run_min_instances = 2
   cloud_run_max_instances = 20
   ```

2. **GCP Secret Manager** - All sensitive values (see "GCP Secret Manager Setup")

3. **Deploy**:
   ```bash
   # Infrastructure
   cd terraform
   terraform apply -var-file=terraform.tfvars

   # Backend
   cd scripts
   ./deploy.sh --environment=prod

   # Mobile (build and upload to App Store/Google Play)
   cd mobile
   flutter build ios --release
   flutter build appbundle --release
   ```

4. **Backend runs on Cloud Run** - uses Secret Manager for all secrets

5. **Mobile** (`mobile/.env.production`):
   ```bash
   ENVIRONMENT=production
   API_BASE_URL=https://api.viatra.health/api/v1
   WS_BASE_URL=wss://api.viatra.health
   ENABLE_CRASHLYTICS=true
   ENABLE_ANALYTICS=true
   CERTIFICATE_PINNING_ENABLED=true
   ROOT_DETECTION_ENABLED=true
   ```

6. **Monitoring**:
   - Enable Cloud Monitoring alerts
   - Configure error reporting (Sentry)
   - Set up uptime checks
   - Configure log aggregation

---

## Security Best Practices

### 1. Secret Management

**Never commit secrets to Git**:
- Use `.env` files for local development only
- Add `.env` to `.gitignore` (already configured)
- Use GCP Secret Manager for staging/production
- Rotate secrets regularly (quarterly minimum)

**Secret Rotation**:
```bash
# Rotate JWT secret
gcloud secrets versions add jwt-secret-prod --data-file=<(openssl rand -base64 64)

# Update Cloud Run to use new version (automatic with "latest")
```

---

### 2. Database Security

**Development**:
- Use weak passwords (already in docker-compose.yml)
- Allow connections from localhost only

**Production**:
- Use Cloud SQL with private IP
- Enable Cloud SQL Proxy for admin access
- Use strong passwords (generate with: `openssl rand -base64 32`)
- Enable automated backups (configured in Terraform)
- Enable audit logging

---

### 3. API Security

**Rate Limiting**:
- Configured in backend via `app-config` secret
- Default: 100 requests per 15 minutes per IP
- Adjust in GCP Secret Manager for production

**CORS**:
- Restrict to known domains in production
- Never use `*` in production

**Authentication**:
- Use JWT with secure secrets
- Set short expiration times (7 days max)
- Implement refresh tokens for mobile apps

---

### 4. Mobile App Security

**Certificate Pinning** (Production):
```bash
# Enable in mobile/.env
CERTIFICATE_PINNING_ENABLED=true
```

**Root Detection** (Production):
```bash
ROOT_DETECTION_ENABLED=true
```

**Obfuscation** (Production builds):
```bash
flutter build apk --obfuscate --split-debug-info=./debug-info
flutter build ios --obfuscate --split-debug-info=./debug-info
```

---

### 5. Infrastructure Security

**IAM Best Practices**:
- Use principle of least privilege
- Create service accounts for each service
- Avoid using owner/editor roles
- Audit IAM changes regularly

**Network Security**:
- Use VPC for private networking
- Enable Cloud Armor for DDoS protection
- Use HTTPS everywhere (enforce in Cloud Run)
- Configure firewall rules (restrict to Cloud Run only)

---

## Troubleshooting

### Common Issues

#### 1. Backend Won't Start

**Error**: `Error: connect ECONNREFUSED 127.0.0.1:5432`

**Solution**:
```bash
# Check if PostgreSQL is running
docker ps | grep postgres

# If not, start Docker services
docker-compose up -d postgres

# Check PostgreSQL logs
docker-compose logs postgres
```

---

#### 2. Database Connection Issues

**Error**: `SequelizeConnectionError: password authentication failed`

**Solution**:
```bash
# Verify credentials in .env match docker-compose.yml
cat backend/.env | grep DATABASE
cat docker-compose.yml | grep POSTGRES

# Reset database
docker-compose down -v
docker-compose up -d postgres
cd backend && npx sequelize-cli db:migrate
```

---

#### 3. Mobile App Can't Connect to Backend

**Error**: `SocketException: Failed host lookup: 'localhost'`

**Solution**:
- Android emulator: Use `http://10.0.2.2:8080` instead of `localhost`
- iOS simulator: Use `http://localhost:8080` or `http://127.0.0.1:8080`
- Physical device: Use your computer's local IP (e.g., `http://192.168.1.100:8080`)

```bash
# Find your local IP
# macOS/Linux:
ifconfig | grep "inet " | grep -v 127.0.0.1

# Update mobile/.env
API_BASE_URL=http://YOUR_LOCAL_IP:8080/api/v1
```

---

#### 4. Terraform Apply Fails

**Error**: `Error creating CloudSQL instance: googleapi: Error 409: already exists`

**Solution**:
```bash
# Import existing resource
terraform import google_sql_database_instance.main PROJECT_ID:INSTANCE_NAME

# Or destroy and recreate (WARNING: data loss)
terraform destroy
terraform apply
```

---

#### 5. Cloud Run Deployment Fails

**Error**: `ERROR: (gcloud.run.deploy) PERMISSION_DENIED`

**Solution**:
```bash
# Grant necessary permissions
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member=user:YOUR_EMAIL \
  --role=roles/run.admin

# Or use a service account
gcloud auth activate-service-account --key-file=service-account.json
```

---

#### 6. Firebase Push Notifications Not Working

**iOS**:
1. Verify APNs certificate is valid
2. Check provisioning profile includes Push Notifications
3. Verify `GoogleService-Info.plist` is in Xcode project
4. Enable "Push Notifications" and "Background Modes" capabilities

**Android**:
1. Verify `google-services.json` is in `android/app/`
2. Check Firebase Cloud Messaging API is enabled
3. Verify app package name matches Firebase project

---

#### 7. Secrets Not Loading in Production

**Error**: `Error: Required environment variable JWT_SECRET is not set`

**Solution**:
```bash
# Verify secrets exist
gcloud secrets list --project=PROJECT_ID | grep ENVIRONMENT

# Check Cloud Run has secret access
gcloud run services describe viatra-backend-ENVIRONMENT \
  --region=REGION \
  --format="yaml(spec.template.spec.containers[0].env)"

# Grant Cloud Run service account access
gcloud secrets add-iam-policy-binding SECRET_NAME \
  --member=serviceAccount:SERVICE_ACCOUNT_EMAIL \
  --role=roles/secretmanager.secretAccessor
```

---

### Getting Help

1. **Check logs**:
   ```bash
   # Backend logs (Docker)
   docker-compose logs -f backend

   # Backend logs (Cloud Run)
   gcloud run services logs tail viatra-backend-ENV --project=PROJECT_ID

   # Mobile logs
   flutter logs
   ```

2. **Enable debug mode**:
   - Backend: Set `LOG_LEVEL=debug` and `DEBUG=true`
   - Mobile: Set `ENABLE_LOGGING=true`

3. **Contact support**:
   - Email: support@viatra.health
   - Slack: #viatra-platform
   - GitHub Issues: https://github.com/your-org/VIATRA/issues

---

## Checklist: Production Deployment

Use this checklist before deploying to production:

### Infrastructure
- [ ] GCP project created with billing enabled
- [ ] Terraform variables configured in `terraform/terraform.tfvars`
- [ ] All GCP secrets created in Secret Manager
- [ ] Terraform applied successfully
- [ ] Cloud SQL instance healthy and backed up
- [ ] Redis instance healthy
- [ ] Cloud Storage bucket created
- [ ] VPC and networking configured

### Backend
- [ ] All required secrets in GCP Secret Manager
- [ ] Database migrations run successfully
- [ ] Cloud Run service deployed and healthy
- [ ] Health check endpoint responding
- [ ] CORS configured for production domains
- [ ] Rate limiting configured
- [ ] Error monitoring enabled (Sentry)
- [ ] Log aggregation enabled
- [ ] Uptime checks configured
- [ ] Alerts configured (CPU, memory, errors)

### Mobile
- [ ] Firebase projects created (iOS & Android)
- [ ] Push notification certificates configured
- [ ] OAuth credentials configured
- [ ] Production API URLs set
- [ ] Obfuscation enabled
- [ ] Certificate pinning enabled
- [ ] Crashlytics enabled
- [ ] Analytics enabled
- [ ] App signed with production certificates
- [ ] Apps uploaded to App Store / Google Play

### Security
- [ ] All secrets rotated from defaults
- [ ] Strong passwords for databases
- [ ] JWT secret is long and random
- [ ] HTTPS enforced everywhere
- [ ] IAM permissions reviewed
- [ ] Security audit completed

### Testing
- [ ] All unit tests passing
- [ ] All integration tests passing
- [ ] End-to-end tests passing
- [ ] Load testing completed
- [ ] Security testing completed
- [ ] Staging environment validated

### Documentation
- [ ] Configuration guide reviewed
- [ ] Deployment guide reviewed
- [ ] API documentation updated
- [ ] Runbook created
- [ ] Disaster recovery plan documented

---

## Additional Resources

- **Main README**: [../README.md](../README.md)
- **Deployment Guide**: [./DEPLOYMENT.md](./DEPLOYMENT.md)
- **API Documentation**: [./API.md](./API.md)
- **Architecture Overview**: [./ARCHITECTURE.md](./ARCHITECTURE.md)
- **Backend README**: [../backend/README.md](../backend/README.md)
- **Mobile README**: [../mobile/README.md](../mobile/README.md)
- **Terraform README**: [../terraform/README.md](../terraform/README.md)

---

## Version History

- **v1.0.0** (2024-01-XX): Initial configuration guide
- **v1.1.0** (2024-XX-XX): Added mobile app configuration
- **v1.2.0** (2024-XX-XX): Added Terraform and GCP setup
- **v1.3.0** (2024-XX-XX): Added CI/CD and deployment scripts

---

**Last Updated**: 2024-01-XX  
**Maintained By**: Platform Team  
**Contact**: platform@viatra.health
