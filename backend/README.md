# Viatra Backend

The backend API server for the Viatra Health Platform, built with Node.js and Express.js.

## Overview

This is a RESTful API service that provides:
- User authentication and authorization
- Healthcare data management
- File upload and storage integration
- Real-time features with Redis caching
- Integration with Google Cloud services

## Technology Stack

- **Runtime**: Node.js 20+
- **Framework**: Express.js
- **Database**: PostgreSQL (Google Cloud SQL)
- **Cache**: Redis (Google Memorystore)
- **Storage**: Google Cloud Storage
- **Authentication**: JWT tokens
- **Validation**: Joi
- **Logging**: Winston
- **Testing**: Jest + Supertest

## Prerequisites

- Node.js 20 or higher
- npm 9 or higher
- PostgreSQL 15+
- Redis 7+
- Google Cloud CLI (for deployment)

## Project Structure

```
backend/
├── src/
│   ├── config/           # Configuration files
│   │   ├── index.js      # Main configuration
│   │   ├── database.js   # PostgreSQL connection
│   │   ├── redis.js      # Redis connection
│   │   ├── secrets.js    # GCP Secret Manager integration
│   │   └── logger.js     # Winston logger setup
│   ├── middleware/       # Express middleware
│   │   ├── errorHandler.js
│   │   ├── requestLogger.js
│   │   ├── auth.js       # Authentication middleware
│   │   └── validation.js # Request validation
│   ├── routes/           # API route definitions
│   ├── controllers/      # Business logic
│   ├── models/          # Database models
│   ├── services/        # External service integrations
│   ├── utils/           # Helper functions
│   └── index.js         # Application entry point
├── tests/               # Test files
├── package.json
├── Dockerfile
└── README.md
```

## Local Development Setup

### 1. Environment Configuration

Copy the environment template and configure your local settings:

```bash
cp .env.example .env
```

Edit `.env` with your local configuration:
- Database connection details
- Redis connection details
- JWT secret key
- GCP project information

### 2. Install Dependencies

```bash
npm install
```

### 3. Database Setup

Make sure PostgreSQL is running and create a database:

```sql
CREATE DATABASE viatra_dev;
CREATE USER viatra_app WITH PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE viatra_dev TO viatra_app;
```

### 4. Redis Setup

Make sure Redis is running locally:

```bash
# Using Docker
docker run -d -p 6379:6379 redis:7-alpine

# Or using local installation
redis-server
```

### 5. Start Development Server

```bash
npm run dev
```

The server will start on `http://localhost:8080` with hot reload enabled.

## Available Scripts

- `npm start` - Start the production server
- `npm run dev` - Start development server with nodemon
- `npm test` - Run tests
- `npm run test:watch` - Run tests in watch mode
- `npm run test:coverage` - Run tests with coverage report
- `npm run lint` - Run ESLint
- `npm run lint:fix` - Run ESLint with auto-fix
- `npm run format` - Format code with Prettier
- `npm run format:check` - Check code formatting
- `npm run docker:build` - Build Docker image
- `npm run docker:run` - Run Docker container

## API Documentation

### Health Check

```
GET /health
```

Returns server health status and basic information.

### Authentication API

All authentication endpoints are prefixed with `/api/v1/auth`:

#### Register User
```
POST /api/v1/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "SecurePass123!",
  "firstName": "John",
  "lastName": "Doe",
  "phone": "+1234567890",
  "role": "patient"  // or "doctor", "admin"
}

// Doctor-specific additional fields:
{
  ...baseFields,
  "role": "doctor",
  "licenseNumber": "MD123456",
  "specialty": "Cardiology",
  "title": "Dr.",
  "npiNumber": "1234567890",
  "education": "Harvard Medical School",
  "consultationFee": 150.00
}
```

Rate limit: 3 requests per hour per IP

#### Login
```
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "SecurePass123!",
  "remember": true  // optional, extends token life
}
```

