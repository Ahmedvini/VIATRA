# Viatra Backend

The backend API server for the Viatra Health Platform, built with Node.js and Express.js.

## Overview

This is a RESTful API service that provides:
- User authentication and authorization
- Healthcare data management
- Appointment booking and management
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
  "role": "patient"  // or "doctor", "hospital", "pharmacy", "admin"
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

### Health Profile Management API

All health profile endpoints are prefixed with `/api/v1/health-profiles`:

#### Get My Health Profile
```
GET /api/v1/health-profiles/me
Authorization: Bearer <access_token>
Roles: patient

Response:
{
  "message": "Health profile retrieved successfully",
  "data": {
    "id": "profile_id",
    "patientId": "patient_id",
    "bloodType": "A+",
    "height": 175,
    "weight": 70,
    "chronicConditions": [
      {
        "name": "Diabetes Type 2",
        "diagnosedYear": 2020,
        "notes": "Under control with medication"
      }
    ],
    "allergies": [
      {
        "allergen": "Penicillin",
        "reaction": "Skin rash",
        "severity": "moderate"
      }
    ],
    "medications": ["Metformin", "Aspirin"],
    "emergencyContact": {
      "name": "Jane Doe",
      "relationship": "Spouse",
      "phone": "+1234567890"
    },
    "notes": "Additional health information",
    "bloodPressureSystolic": 120,
    "bloodPressureDiastolic": 80,
    "heartRate": 72,
    "bloodGlucose": 95,
    "oxygenSaturation": 98,
    "createdAt": "2024-01-01T00:00:00.000Z",
    "updatedAt": "2024-01-01T00:00:00.000Z"
  }
}
```

Rate limit: 10 requests per minute

#### Create Health Profile
```
POST /api/v1/health-profiles
Authorization: Bearer <access_token>
Content-Type: application/json
Roles: patient

{
  "bloodType": "A+",
  "height": 175,
  "weight": 70,
  "chronicConditions": [
    {
      "name": "Diabetes Type 2",
      "diagnosedYear": 2020,
      "notes": "Under control with medication"
    }
  ],
  "allergies": [
    {
      "allergen": "Penicillin",
      "reaction": "Skin rash",
      "severity": "moderate"
    }
  ],
  "medications": ["Metformin", "Aspirin"],
  "emergencyContact": {
    "name": "Jane Doe",
    "relationship": "Spouse",
    "phone": "+1234567890"
  },
  "notes": "Additional health information"
}

Response:
{
  "message": "Health profile created successfully",
  "data": { /* health profile object */ }
}
```

Rate limit: 10 requests per minute

#### Update Health Profile
```
PATCH /api/v1/health-profiles/me
Authorization: Bearer <access_token>
Content-Type: application/json
Roles: patient

{
  "bloodType": "A+",
  "height": 180,
  "weight": 72,
  "medications": ["Metformin", "Aspirin", "Lisinopril"],
  "notes": "Updated health information"
}

Response:
{
  "message": "Health profile updated successfully",
  "data": { /* updated health profile object */ }
}
```

Rate limit: 10 requests per minute

#### Add Chronic Condition
```
POST /api/v1/health-profiles/me/chronic-conditions
Authorization: Bearer <access_token>
Content-Type: application/json
Roles: patient

{
  "name": "Hypertension",
  "diagnosedYear": 2022,
  "notes": "Controlled with medication"
}

Response:
{
  "message": "Chronic condition added successfully",
  "data": { /* updated health profile object */ }
}
```

Rate limit: 10 requests per minute

#### Remove Chronic Condition
```
DELETE /api/v1/health-profiles/me/chronic-conditions/:conditionId
Authorization: Bearer <access_token>
Roles: patient

Response:
{
  "message": "Chronic condition removed successfully",
  "data": { /* updated health profile object */ }
}
```

Rate limit: 10 requests per minute

#### Add Allergy
```
POST /api/v1/health-profiles/me/allergies
Authorization: Bearer <access_token>
Content-Type: application/json
Roles: patient

{
  "allergen": "Peanuts",
  "reaction": "Anaphylaxis",
  "severity": "severe"
}

Response:
{
  "message": "Allergy added successfully",
  "data": { /* updated health profile object */ }
}
```

