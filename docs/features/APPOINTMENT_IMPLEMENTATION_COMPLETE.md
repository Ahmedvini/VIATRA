# Appointment System Implementation

## Overview

Complete implementation of the appointment booking and management system for the VIATRA Health Platform, enabling patients to book appointments with doctors and manage their healthcare schedules.

## Features Implemented

### Backend Implementation

#### 1. Database Models
- **Appointment Model** (`backend/src/models/Appointment.js`)
  - Patient and doctor relationship
  - Appointment types: telehealth, in-person, phone
  - Status tracking: scheduled, confirmed, in_progress, completed, cancelled, no_show
  - Time tracking: scheduled start/end, actual start/end
  - Additional fields: reason for visit, chief complaint, notes, urgency flag

#### 2. Controllers (`backend/src/controllers/appointmentController.js`)
- **Create Appointment**: Book new appointments with validation
- **Get Appointments**: List appointments with filters (status, date range, pagination)
- **Get Single Appointment**: Retrieve appointment details
- **Update Appointment**: Modify appointment details and status
- **Cancel Appointment**: Cancel appointments with reason tracking
- **Check Availability**: Verify doctor availability for booking
- **Get Available Slots**: Fetch available time slots for a doctor

#### 3. Services (`backend/src/services/appointmentService.js`)
- Business logic for appointment management
- Conflict detection and double-booking prevention
- Availability calculation
- Status transition validation
- Notification triggers

#### 4. Routes (`backend/src/routes/appointment.js`)
```
POST   /api/v1/appointments              - Create appointment
GET    /api/v1/appointments              - List appointments
GET    /api/v1/appointments/:id          - Get appointment details
PUT    /api/v1/appointments/:id          - Update appointment
DELETE /api/v1/appointments/:id          - Cancel appointment
GET    /api/v1/appointments/doctor/:doctorId/availability  - Check availability
GET    /api/v1/appointments/doctor/:doctorId/slots         - Get available slots
```

#### 5. Validation
- **Joi schemas** for all endpoints
- Date/time validation (appointments must be in future)
- Duration validation (end time after start time)
- Status transition validation
- Required fields enforcement

### Mobile Implementation

#### 1. Screens (`mobile/lib/screens/appointments/`)
- **Appointment List Screen**: View all appointments
- **Appointment Booking Screen**: Book new appointments
- **Appointment Details Screen**: View and manage appointment details
- **Doctor Availability Screen**: Check doctor availability

#### 2. Provider (`mobile/lib/providers/appointment_provider.dart`)
- State management for appointments
- API integration
- Real-time updates
- Error handling
- Loading states

#### 3. Models (`mobile/lib/models/`)
- Appointment model with serialization
- Status enums
- Type enums
- Validation helpers

#### 4. Widgets (`mobile/lib/widgets/appointments/`)
- Appointment card
- Status badge
- Time slot picker
- Booking form components
- Cancellation dialog

## API Endpoints

### Create Appointment
```http
POST /api/v1/appointments
Authorization: Bearer <token>

{
  "doctorId": "uuid",
  "appointmentType": "telehealth|in_person|phone",
  "scheduledStart": "2024-01-15T10:00:00Z",
  "scheduledEnd": "2024-01-15T10:30:00Z",
  "reasonForVisit": "Annual checkup",
  "chiefComplaint": "Optional detailed complaint",
  "urgent": false
}
```

### List Appointments
```http
GET /api/v1/appointments?status=scheduled&page=1&limit=20
Authorization: Bearer <token>
```

### Get Appointment Details
```http
GET /api/v1/appointments/:id
Authorization: Bearer <token>
```

### Update Appointment
```http
PUT /api/v1/appointments/:id
Authorization: Bearer <token>

{
  "status": "confirmed",
  "notes": "Patient confirmed via phone"
}
```

### Cancel Appointment
```http
DELETE /api/v1/appointments/:id
Authorization: Bearer <token>

{
  "cancellationReason": "Patient emergency"
}
```

### Check Doctor Availability
```http
GET /api/v1/appointments/doctor/:doctorId/availability?date=2024-01-15&duration=30
Authorization: Bearer <token>
```

## Business Rules

1. **Booking Window**: Appointments can only be booked for future dates
2. **Conflict Prevention**: System checks for overlapping appointments
3. **Status Transitions**: Only valid status changes allowed
4. **Cancellation Policy**: Appointments can be cancelled before start time
5. **Duration Limits**: Appointments must be between 15-120 minutes
6. **Availability**: Doctors must have availability slots configured

## Testing

### Backend Tests
```bash
cd backend
npm test -- appointment
```

### Mobile Tests
```bash
cd mobile
flutter test test/appointment_test.dart
```

### Integration Tests
```bash
cd mobile
flutter test integration_test/appointment_flow_test.dart
```

## Database Schema

```sql
CREATE TABLE appointments (
  id UUID PRIMARY KEY,
  patient_id UUID REFERENCES patients(id),
  doctor_id UUID REFERENCES doctors(id),
  appointment_type VARCHAR(20),
  status VARCHAR(20),
  scheduled_start TIMESTAMP,
  scheduled_end TIMESTAMP,
  actual_start TIMESTAMP,
  actual_end TIMESTAMP,
  reason_for_visit TEXT,
  chief_complaint TEXT,
  notes TEXT,
  urgent BOOLEAN,
  cancelled_at TIMESTAMP,
  cancellation_reason TEXT,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

## Future Enhancements

- [ ] Recurring appointments
- [ ] Appointment reminders (email/SMS)
- [ ] Video conferencing integration for telehealth
- [ ] Automated rescheduling suggestions
- [ ] Waitlist management
- [ ] Calendar integration (Google, Apple)
- [ ] No-show tracking and penalties
- [ ] Advanced scheduling rules (buffer times, etc.)

## Dependencies

### Backend
- `joi`: Validation
- `sequelize`: ORM
- `date-fns`: Date manipulation

### Mobile
- `provider`: State management
- `http`: API calls
- `intl`: Date formatting

## Documentation Links

- [API Documentation](../api/APPOINTMENT_API.md)
- [Testing Guide](../TESTING_GUIDE.md)
- [Deployment Guide](../DEPLOYMENT.md)

---

**Status**: ✅ Complete  
**Last Updated**: November 2024  
**Maintained By**: Platform Team