Rate limit: 5 requests per 15 minutes per IP (failed attempts only)

#### Logout
```
POST /api/v1/auth/logout
Authorization: Bearer <access_token>
```

#### Refresh Token
```
POST /api/v1/auth/refresh-token
Content-Type: application/json

{
  "refreshToken": "<refresh_token>"
}
```

Rate limit: 10 requests per 5 minutes per IP

#### Verify Email
```
POST /api/v1/auth/verify-email
Content-Type: application/json

{
  "email": "user@example.com",
  "code": "123456"
}
```

Rate limit: 3 requests per 5 minutes per IP

#### Request Password Reset
```
POST /api/v1/auth/request-password-reset
Content-Type: application/json

{
  "email": "user@example.com"
}
```

Rate limit: 3 requests per hour per IP

#### Reset Password
```
POST /api/v1/auth/reset-password
Content-Type: application/json

{
  "token": "<reset_token>",
  "newPassword": "NewSecurePass123!"
}
```

Rate limit: 3 requests per hour per IP

#### Get Current User
```
GET /api/v1/auth/me
Authorization: Bearer <access_token>
```

#### Validate Token
```
GET /api/v1/auth/validate-token
Authorization: Bearer <access_token>
```

### Verification API

All verification endpoints are prefixed with `/api/v1/verification`:

#### Submit Document
```
POST /api/v1/verification/submit
Authorization: Bearer <access_token>
Content-Type: multipart/form-data
Roles: doctor, admin

Form fields:
- file: <document_file>
- documentType: medical_license | board_certification | education_certificate | identification | malpractice_insurance
- description: "Optional description"
```

Rate limit: 10 requests per hour per IP

#### Get Document Status
```
GET /api/v1/verification/document/:documentId
Authorization: Bearer <access_token>
```

#### Get User Verification Status
```
GET /api/v1/verification/status
Authorization: Bearer <access_token>
```

#### Update Document Status (Admin Only)
```
PATCH /api/v1/verification/document/:documentId/status
Authorization: Bearer <access_token>
Content-Type: application/json
Roles: admin

{
  "status": "approved",  // or "rejected", "pending"
  "comments": "Optional admin comments"
}
```

Rate limit: 50 requests per 5 minutes per IP

#### Resend Verification Email
```
POST /api/v1/verification/resend-email
Authorization: Bearer <access_token>
```

Rate limit: 2 requests per 15 minutes per IP

#### Get Pending Verifications (Admin Only)
```
GET /api/v1/verification/pending
Authorization: Bearer <access_token>
Roles: admin
Query parameters:
- page: 1 (optional)
- limit: 20 (optional)
- documentType: medical_license (optional)
- userId: user_id (optional)
```

#### Bulk Update Documents (Admin Only)
```
POST /api/v1/verification/bulk-update
Authorization: Bearer <access_token>
Content-Type: application/json
Roles: admin

{
  "documentIds": ["doc1", "doc2", "doc3"],
  "status": "approved",
  "comments": "Batch approval"
}
```

#### Get Verification Statistics (Admin Only)
```
GET /api/v1/verification/stats
Authorization: Bearer <access_token>
Roles: admin
```

### cURL Examples

#### Register a new patient
```bash
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "patient@example.com",
    "password": "SecurePass123!",
    "firstName": "John",
    "lastName": "Doe",
    "phone": "+1234567890",
    "role": "patient"
  }'
```

#### Login
```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "patient@example.com",
    "password": "SecurePass123!"
  }'
```

#### Upload verification document
```bash
curl -X POST http://localhost:8080/api/v1/verification/submit \
  -H "Authorization: Bearer <your_access_token>" \
  -F "file=@/path/to/license.pdf" \
  -F "documentType=medical_license" \
  -F "description=Medical license for verification"
```

#### Get current user profile
```bash
curl -X GET http://localhost:8080/api/v1/auth/me \
  -H "Authorization: Bearer <your_access_token>"
```