Rate limit: 10 requests per minute

#### Remove Allergy
```
DELETE /api/v1/health-profiles/me/allergies/:allergen
Authorization: Bearer <access_token>
Roles: patient

Response:
{
  "message": "Allergy removed successfully",
  "data": { /* updated health profile object */ }
}
```

Rate limit: 10 requests per minute

#### Update Vitals
```
PATCH /api/v1/health-profiles/me/vitals
Authorization: Bearer <access_token>
Content-Type: application/json
Roles: patient

{
  "bloodPressureSystolic": 125,
  "bloodPressureDiastolic": 82,
  "heartRate": 75,
  "bloodGlucose": 98,
  "oxygenSaturation": 99
}

Response:
{
  "message": "Vitals updated successfully",
  "data": { /* updated health profile object */ }
}
```

Rate limit: 10 requests per minute

**Authentication & Authorization**
- All health profile endpoints require authentication via Bearer token
- Only patients can access their own health profiles
- Patient lookup is automatic based on the authenticated user

**Caching**
- Health profiles are cached in Redis with a 5-minute TTL
- Cache is automatically invalidated on create, update, or delete operations
- Force refresh by re-fetching after cache expiration

**Validation**
- All request bodies are validated using Joi schemas
- Blood type must be one of: A+, A-, B+, B-, AB+, AB-, O+, O-
- Height must be between 30-300 cm
- Weight must be between 1-500 kg
- Blood pressure systolic: 70-250 mmHg, diastolic: 40-150 mmHg
- Heart rate: 30-250 bpm
- Blood glucose: 20-600 mg/dL
- Oxygen saturation: 50-100%
- Allergy severity must be: mild, moderate, or severe

### Doctor Search API

All doctor search endpoints are prefixed with `/api/v1/doctors`:

#### Search Doctors
```
GET /api/v1/doctors/search
Query Parameters (all optional):
- specialty: string (case-insensitive partial match)
- subSpecialty: string (case-insensitive partial match)
- city: string (case-insensitive partial match)
- state: string (case-insensitive partial match)
- zipCode: string (exact match)
- minFee: number (minimum consultation fee)
- maxFee: number (maximum consultation fee)
- languages: string (comma-separated list, e.g., "English,Spanish")
- isAcceptingPatients: boolean (true/false)
- telehealthEnabled: boolean (true/false)
- page: number (default: 1, min: 1)
- limit: number (default: 20, min: 1, max: 100)
- sortBy: string (default: 'created_at', options: 'created_at', 'consultation_fee', 'years_of_experience')
- sortOrder: string (default: 'DESC', options: 'ASC', 'DESC')

Example Request:
curl -X GET "http://localhost:8080/api/v1/doctors/search?specialty=Cardiology&city=New%20York&isAcceptingPatients=true&page=1&limit=20"

Response:
{
  "success": true,
  "message": "Doctors retrieved successfully",
  "data": {
    "doctors": [
      {
        "id": "doctor_uuid",
        "specialty": "Cardiology",
        "sub_specialty": "Interventional Cardiology",
        "years_of_experience": 15,
        "consultation_fee": 250.00,
        "office_city": "New York",
        "office_state": "NY",
        "office_zip_code": "10001",
        "office_address_line1": "123 Medical Plaza",
        "office_phone": "+1234567890",
        "is_accepting_patients": true,
        "telehealth_enabled": true,
        "languages_spoken": ["English", "Spanish"],
        "working_hours": {
          "monday": { "open": "09:00", "close": "17:00" },
          "tuesday": { "open": "09:00", "close": "17:00" },
          ...
        },
        "user": {
          "id": "user_uuid",
          "first_name": "John",
          "last_name": "Doe",
          "email": "john.doe@example.com",
          "phone": "+1234567890",
          "profile_image": "https://..."
        },
        "created_at": "2024-01-01T00:00:00.000Z",
        "updated_at": "2024-01-01T00:00:00.000Z"
      }
    ],
    "pagination": {
      "total": 45,
      "page": 1,
      "limit": 20,
      "totalPages": 3
    }
  }
}
```

Rate limit: 30 requests per minute

