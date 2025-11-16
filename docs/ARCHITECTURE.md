# System Architecture

This document describes the overall system architecture of the Viatra Health Platform.

## Overview

The Viatra Health Platform is a cloud-native, microservices-based healthcare application designed for scalability, security, and reliability. The system follows a modern architecture pattern with clear separation of concerns between the mobile client, backend API, and cloud infrastructure.

## Architecture Principles

### 1. Cloud-Native Design
- Built for Google Cloud Platform (GCP)
- Containerized services using Docker
- Serverless computing with Cloud Run
- Managed services for databases and caching

### 2. Security-First Approach
- Zero-trust network security
- End-to-end encryption
- Secure secret management
- Regular security audits and monitoring

### 3. Scalability and Performance
- Horizontal auto-scaling
- Caching at multiple layers
- Optimized database queries
- CDN for static assets

### 4. Reliability and Resilience
- Multi-region deployment capability
- Automated backups and disaster recovery
- Health checks and monitoring
- Graceful degradation strategies

## System Components

### Mobile Application (Flutter)
```
┌─────────────────────────────────────┐
│              Mobile App             │
├─────────────────────────────────────┤
│ • Cross-platform Flutter app       │
│ • Material Design 3 UI              │
│ • Provider state management        │
│ • Secure local storage             │
│ • Offline capability               │
│ • Push notifications               │
└─────────────────────────────────────┘
```

### Backend API (Node.js)
```
┌─────────────────────────────────────┐
│            Backend API              │
├─────────────────────────────────────┤
│ • Node.js with Express.js           │
│ • RESTful API design               │
│ • JWT authentication               │
│ • Input validation & sanitization  │
│ • Rate limiting & security         │
│ • Structured logging               │
└─────────────────────────────────────┘
```

### Cloud Infrastructure
```
┌─────────────────────────────────────┐
│         Google Cloud Platform       │
├─────────────────────────────────────┤
│ • Cloud Run (Serverless containers) │
│ • Cloud SQL (PostgreSQL)           │
│ • Redis Memorystore (Caching)      │
│ • Cloud Storage (File storage)     │
│ • Secret Manager (Secrets)         │
│ • VPC (Network security)           │
└─────────────────────────────────────┘
```

## Detailed Architecture Diagram

```
┌─────────────────┐    ┌─────────────────┐
│   Mobile Apps   │    │   Web Clients   │
│  (iOS/Android)  │    │  (Future Web)   │
└─────────┬───────┘    └─────────┬───────┘
          │                      │
          └──────────┬───────────┘
                     │
              ┌──────▼──────┐
              │   Load      │
              │  Balancer   │
              └──────┬──────┘
                     │
          ┌─────────▼─────────┐
          │   Cloud Run       │
          │  Backend API      │
          │  (Auto-scaling)   │
          └─────────┬─────────┘
                    │
     ┌──────────────┼──────────────┐
     │              │              │
┌────▼───┐    ┌────▼───┐    ┌─────▼─────┐
│ Cloud  │    │ Redis  │    │   Cloud   │
│  SQL   │    │Memory- │    │  Storage  │
│(PostgreSQL)│ store  │    │  (Files)  │
└────────┘    └────────┘    └───────────┘
     │              │              │
     └──────────────┼──────────────┘
                    │
          ┌─────────▼─────────┐
          │   Secret Manager  │
          │   (Credentials)   │
          └───────────────────┘
```

## Network Architecture

### VPC Configuration
- **Private VPC**: Isolates all resources from public internet
- **Subnets**: Separate subnets for different environments
- **VPC Connector**: Allows Cloud Run to access VPC resources
- **Cloud NAT**: Provides outbound internet access
- **Firewall Rules**: Restricts traffic to necessary communications only

### Security Layers
1. **Network Level**: VPC isolation, firewall rules
2. **Application Level**: Authentication, authorization
3. **Data Level**: Encryption at rest and in transit
4. **Infrastructure Level**: IAM roles, service accounts

## Data Architecture

### Database Design
```
PostgreSQL (Cloud SQL)
├── Users
│   ├── Authentication data
│   ├── Profile information
│   └── Preferences
├── Healthcare Providers
│   ├── Provider profiles
│   ├── Services offered
│   └── Availability
├── Appointments
│   ├── Booking details
│   ├── Status tracking
│   └── History
└── Documents
    ├── Metadata
    ├── Access permissions
    └── Storage references
```

### Caching Strategy
```
Redis Memorystore
├── Session Data
│   ├── User sessions
│   └── Authentication tokens
├── Application Cache
│   ├── Frequently accessed data
│   ├── API response cache
│   └── Configuration cache
└── Real-time Data
    ├── Notification queues
    └── Live updates
```

### File Storage
```
Cloud Storage
├── User Documents
│   ├── Medical records
│   ├── Insurance documents
│   └── ID verification
├── Provider Assets
│   ├── Profile images
│   ├── Certificates
│   └── Practice photos
└── Application Assets
    ├── Static resources
    └── Cached content
```

## Security Architecture

### Authentication Flow
1. **User Registration/Login**: Mobile app → Backend API
2. **Token Generation**: JWT tokens with refresh mechanism
3. **Token Validation**: Every API request validates JWT
4. **Session Management**: Redis stores session state
5. **Token Refresh**: Automatic refresh before expiration

### Authorization Model
- **Role-Based Access Control (RBAC)**
- **Resource-Level Permissions**
- **Attribute-Based Access Control (ABAC) for sensitive data**

