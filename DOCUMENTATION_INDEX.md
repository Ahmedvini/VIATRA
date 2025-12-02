# VIATRA Platform - Documentation Index

## 🎯 Quick Start Guides

### Latest Updates
- **[Sleep Tracking Fixes](SLEEP_BUGS_FIXED.md)** - Timer and pause/resume bugs fixed ✅
- **[PHQ-9 Integration](PHQ9_INTEGRATION_COMPLETE.md)** - Psychological assessment feature complete ✅
- **[Quick Start: PHQ-9](QUICK_START_PHQ9.md)** - Get PHQ-9 up and running quickly

### Feature-Specific Guides
- **[Sleep Fix Quick Guide](SLEEP_FIX_QUICK.md)** - TL;DR version of sleep tracking fixes
- **[Sleep Tracking Fixes - Detailed](SLEEP_TRACKING_FIXES.md)** - Complete technical documentation

## 🏗️ Architecture & Setup

### Core Documentation
- **[Architecture Overview](docs/ARCHITECTURE.md)** - System design and component overview
- **[Development Guide](docs/DEVELOPMENT.md)** - Setting up local development environment
- **[Deployment Guide](docs/DEPLOYMENT.md)** - Production deployment instructions
- **[Configuration Guide](docs/CONFIGURATION_GUIDE.md)** - Environment variables and settings

### Backend
- **[Backend README](backend/README.md)** - Backend API overview
- **[Chat Implementation](backend/CHAT_IMPLEMENTATION_GUIDE.md)** - Real-time chat feature
- **[PHQ-9 Backend Troubleshooting](PHQ9_BACKEND_TROUBLESHOOTING.md)** - Common backend issues

### Mobile (Flutter)
- **[Mobile README](mobile/README.md)** - Flutter app overview
- **[Doctor Search Feature](mobile/DOCTOR_SEARCH_FEATURE.md)** - Provider search implementation
- **[Flutter Debug Guide](FLUTTER_DEBUG_GUIDE.md)** - Debugging Flutter issues

## 🚀 Deployment & Operations

### Cloud Deployment
- **[Railway Deployment Steps](RAILWAY_DEPLOYMENT_STEPS.md)** - Deploy backend to Railway
- **[Terraform README](terraform/README.md)** - Infrastructure as Code (Google Cloud)
- **[Docker Setup](docker/README.md)** - Containerization and local deployment

### Build & Fix Guides
- **[Build Fix Status](docs/BUILD_FIX_FINAL_STATUS.md)** - Latest build status
- **[Build Fix Summary](docs/BUILD_FIX_SUMMARY.md)** - Historical build fixes
- **[Remaining Fixes](docs/REMAINING_FIXES.md)** - Known issues and TODOs

## 📚 Feature Documentation

### Completed Features
- **[PHQ-9 Implementation Summary](PHQ9_IMPLEMENTATION_SUMMARY.md)** - Complete feature overview
- **[PHQ-9 Dashboard Integration](PHQ9_DASHBOARD_ADDED.md)** - Dashboard integration details
- **[Chat Implementation Complete](docs/features/CHAT_IMPLEMENTATION_COMPLETE.md)** - Real-time messaging
- **[Appointment Implementation Complete](docs/features/APPOINTMENT_IMPLEMENTATION_COMPLETE.md)** - Booking system
- **[Auth Provider Integration Complete](docs/features/AUTH_PROVIDER_INTEGRATION_COMPLETE.md)** - Authentication system

### In Progress Features
- Sleep tracking (bugs fixed, ready for testing)
- Medical records management
- Prescription management
- Lab results tracking

## 🔧 Technical References

### API Documentation
- **[Chat API](docs/api/CHAT_API.md)** - WebSocket and REST endpoints for chat

### Testing
- **[Testing Guide](docs/TESTING_GUIDE.md)** - Unit, integration, and e2e testing

### Localization
- **[Localization Guide](docs/LOCALIZATION_GUIDE.md)** - Multi-language support

### Database
- **[Database Migrations](backend/src/migrations/)** - Schema changes
- **[Database Seeders](backend/src/seeders/)** - Sample data

## 🐛 Troubleshooting & Fixes

### Recent Fixes
- **[Sleep Bugs Fixed](SLEEP_BUGS_FIXED.md)** - ✅ Timer and type error fixes
- **[Final Fixes Applied](FINAL_FIXES_APPLIED.md)** - Latest bug fixes
- **[Logger Fix](LOGGER_FIX.md)** - Backend logger import issue
- **[Model Registration Fix](FIXED_MODEL_REGISTRATION.md)** - Sequelize model registration