**Search Features**:
- Case-insensitive partial matching for text fields (specialty, city, state)
- Exact matching for zipCode
- Price range filtering with minFee/maxFee
- Array containment for languages (supports multiple language filters)
- Boolean filters for availability and telehealth
- Pagination with configurable page size
- Sorting by multiple criteria
- Returns associated User data for each doctor

**Performance Optimization**:
- Redis caching with 5-minute TTL
- Database indexes on frequently queried columns:
  - Composite index on `specialty` + `office_city`
  - Index on `consultation_fee` for price range queries
  - GIN index on `languages_spoken` for array queries
  - Indexes on `is_accepting_patients` and `telehealth_enabled`
  - Composite indexes for common filter combinations

#### Get Doctor by ID
```
GET /api/v1/doctors/:id
Path Parameters:
- id: UUID of the doctor

Example Request:
curl -X GET "http://localhost:8080/api/v1/doctors/doctor_uuid"

Response:
{
  "success": true,
  "message": "Doctor retrieved successfully",
  "data": {
    "id": "doctor_uuid",
    "specialty": "Cardiology",
    "sub_specialty": "Interventional Cardiology",
    "license_number": "MD123456",
    "npi_number": "1234567890",
    "years_of_experience": 15,
    "bio": "Experienced cardiologist specializing in...",
    "education": "Harvard Medical School, MD",
    "certifications": ["Board Certified in Cardiology", "ACLS Certified"],
    "consultation_fee": 250.00,
    "office_address_line1": "123 Medical Plaza",
    "office_address_line2": "Suite 400",
    "office_city": "New York",
    "office_state": "NY",
    "office_zip_code": "10001",
    "office_phone": "+1234567890",
    "is_accepting_patients": true,
    "telehealth_enabled": true,
    "languages_spoken": ["English", "Spanish"],
    "working_hours": {
      "monday": { "open": "09:00", "close": "17:00" },
      "tuesday": { "open": "09:00", "close": "17:00" },
      "wednesday": { "open": "09:00", "close": "17:00" },
      "thursday": { "open": "09:00", "close": "17:00" },
      "friday": { "open": "09:00", "close": "17:00" },
      "saturday": null,
      "sunday": null
    },
    "user": {
      "id": "user_uuid",
      "first_name": "John",
      "last_name": "Doe",
      "email": "john.doe@example.com",
      "phone": "+1234567890",
      "profile_image": "https://...",
      "email_verified": true
    },
    "created_at": "2024-01-01T00:00:00.000Z",
    "updated_at": "2024-01-01T00:00:00.000Z"
  }
}

Error Response (404):
{
  "success": false,
  "message": "Doctor not found"
}
```

Rate limit: 60 requests per minute

**Caching**: Individual doctor profiles are cached in Redis for 5 minutes

#### Get Doctor Availability
```
GET /api/v1/doctors/:id/availability
Path Parameters:
- id: UUID of the doctor

Example Request:
curl -X GET "http://localhost:8080/api/v1/doctors/doctor_uuid/availability"

Response:
{
  "success": true,
  "message": "Doctor availability retrieved successfully",
  "data": {
    "workingHours": {
      "monday": { "open": "09:00", "close": "17:00" },
      "tuesday": { "open": "09:00", "close": "17:00" },
      "wednesday": { "open": "09:00", "close": "17:00" },
      "thursday": { "open": "09:00", "close": "17:00" },
      "friday": { "open": "09:00", "close": "17:00" },
      "saturday": null,
      "sunday": null
    },
    "isAcceptingPatients": true,
    "telehealthEnabled": true
  }
}

Error Response (404):
{
  "success": false,
  "message": "Doctor not found"
}
```

Rate limit: 60 requests per minute

**Use Case**: This endpoint is useful for quickly checking a doctor's availability status without fetching the full profile.

**Authentication & Authorization**
- All doctor endpoints are public (no authentication required)
- Optional authentication context available for future features (favorites, booking history)

