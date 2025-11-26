# Viatra Health Platform

A comprehensive digital health platform built with a modern tech stack, featuring a Node.js backend and Flutter mobile application, deployed on Google Cloud Platform.

## 📚 Documentation

**📖 [Complete Documentation Index](docs/DOCUMENTATION_INDEX.md)**

For comprehensive documentation including:
- 🚀 Getting Started Guides
- 🎯 Feature Documentation (Chat, Appointments, Health Profiles, etc.)
- 📱 Mobile Development
- 🔧 Backend API Reference
- 🏗️ Infrastructure & Deployment
- 🧪 Testing Guides
- ⚡ Quick References

---

## Overview

Viatra Health Platform is designed to provide secure, scalable healthcare services through a mobile-first approach. The platform consists of:

- **Backend API**: Node.js/Express server with PostgreSQL database
- **Mobile App**: Cross-platform Flutter application for iOS and Android
- **Cloud Infrastructure**: GCP services including Cloud Run, Cloud SQL, Redis Memorystore, and Cloud Storage

## Technology Stack

### Backend
- **Runtime**: Node.js 20+
- **Framework**: Express.js
- **Database**: PostgreSQL 15 (Cloud SQL)
- **Cache**: Redis 7 (Memorystore)
- **Storage**: Google Cloud Storage
- **Container**: Docker with Cloud Run deployment

### Mobile
- **Framework**: Flutter 3.x+
- **Language**: Dart
- **State Management**: Provider/Riverpod
- **Storage**: Secure Storage, Shared Preferences
- **Platform**: iOS and Android

### Infrastructure
- **Cloud Provider**: Google Cloud Platform (GCP)
- **Infrastructure as Code**: Terraform
- **CI/CD**: Google Cloud Build
- **Secrets Management**: Google Secret Manager
- **Monitoring**: Google Cloud Operations Suite

## Repository Structure

```
viatra-health-platform/
├── README.md                 # This file
├── package.json             # Monorepo configuration
├── docker-compose.yml       # Local development environment
├── cloudbuild.yaml         # CI/CD pipeline configuration
├── .gitignore              # Git ignore rules
├── .editorconfig           # Code style configuration
├── backend/                # Node.js API server
│   ├── src/                # Source code
│   ├── package.json        # Backend dependencies
│   ├── Dockerfile          # Container configuration
│   └── README.md           # Backend-specific documentation
├── mobile/                 # Flutter mobile application
│   ├── lib/                # Dart source code
│   ├── pubspec.yaml        # Flutter dependencies
│   └── README.md           # Mobile-specific documentation
├── terraform/              # Infrastructure as Code
│   ├── main.tf             # Main Terraform configuration
│   ├── variables.tf        # Variable definitions
│   └── README.md           # Infrastructure documentation
├── scripts/               # Utility scripts
│   ├── setup.sh           # Initial project setup
│   └── deploy.sh          # Manual deployment helper
└── docs/                  # Project documentation
    ├── ARCHITECTURE.md    # System architecture
    ├── DEPLOYMENT.md      # Deployment guide
    └── DEVELOPMENT.md     # Development guide
```

## Prerequisites

Before setting up the project, ensure you have the following installed:

- **Node.js** 20+ and npm
- **Flutter SDK** 3.x+
- **Google Cloud CLI** (gcloud)
- **Terraform** 1.5+
- **Docker** and Docker Compose
- **Git**

## Quick Start

### 1. Initial Setup

Run the setup script to prepare your development environment:

```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

### 2. GCP Infrastructure

Deploy the cloud infrastructure using Terraform:

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your project values
terraform init
terraform plan
terraform apply
```

### 3. Local Development

Start the local development environment:

```bash
# Start backend services (PostgreSQL, Redis, API)
docker-compose up -d

# Install dependencies
npm install

# Start mobile app (in a separate terminal)
cd mobile
flutter run
```

### 4. Seed Initial Data

Populate Secret Manager with initial secrets:

```bash
chmod +x scripts/seed-secrets.sh
./scripts/seed-secrets.sh
```

## Available Scripts

The project includes several utility scripts in the `scripts/` directory:

- **`setup.sh`** - Initial project setup, API enablement, and environment configuration
- **`seed-secrets.sh`** - Populate Secret Manager with initial secrets for each environment
- **`deploy.sh`** - Manual deployment helper for Cloud Run applications
- **`backup-secrets.sh`** - Create encrypted backups of Secret Manager values for disaster recovery

All scripts support environment-specific operations (dev, staging, prod) and include comprehensive help:

```bash
./scripts/[script-name] --help
```

## Development

- **Backend**: See [backend/README.md](backend/README.md)
- **Mobile**: See [mobile/README.md](mobile/README.md)
- **Infrastructure**: See [terraform/README.md](terraform/README.md)

## Deployment

The project uses Google Cloud Build for automated CI/CD. Manual deployment is also supported:

```bash
chmod +x scripts/deploy.sh
./scripts/deploy.sh [environment]
```

For detailed deployment instructions, see [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md).

## Documentation

- [Architecture Overview](docs/ARCHITECTURE.md)
- [Deployment Guide](docs/DEPLOYMENT.md)
- [Development Guide](docs/DEVELOPMENT.md)

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is proprietary and confidential. All rights reserved.

## Support

For technical support or questions, please contact the development team.