### Response Format

All API responses follow a consistent format:

```json
{
  "message": "Success message",
  "data": {
    // Response data
  },
  "pagination": {  // Only for paginated responses
    "page": 1,
    "limit": 20,
    "total": 100,
    "pages": 5
  }
}
```

### Error Format

```json
{
  "error": "Error type",
  "message": "Human readable error message",
  "details": [  // Only for validation errors
    {
      "field": "email",
      "message": "Email is required"
    }
  ]
}
```

### Rate Limits

Rate limits are enforced per IP address. When exceeded, the API returns:

```json
{
  "error": "Too many requests",
  "message": "Rate limit exceeded. Try again later.",
  "retryAfter": 300
}
```

### File Upload Limits

- **Max file size**: 10MB
- **Allowed types**: JPEG, PNG, PDF
- **Storage**: Google Cloud Storage
- **Security**: Files are scanned and validated before storage

### Authentication Flow

1. **Register** → Email verification required
2. **Login** → Receive access token (15 min) & refresh token (7 days)
3. **Access APIs** → Use access token in Authorization header
4. **Token expires** → Use refresh token to get new access token
5. **Refresh expires** → Re-login required

### Role-Based Access Control (RBAC)

- **Patient**: Basic profile access, appointment booking
- **Doctor**: Patient management, verification document upload, profile management
- **Admin**: All doctor permissions + user management, verification approval, system stats

## Environment Variables

### Required Variables

- `NODE_ENV` - Environment (development, production)
- `PORT` - Server port (default: 8080)
- `DATABASE_URL` - PostgreSQL connection string
- `REDIS_HOST` - Redis host
- `REDIS_PORT` - Redis port
- `JWT_SECRET` - JWT secret key (min 32 characters)
- `GCP_PROJECT_ID` - Google Cloud project ID

### Optional Variables (Local/Test Only)

**Note**: In production, the following values are automatically sourced from Google Cloud Secret Manager:
- **App Configuration**: Rate limiting, file upload settings from `app-config-${environment}`
- **API Keys**: Stripe, Twilio, SendGrid, Firebase from `api-keys-${environment}`
- **OAuth Credentials**: Google, Apple, Facebook from `oauth-config-${environment}`

For local development and testing:
- `CORS_ORIGIN` - Allowed CORS origins
- `RATE_LIMIT_MAX` - Rate limit maximum requests (production: from Secret Manager)
- `RATE_LIMIT_WINDOW` - Rate limit window in milliseconds (production: from Secret Manager)
- `FILE_UPLOAD_MAX_SIZE` - Maximum file upload size (production: from Secret Manager)
- `STRIPE_API_KEY` - Stripe API key (production: from Secret Manager)
- `TWILIO_AUTH_TOKEN` - Twilio authentication token (production: from Secret Manager)
- `SENDGRID_API_KEY` - SendGrid API key (production: from Secret Manager)
- `FIREBASE_API_KEY` - Firebase API key (production: from Secret Manager)
- `GOOGLE_CLIENT_ID` - Google OAuth client ID (production: from Secret Manager)
- `GOOGLE_CLIENT_SECRET` - Google OAuth client secret (production: from Secret Manager)
- `APPLE_CLIENT_ID` - Apple OAuth client ID (production: from Secret Manager)
- `APPLE_CLIENT_SECRET` - Apple OAuth client secret (production: from Secret Manager)
- `FACEBOOK_APP_ID` - Facebook app ID (production: from Secret Manager)
- `FACEBOOK_APP_SECRET` - Facebook app secret (production: from Secret Manager)
- `LOG_LEVEL` - Logging level (debug, info, warn, error)

## Testing

### Running Tests

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Run with coverage
npm run test:coverage
```

### Test Structure

```
tests/
├── unit/           # Unit tests
├── integration/    # Integration tests
├── fixtures/       # Test data
└── helpers/        # Test utilities
```

### Writing Tests

Example test file:

```javascript
import request from 'supertest';
import app from '../src/index.js';