**Database Indexes**
The following indexes are created to optimize search performance:
- `idx_doctors_specialty_city` - Composite index on specialty and city
- `idx_doctors_specialty` - Index on specialty alone
- `idx_doctors_city_state` - Composite index on city and state
- `idx_doctors_consultation_fee` - Index on consultation fee
- `idx_doctors_accepting_patients` - Index on is_accepting_patients
- `idx_doctors_accepting_created` - Composite index on accepting patients and created_at
- `idx_doctors_zip_code` - Index on office zip code
- `idx_doctors_languages_spoken` - GIN index on languages_spoken JSONB array
- `idx_doctors_created_at` - Index on created_at for sorting
- `idx_doctors_telehealth_accepting` - Composite index on telehealth and accepting patients

### Appointment Booking API

All appointment endpoints are prefixed with `/api/v1/appointments`:

#### Create Appointment
```
POST /api/v1/appointments
Authorization: Bearer <access_token>
Content-Type: application/json
Roles: patient

{
  "doctorId": "doctor_uuid",
  "appointmentType": "consultation",  // or "follow_up", "checkup", "procedure"
  "scheduledStart": "2024-12-15T09:00:00.000Z",
  "scheduledEnd": "2024-12-15T09:30:00.000Z",
  "reasonForVisit": "Annual checkup",
  "chiefComplaint": "Chest pain, shortness of breath",  // optional
  "urgent": false  // optional, default false
}

Response:
{
  "success": true,
  "message": "Appointment created successfully",
  "data": {
    "id": "appointment_uuid",
    "patientId": "patient_uuid",
    "doctorId": "doctor_uuid",
    "appointmentType": "consultation",
    "scheduledStart": "2024-12-15T09:00:00.000Z",
    "scheduledEnd": "2024-12-15T09:30:00.000Z",
    "status": "scheduled",
    "reasonForVisit": "Annual checkup",
    "urgent": false,
    "doctor": {
      "id": "doctor_uuid",
      "specialty": "Cardiology",
      "user": {
        "firstName": "John",
        "lastName": "Doe",
        "email": "doctor@example.com"
      }
    },
    "createdAt": "2024-12-01T10:00:00.000Z",
    "updatedAt": "2024-12-01T10:00:00.000Z"
  }
}
```

Rate limit: 20 requests per hour

**Validation**:
- Doctor must exist and be accepting patients
- Scheduled time must be within doctor's working hours
- No conflicting appointments for the same doctor
- End time must be after start time
- Scheduled time must be in the future

#### Get My Appointments
```
GET /api/v1/appointments
Authorization: Bearer <access_token>
Roles: patient
Query Parameters (all optional):
- status: string (scheduled, confirmed, in_progress, completed, cancelled, no_show)
- startDate: ISO date string (filter by scheduled start >= this date)
- endDate: ISO date string (filter by scheduled start <= this date)
- page: number (default: 1)
- limit: number (default: 10, max: 50)
- sortBy: string (default: 'scheduledStart')
- sortOrder: string (default: 'DESC', options: 'ASC', 'DESC')

Response:
{
  "success": true,
  "message": "Appointments retrieved successfully",
  "data": {
    "appointments": [
      {
        "id": "appointment_uuid",
        "appointmentType": "consultation",
        "scheduledStart": "2024-12-15T09:00:00.000Z",
        "scheduledEnd": "2024-12-15T09:30:00.000Z",
        "status": "scheduled",
        "reasonForVisit": "Annual checkup",
        "urgent": false,
        "doctor": {
          "id": "doctor_uuid",
          "specialty": "Cardiology",
          "consultationFee": 250.00,
          "user": {
            "firstName": "John",
            "lastName": "Doe"
          }
        }
      }
    ],
    "pagination": {
      "total": 15,
      "page": 1,
      "limit": 10,
      "totalPages": 2
    }
  }
}
```

Rate limit: 30 requests per minute

**Caching**: Results are cached for 5 minutes per unique filter combination