### Build Issues
- **[Viatra App Build Status](viatra_app/FINAL_BUILD_STATUS.md)** - Build diagnostics
- **[Build Ready](viatra_app/BUILD_READY.md)** - Pre-deployment checklist

## 📊 Status Reports

### Project Status
- **[Documentation Organization](docs/DOCUMENTATION_ORGANIZATION.md)** - Docs structure
- **[Documentation Restoration](docs/DOCUMENTATION_RESTORATION_SUMMARY.md)** - Doc recovery summary
- **[Appointment Verification Fixes](docs/features/APPOINTMENT_VERIFICATION_FIXES.md)** - Appointment fixes

## 🛠️ Scripts & Automation

### Available Scripts
```bash
# Verification
./verify_sleep_fixes.sh          # Test sleep tracking fixes

# Setup
./scripts/setup.sh                # Initial project setup
./scripts/deploy.sh               # Deploy to production

# Secrets Management
./scripts/seed-secrets.sh         # Load secrets to Secret Manager
./scripts/backup-secrets.sh       # Backup secrets

# Testing
./scripts/test-nginx.sh           # Test nginx configuration
```

## 🏃‍♂️ Quick Command Reference

### Development
```bash
# Backend
cd backend
npm install
npm run dev

# Mobile
cd mobile
flutter pub get
flutter run

# Full Stack
npm run dev  # From project root
```

### Testing
```bash
# Run all tests
npm test

# Mobile tests
cd mobile
flutter test

# Backend tests
cd backend
npm test
```

### Build
```bash
# Mobile (Android)
cd mobile
flutter build apk

# Mobile (iOS)
flutter build ios

# Backend (Docker)
docker-compose up --build
```

## 📖 Additional Resources

### Project Files
- **[README.md](README.md)** - Project overview
- **[LICENSE](LICENSE)** - Apache 2.0 License
- **[.env.example](mobile/.env.example)** - Environment variable template

### VS Code Tasks
- Install Dependencies and Start Dev Server
- Flutter: Run (mobile)
- Flutter: Build APK (mobile)
- Flutter: Clean (mobile)

## 🎯 Current Sprint Status

### Completed ✅
- PHQ-9 psychological assessment (backend + mobile)
- PHQ-9 dashboard integration
- Sleep tracking timer fix
- Sleep tracking pause/resume fix
- Model registration and authentication fixes

### In Testing 🧪
- PHQ-9 end-to-end flow
- Sleep tracking with fixes

### Next Up 📋
- User acceptance testing
- Performance optimization
- Production deployment
- Analytics integration

---

## 📞 Support & Contribution

### Getting Help
1. Check relevant documentation above
2. Search closed issues in version control
3. Review troubleshooting guides
4. Check application logs

### Contributing
1. Read the development guide
2. Follow code style guidelines
3. Write tests for new features
4. Update documentation

---

**Last Updated**: 2024  
**Platform Version**: 1.0  
**Status**: Active Development  

---

## 🗂️ Documentation Structure

```
VIATRA/
├── Root Level (Quick Access)
│   ├── SLEEP_BUGS_FIXED.md ⭐ NEW
│   ├── SLEEP_TRACKING_FIXES.md ⭐ NEW
│   ├── SLEEP_FIX_QUICK.md ⭐ NEW
│   ├── PHQ9_INTEGRATION_COMPLETE.md
│   ├── QUICK_START_PHQ9.md
│   └── DOCUMENTATION_INDEX.md (this file)
│
├── docs/ (Detailed Documentation)
│   ├── ARCHITECTURE.md
│   ├── DEVELOPMENT.md
│   ├── DEPLOYMENT.md
│   ├── api/
│   ├── features/
│   ├── guides/
│   └── status/
│
├── backend/ (Backend Code & Docs)
│   ├── README.md
│   ├── src/
│   └── database/
│
├── mobile/ (Mobile Code & Docs)
│   ├── README.md
│   └── lib/
│
├── scripts/ (Automation)
│   └── *.sh
│
└── terraform/ (Infrastructure)
    └── *.tf
```

---

**Navigate**: Use the links above to jump to specific documentation.  
**Search**: Use Ctrl+F (Cmd+F on Mac) to find specific topics.  
**Update**: This index is automatically updated as new docs are added.