describe('Health Check', () => {
  it('should return health status', async () => {
    const response = await request(app)
      .get('/health')
      .expect(200);
    
    expect(response.body.status).toBe('healthy');
  });
});
```

## Docker

### Building Image

```bash
npm run docker:build
```

### Running Container

```bash
npm run docker:run
```

### Production Deployment

The application uses a multi-stage Dockerfile optimized for production:

1. **Builder stage**: Installs dependencies
2. **Production stage**: Copies only production files and dependencies

## Logging

The application uses Winston for structured logging:

- **Development**: Colorized console output
- **Production**: JSON format with file rotation
- **Levels**: error, warn, info, debug

Log files are stored in the `logs/` directory:
- `app.log` - Combined logs
- `error.log` - Error logs only

## Security

### Authentication

- JWT tokens for stateless authentication
- Refresh token mechanism for security
- Secure password hashing with bcrypt

### Security Middleware

- Helmet for security headers
- CORS configuration
- Rate limiting
- Request size limits
- Input validation with Joi

### Best Practices

- Environment variables for secrets
- Least privilege database access
- SQL injection prevention with parameterized queries
- XSS protection
- CSRF protection for web clients

## Database

### Migrations

Database migrations are managed through Sequelize CLI:

```bash
# Run all pending migrations
npm run db:migrate

# Undo the last migration
npm run db:migrate:undo

# Undo all migrations
npm run db:migrate:undo:all

# Seed the database with sample data
npm run db:seed

# Undo all seeders
npm run db:seed:undo

# Reset database (undo all migrations, run all migrations, run all seeders)
npm run db:reset
```

### Database Schema

The application uses a doctor/patient-centric schema with the following core models:
- **Users** - Base user authentication and profile data
- **Doctors** - Doctor-specific information (specialties, licenses, schedules)
- **Patients** - Patient demographics and contact information  
- **Appointments** - Scheduled consultations between doctors and patients
- **HealthProfiles** - Patient medical history, allergies, medications
- **Verifications** - Document verification for professional credentials

### Connection Pooling

The application uses connection pooling for optimal database performance:
- Max connections: 20
- Idle timeout: 30 seconds
- Connection timeout: 10 seconds

## Caching

Redis is used for:
- Session storage
- API response caching
- Rate limiting counters
- Temporary data storage

## Error Handling

Centralized error handling with:
- Structured error responses
- Request ID tracking
- Detailed logging
- Environment-specific error details

## Performance

### Optimization Techniques

- Database connection pooling
- Redis caching
- Response compression
- Async/await for non-blocking operations
- Request timeout handling

### Monitoring

- Request/response logging
- Performance metrics
- Error rate tracking
- Database query performance

## Deployment

### Google Cloud Run

The application is designed to run on Google Cloud Run:

1. Build Docker image
2. Push to Google Container Registry
3. Deploy to Cloud Run
4. Configure environment variables from Secret Manager

### Environment Setup

Different configurations for each environment:

- **Development**: Local databases, debug logging
- **Staging**: Shared cloud resources, info logging
- **Production**: High availability setup, error logging

## Troubleshooting

### Common Issues

1. **Database Connection Errors**
   - Check connection string and credentials
   - Verify database is running and accessible
   - Check firewall rules for Cloud SQL

2. **Redis Connection Errors**
   - Verify Redis host and port
   - Check authentication credentials
   - Ensure Redis service is running

3. **Authentication Issues**
   - Verify JWT secret configuration
   - Check token expiration settings
   - Validate request headers

4. **File Upload Problems**
   - Check GCS bucket permissions
   - Verify service account credentials
   - Review file size limits

### Getting Help

- Check application logs in `logs/` directory
- Enable debug logging: `LOG_LEVEL=debug`
- Use health check endpoint: `/health`
- Review error responses for details