#### Get Appointment by ID
```
GET /api/v1/appointments/:id
Authorization: Bearer <access_token>
Path Parameters:
- id: UUID of the appointment

Response:
{
  "success": true,
  "message": "Appointment retrieved successfully",
  "data": {
    "id": "appointment_uuid",
    "patientId": "patient_uuid",
    "doctorId": "doctor_uuid",
    "appointmentType": "consultation",
    "scheduledStart": "2024-12-15T09:00:00.000Z",
    "scheduledEnd": "2024-12-15T09:30:00.000Z",
    "actualStart": null,
    "actualEnd": null,
    "status": "scheduled",
    "reasonForVisit": "Annual checkup",
    "chiefComplaint": "Chest pain",
    "urgent": false,
    "notes": null,
    "followUpRequired": null,
    "followUpInstructions": null,
    "cancellationReason": null,
    "cancelledBy": null,
    "cancelledAt": null,
    "doctor": {
      "id": "doctor_uuid",
      "specialty": "Cardiology",
      "officeAddress": "123 Medical Plaza",
      "user": {
        "firstName": "John",
        "lastName": "Doe",
        "email": "doctor@example.com",
        "phone": "+1234567890"
      }
    },
    "patient": {
      "id": "patient_uuid",
      "user": {
        "firstName": "Jane",
        "lastName": "Smith",
        "email": "patient@example.com",
        "phone": "+0987654321"
      }
    },
    "createdAt": "2024-12-01T10:00:00.000Z",
    "updatedAt": "2024-12-01T10:00:00.000Z"
  }
}
```

Rate limit: 60 requests per minute

**Access Control**: Patient can only view their own appointments; doctor can view appointments assigned to them

#### Update Appointment
```
PATCH /api/v1/appointments/:id
Authorization: Bearer <access_token>
Content-Type: application/json
Path Parameters:
- id: UUID of the appointment

{
  "scheduledStart": "2024-12-15T10:00:00.000Z",  // optional
  "scheduledEnd": "2024-12-15T10:30:00.000Z",  // optional
  "notes": "Patient requested morning slot",  // optional
  "status": "confirmed"  // optional
}

Response:
{
  "success": true,
  "message": "Appointment updated successfully",
  "data": { /* updated appointment object */ }
}
```

Rate limit: 10 requests per hour

**Validation**:
- Cannot update completed, cancelled, or no-show appointments
- If rescheduling, must check doctor availability
- Only patient or assigned doctor can update

#### Cancel Appointment
```
POST /api/v1/appointments/:id/cancel
Authorization: Bearer <access_token>
Content-Type: application/json
Path Parameters:
- id: UUID of the appointment

{
  "cancellationReason": "Schedule conflict"  // required
}

Response:
{
  "success": true,
  "message": "Appointment cancelled successfully",
  "data": {
    "id": "appointment_uuid",
    "status": "cancelled",
    "cancelledBy": "patient",
    "cancelledAt": "2024-12-01T10:00:00.000Z",
    "cancellationReason": "Schedule conflict"
  }
}
```

Rate limit: 10 requests per hour

**Validation**:
- Appointment must be at least 2 hours in the future
- Only scheduled or confirmed appointments can be cancelled
- Cancelled appointments cannot be un-cancelled

#### Get Doctor Availability (Time Slots)
```
GET /api/v1/doctors/:doctorId/availability
Query Parameters:
- date: ISO date string (required) - Date to check availability
- duration: number (optional, default: 30) - Appointment duration in minutes

Example Request:
curl -X GET "http://localhost:8080/api/v1/doctors/doctor_uuid/availability?date=2024-12-15&duration=30"

Response:
{
  "success": true,
  "message": "Available time slots retrieved successfully",
  "data": [
    {
      "start": "2024-12-15T09:00:00.000Z",
      "end": "2024-12-15T09:30:00.000Z",
      "available": true
    },
    {
      "start": "2024-12-15T09:30:00.000Z",
      "end": "2024-12-15T10:00:00.000Z",
      "available": false
    },
    {
      "start": "2024-12-15T10:00:00.000Z",
      "end": "2024-12-15T10:30:00.000Z",
      "available": true
    }
  ]
}
```

Rate limit: 30 requests per minute

**Features**:
- Generates time slots based on doctor's working hours
- Checks for existing appointments to mark slots as unavailable
- Configurable appointment duration
- Returns only slots within the doctor's working day

**Performance Optimization**:
- Composite indexes on `(patient_id, status, scheduled_start)` and `(doctor_id, status, scheduled_start)`
- Index on `(scheduled_start, scheduled_end)` for conflict detection
- Redis caching with 5-minute TTL for availability queries
- Cache invalidation on appointment create/update/cancel

### Doctor Appointment Management

Doctor-specific endpoints for managing appointments. All endpoints require authentication and doctor role.

