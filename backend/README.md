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

### API Endpoints

All API endpoints are prefixed with `/api/v1`:

- `POST /api/v1/auth/register` - User registration
- `POST /api/v1/auth/login` - User login
- `POST /api/v1/auth/refresh` - Refresh JWT token
- `GET /api/v1/users/profile` - Get user profile
- `PUT /api/v1/users/profile` - Update user profile

(Full API documentation will be available via Swagger/OpenAPI)

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

Database migrations will be managed through a dedicated migration system:

```bash
npm run migrate
```

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