### Data Protection
- **Encryption at Rest**: All databases and storage encrypted
- **Encryption in Transit**: TLS 1.3 for all communications
- **Key Management**: Google Cloud KMS for encryption keys
- **Secret Management**: Google Secret Manager for credentials

## Deployment Architecture

### Environments
```
┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│ Development │  │   Staging   │  │ Production  │
├─────────────┤  ├─────────────┤  ├─────────────┤
│ • Dev GCP   │  │ • Staging   │  │ • Prod GCP  │
│   project   │  │   GCP proj  │  │   project   │
│ • Minimal   │  │ • Production│  │ • High      │
│   resources │  │   like      │  │   available │
│ • Shared    │  │ • Reduced   │  │ • Multi-    │
│   services  │  │   capacity  │  │   region    │
└─────────────┘  └─────────────┘  └─────────────┘
```

### CI/CD Pipeline
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Source    │    │   Build     │    │   Deploy    │
│   Control   │───▶│   & Test    │───▶│   & Monitor │
├─────────────┤    ├─────────────┤    ├─────────────┤
│ • Git repo  │    │ • Cloud     │    │ • Cloud Run │
│ • Branch    │    │   Build     │    │ • Health    │
│   strategy  │    │ • Auto      │    │   checks    │
│ • Code      │    │   tests     │    │ • Monitoring│
│   review    │    │ • Security  │    │ • Rollback  │
│             │    │   scans     │    │   strategy  │
└─────────────┘    └─────────────┘    └─────────────┘
```

## Monitoring and Observability

### Logging Strategy
- **Structured Logging**: JSON format for all logs
- **Centralized Logging**: Google Cloud Logging
- **Log Levels**: DEBUG, INFO, WARN, ERROR
- **Correlation IDs**: Track requests across services

### Monitoring Stack
```
┌─────────────────┐
│  Google Cloud   │
│   Operations    │
├─────────────────┤
│ • Cloud         │
│   Monitoring    │
│ • Cloud Logging │
│ • Error         │
│   Reporting     │
│ • Cloud Trace   │
│ • Uptime        │
│   Monitoring    │
└─────────────────┘
```

### Key Metrics
- **Application Metrics**: Request rate, response time, error rate
- **Infrastructure Metrics**: CPU, memory, disk, network usage
- **Business Metrics**: User registrations, appointments, revenue
- **Security Metrics**: Failed logins, suspicious activities

## Scalability Considerations

### Horizontal Scaling
- **Cloud Run**: Automatic scaling based on request load
- **Database**: Read replicas for read-heavy workloads
- **Cache**: Redis cluster for high availability
- **Storage**: Auto-scaling storage with lifecycle policies

### Performance Optimization
- **CDN**: Content delivery network for static assets
- **Caching**: Multi-layer caching strategy
- **Database Optimization**: Proper indexing and query optimization
- **API Optimization**: Response compression and pagination

### Load Testing Strategy
- **Baseline Testing**: Establish performance baselines
- **Stress Testing**: Test beyond normal capacity
- **Spike Testing**: Test sudden load increases
- **Endurance Testing**: Test sustained high load

## Disaster Recovery

### Backup Strategy
- **Database Backups**: Automated daily backups with point-in-time recovery
- **File Storage Backups**: Cross-region replication
- **Configuration Backups**: Infrastructure as Code in Git
- **Secret Backups**: Secure secret rotation and backup

### Recovery Procedures
1. **RTO (Recovery Time Objective)**: 4 hours for critical systems
2. **RPO (Recovery Point Objective)**: 1 hour maximum data loss
3. **Multi-Region Deployment**: Failover to backup region
4. **Data Replication**: Real-time or near-real-time replication

### Business Continuity
- **Service Dependencies**: Document all external dependencies
- **Fallback Procedures**: Manual processes for critical functions
- **Communication Plan**: Stakeholder notification procedures
- **Regular DR Testing**: Quarterly disaster recovery drills

## Technology Stack Summary

| Component | Technology | Purpose |
|-----------|------------|---------|
| Mobile App | Flutter 3.x | Cross-platform mobile development |
| Backend API | Node.js 20, Express.js | RESTful API server |
| Database | PostgreSQL 15 (Cloud SQL) | Primary data storage |
| Cache | Redis 7 (Memorystore) | Session and application caching |
| File Storage | Cloud Storage | Document and media storage |
| Container Platform | Cloud Run | Serverless container deployment |
| Infrastructure | Terraform | Infrastructure as Code |
| CI/CD | Cloud Build / GitHub Actions | Automated deployment pipeline |
| Monitoring | Google Cloud Operations | System monitoring and alerting |
| Security | Secret Manager, IAM | Credential and access management |

## Future Architecture Considerations

### Microservices Evolution
- **Service Decomposition**: Break monolithic API into services
- **Event-Driven Architecture**: Implement async messaging
- **API Gateway**: Centralized API management
- **Service Mesh**: Advanced traffic management

### Advanced Features
- **GraphQL**: More efficient data fetching
- **WebRTC**: Real-time video consultations
- **Machine Learning**: AI-powered features
- **Blockchain**: Secure health record verification

### Global Expansion
- **Multi-Region Deployment**: Global load distribution
- **Data Residency**: Compliance with local data laws
- **Edge Computing**: Reduced latency worldwide
- **Internationalization**: Multiple language and cultural support

This architecture provides a solid foundation for the Viatra Health Platform while maintaining flexibility for future growth and evolution.