#### Get Doctor's Appointments

```
GET /api/v1/appointments/doctor/me
Query Parameters:
- status: Filter by status (scheduled, confirmed, in_progress, completed, cancelled, no_show)
- startDate: ISO date string - Filter appointments from this date
- endDate: ISO date string - Filter appointments until this date
- page: Page number (default: 1)
- limit: Items per page (default: 20, max: 100)
- sortBy: Sort field (scheduled_start, created_at, status)
- sortOrder: Sort direction (ASC, DESC)

Example Request:
curl -X GET "http://localhost:8080/api/v1/appointments/doctor/me?status=scheduled&page=1&limit=20" \
  -H "Authorization: Bearer <token>"

Response:
{
  "success": true,
  "message": "Appointments retrieved successfully",
  "data": {
    "appointments": [
      {
        "id": "uuid",
        "patientId": "patient_uuid",
        "appointmentType": "telehealth",
        "scheduledStart": "2024-12-15T09:00:00.000Z",
        "scheduledEnd": "2024-12-15T09:30:00.000Z",
        "status": "scheduled",
        "reasonForVisit": "Annual checkup",
        "urgent": false,
        "patient": {
          "id": "patient_uuid",
          "user": {
            "firstName": "John",
            "lastName": "Doe",
            "email": "john@example.com",
            "phone": "+1234567890"
          }
        }
      }
    ],
    "pagination": {
      "total": 45,
      "page": 1,
      "limit": 20,
      "totalPages": 3
    }
  }
}
```

Rate limit: 30 requests per minute

**Authentication**: Requires JWT token and doctor role

**Caching**: Results cached in Redis for 5 minutes

#### Get Doctor Dashboard Statistics

```
GET /api/v1/appointments/doctor/dashboard

Example Request:
curl -X GET "http://localhost:8080/api/v1/appointments/doctor/dashboard" \
  -H "Authorization: Bearer <token>"

Response:
{
  "success": true,
  "message": "Statistics retrieved successfully",
  "data": {
    "todayCount": 5,
    "upcomingCount": 12,
    "totalPatients": 87,
    "pendingCount": 3
  }
}
```

**Statistics**:
- `todayCount`: Number of appointments scheduled for today (excluding cancelled/no-show)
- `upcomingCount`: Number of future scheduled or confirmed appointments
- `totalPatients`: Total number of unique completed patients
- `pendingCount`: Number of appointments in 'scheduled' status (not yet confirmed)

Rate limit: 60 requests per minute

**Authentication**: Requires JWT token and doctor role

**Caching**: Results cached in Redis for 5 minutes

#### Accept Appointment

```
POST /api/v1/appointments/:id/accept

Example Request:
curl -X POST "http://localhost:8080/api/v1/appointments/appointment_uuid/accept" \
  -H "Authorization: Bearer <token>"

Response:
{
  "success": true,
  "message": "Appointment accepted successfully",
  "data": {
    "id": "uuid",
    "status": "confirmed",
    "scheduledStart": "2024-12-15T09:00:00.000Z",
    "scheduledEnd": "2024-12-15T09:30:00.000Z"
  }
}
```

Rate limit: 10 requests per hour

**Authentication**: Requires JWT token and doctor role

**Validation**:
- Appointment must belong to the authenticated doctor
- Only appointments with status 'scheduled' can be accepted
- Status will be changed to 'confirmed'

**Error Responses**:
- 400: Invalid appointment ID format
- 403: Access denied (not your appointment)
- 404: Appointment not found
- 409: Cannot accept appointment (invalid status)

#### Reschedule Appointment

```
POST /api/v1/appointments/:id/reschedule
Content-Type: application/json

Request Body:
{
  "scheduledStart": "2024-12-15T10:00:00.000Z",
  "scheduledEnd": "2024-12-15T10:30:00.000Z"
}

Example Request:
curl -X POST "http://localhost:8080/api/v1/appointments/appointment_uuid/reschedule" \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "scheduledStart": "2024-12-15T10:00:00.000Z",
    "scheduledEnd": "2024-12-15T10:30:00.000Z"
  }'

Response:
{
  "success": true,
  "message": "Appointment rescheduled successfully",
  "data": {
    "id": "uuid",
    "scheduledStart": "2024-12-15T10:00:00.000Z",
    "scheduledEnd": "2024-12-15T10:30:00.000Z",
    "status": "scheduled"
  }
}
```

Rate limit: 10 requests per hour

**Authentication**: Requires JWT token and doctor role

**Validation**:
- Appointment must belong to the authenticated doctor
- Cannot reschedule completed, cancelled, or no-show appointments
- New time slot must be within doctor's working hours
- New time slot must not conflict with other appointments
- End time must be after start time (minimum 15 minutes duration)

**Availability Check**: Automatically validates that the new time slot is available using the same availability checking logic as appointment creation

**Error Responses**:
- 400: Invalid request body or time selection
- 403: Access denied (not your appointment)
- 404: Appointment not found
- 409: Time slot not available or conflict detected

**Cache Invalidation**: Clears appointment caches for doctor and patient when rescheduling succeeds

### Chat API

All chat endpoints are prefixed with `/api/v1/chat` and require authentication.

#### Get Conversations
```
GET /api/v1/chat/conversations?page=1&limit=20&type=direct
Authorization: Bearer <access_token>

Query parameters:
- page: Page number (default: 1)
- limit: Items per page (default: 20, max: 50)
- type: Conversation type (direct, group, channel)

Response:
{
  "success": true,
  "data": {
    "conversations": [
      {
        "id": "uuid",
        "type": "direct",
        "participant_ids": ["user1_id", "user2_id"],
        "created_by": "user1_id",
        "last_message_at": "2025-11-26T10:00:00Z",
        "metadata": {},
        "unread_count": 3,
        "participants": [
          {
            "id": "user2_id",
            "first_name": "John",
            "last_name": "Doe",
            "profile_picture": "url"
          }
        ],
        "last_message": {
          "id": "uuid",
          "content": "Hello!",
          "sender_id": "user2_id",
          "created_at": "2025-11-26T10:00:00Z"
        }
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 45,
      "pages": 3
    }
  }
}
```

Rate limit: 30 requests per minute

#### Get or Create Conversation
```
POST /api/v1/chat/conversations
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "type": "direct",  // or "group", "channel"
  "participant_ids": ["user2_id"],
  "metadata": {
    "name": "Support Group",  // optional for group/channel
    "description": "Description"  // optional
  }
}

Response: Same structure as conversation object above
```

Rate limit: 20 requests per minute

#### Get Conversation Messages
```
GET /api/v1/chat/conversations/:conversationId/messages?page=1&limit=50
Authorization: Bearer <access_token>

Response:
{
  "success": true,
  "data": {
    "messages": [
      {
        "id": "uuid",
        "conversation_id": "conversation_uuid",
        "sender_id": "user_id",
        "parent_message_id": null,
        "message_type": "text",  // text, image, file, system
        "content": "Hello!",
        "metadata": {},
        "read_by": ["user1_id"],
        "delivered_to": ["user1_id", "user2_id"],
        "is_edited": false,
        "is_deleted": false,
        "created_at": "2025-11-26T10:00:00Z",
        "updated_at": "2025-11-26T10:00:00Z",
        "sender": {
          "id": "user_id",
          "first_name": "Jane",
          "last_name": "Smith"
        }
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 50,
      "total": 150,
      "pages": 3
    }
  }
}
```

Rate limit: 60 requests per minute

#### Send Message
```
POST /api/v1/chat/conversations/:conversationId/messages
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "message_type": "text",
  "content": "Hello there!",
  "parent_message_id": "uuid",  // optional for replies
  "metadata": {
    "attachment_url": "https://...",  // optional
    "file_name": "document.pdf",
    "file_size": 1024
  }
}

Response: Message object (same structure as above)
```

Rate limit: 60 requests per minute

#### Mark Messages as Read
```
POST /api/v1/chat/conversations/:conversationId/read
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "message_ids": ["message1_id", "message2_id"]
}

Response:
{
  "success": true,
  "message": "Messages marked as read"
}
```

Rate limit: 60 requests per minute

#### Delete Message
```
DELETE /api/v1/chat/messages/:messageId
Authorization: Bearer <access_token>

Response:
{
  "success": true,
  "message": "Message deleted successfully"
}
```

Rate limit: 30 requests per minute

#### Update FCM Token
```
POST /api/v1/auth/fcm-token
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "fcm_token": "firebase_cloud_messaging_token"
}

Response:
{
  "success": true,
  "message": "FCM token updated successfully"
}
```

Rate limit: 10 requests per minute

### Socket.io Real-time Events

Connect to the WebSocket server using Socket.io client:

```javascript
const socket = io('http://localhost:8080', {
  auth: {
    token: 'your_jwt_token'
  }
});
```

#### Client → Server Events

**join_conversation**
```javascript
socket.emit('join_conversation', { conversationId: 'uuid' });
```

**leave_conversation**
```javascript
socket.emit('leave_conversation', { conversationId: 'uuid' });
```

**send_message**
```javascript
socket.emit('send_message', {
  conversationId: 'uuid',
  message_type: 'text',
  content: 'Hello!',
  parent_message_id: 'uuid',  // optional
  metadata: {}
});
```

**typing_start**
```javascript
socket.emit('typing_start', { conversationId: 'uuid' });
```

**typing_stop**
```javascript
socket.emit('typing_stop', { conversationId: 'uuid' });
```

**mark_delivered**
```javascript
socket.emit('mark_delivered', {
  conversationId: 'uuid',
  messageIds: ['msg1', 'msg2']
});
```

**mark_read**
```javascript
socket.emit('mark_read', {
  conversationId: 'uuid',
  messageIds: ['msg1', 'msg2']
});
```

#### Server → Client Events

**new_message**
```javascript
socket.on('new_message', (message) => {
  console.log('New message:', message);
  // Message structure: { id, conversation_id, sender_id, content, ... }
});
```

**message_delivered**
```javascript
socket.on('message_delivered', ({ messageId, userId }) => {
  console.log('Message delivered to:', userId);
});
```

**message_read**
```javascript
socket.on('message_read', ({ messageId, userId }) => {
  console.log('Message read by:', userId);
});
```

**user_typing**
```javascript
socket.on('user_typing', ({ conversationId, userId, isTyping }) => {
  console.log('User typing:', userId, isTyping);
});
```

**user_online**
```javascript
socket.on('user_online', ({ userId }) => {
  console.log('User online:', userId);
});
```

**user_offline**
```javascript
socket.on('user_offline', ({ userId, lastSeen }) => {
  console.log('User offline:', userId, 'Last seen:', lastSeen);
});
```

**error**
```javascript
socket.on('error', ({ message }) => {
  console.error('Socket error:', message);
});
```

### Push Notifications

The backend sends Firebase Cloud Messaging (FCM) push notifications when:
- A user receives a new message while offline
- A user receives a message in a conversation they haven't joined

Notification payload:
```json
{
  "notification": {
    "title": "John Doe",
    "body": "Hello there!"
  },
  "data": {
    "type": "new_message",
    "conversation_id": "uuid",
    "message_id": "uuid",
    "sender_id": "uuid"
  }
}
```

## Real-time Features

### Chat System

The chat system provides:
- **Direct messaging** between two users
- **Group conversations** with multiple participants
- **Real-time messaging** via Socket.io WebSockets
- **Message delivery & read receipts**
- **Typing indicators**
- **Online/offline presence tracking**
- **Push notifications** for offline users via FCM
- **Message history** with pagination
- **Redis caching** for conversations and messages

**Database Schema**:
- `conversations`: Stores conversation metadata with GIN index on participant_ids
- `messages`: Stores messages with composite index on (conversation_id, created_at)
- `users.fcm_token`: Stores FCM tokens for push notifications

**Performance Features**:
- Redis caching with 10-minute TTL for conversations
- Redis caching with 5-minute TTL for messages
- Efficient pagination with cursor-based loading
- Background push notification delivery
- Connection pooling for Socket.io

**Security Features**:
- JWT authentication for Socket.io connections
- Participant verification before message access
- Rate limiting on all endpoints
- Content validation and sanitization
- SQL injection prevention via Sequelize ORM

For detailed implementation guide, see [CHAT_IMPLEMENTATION_GUIDE.md](./CHAT_IMPLEMENTATION_GUIDE.md).
