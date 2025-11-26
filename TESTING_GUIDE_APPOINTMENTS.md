# Quick Testing Guide - Appointment Booking Verification

## Backend Testing

### 1. Test Working Hours Logic
```bash
# Test doctor availability with single shift per day
curl -X GET "http://localhost:3000/api/v1/doctors/{doctorId}/availability?date=2025-11-27&duration=30" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Expected: Array of time slots respecting single shift window per day
# Should return [] if day.available is false
```

### 2. Test Patient ID Derivation
```bash
# Create appointment - should use correct patient.id (not user.id)
curl -X POST "http://localhost:3000/api/v1/appointments" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "doctorId": "doctor-uuid",
    "appointmentType": "telehealth",
    "scheduledStart": "2025-11-27T10:00:00Z",
    "scheduledEnd": "2025-11-27T10:30:00Z",
    "reasonForVisit": "Annual checkup",
    "urgent": false
  }'

# Expected: 201 Created with appointment object
# Or 400 if no patient profile exists for user
```

### 3. Test Appointment Type Validation
```bash
# Valid types: telehealth, in_person, phone
curl -X POST "http://localhost:3000/api/v1/appointments" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "doctorId": "doctor-uuid",
    "appointmentType": "consultation",
    "scheduledStart": "2025-11-27T10:00:00Z",
    "scheduledEnd": "2025-11-27T10:30:00Z",
    "reasonForVisit": "Test"
  }'

# Expected: 400 Bad Request with validation error
```

### 4. Test Cache Consistency
```bash
# First request (from DB)
curl -X GET "http://localhost:3000/api/v1/appointments/{appointmentId}" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Second request (from cache) - should be identical
curl -X GET "http://localhost:3000/api/v1/appointments/{appointmentId}" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Both should have same structure with doctor.user and patient.user associations
```

## Mobile Testing

### 1. Flutter Analyze
```bash
cd mobile
flutter analyze
# Expected: No issues found!
```

### 2. Build Test
```bash
cd mobile
flutter build apk --debug
# or
flutter build ios --debug --no-codesign
# Expected: Build succeeds without errors
```

### 3. Unit Tests (if available)
```bash
cd mobile
flutter test
```

## Manual Integration Test Scenarios

### Scenario 1: Complete Booking Flow
1. **Login as Patient**
   - Use mobile app to authenticate
   - Verify patient profile exists

2. **Search for Doctor**
   - Navigate to doctor search
   - Select a doctor with availability

3. **Select Time Slot**
   - Choose date (working day for selected doctor)
   - Verify time slots appear
   - Select appointment type: Telehealth, In-Person, or Phone
   - Fill reason for visit

4. **Confirm Booking**
   - Review appointment details
   - Submit booking
   - Verify success message
   - Check appointment appears in list

5. **View Appointment**
   - Navigate to appointment list
   - Tap appointment card
   - Verify all fields display correctly:
     - doctorName
     - specialty
     - statusLabel
     - Date and time
     - Type icon

### Scenario 2: Appointment Cancellation
1. **View Appointment Details**
   - Navigate to appointment detail screen
   - Verify "Cancel" button appears for upcoming appointments

2. **Cancel Appointment**
   - Tap cancel button
   - Enter cancellation reason
   - Submit cancellation
   - Verify status updates to "Cancelled"

3. **Verify Cache Invalidation**
   - Refresh appointment list
   - Verify cancelled appointment shows correct status

### Scenario 3: Reschedule Attempt
1. **View Appointment Details**
   - Navigate to appointment with canBeRescheduled = true

2. **Attempt Reschedule**
   - Tap "Reschedule" button
   - Verify "Coming soon" message appears
   - Verify no errors or crashes

### Scenario 4: Working Hours Edge Cases
1. **Weekend Availability**
   - Try to book on weekend (if doctor not available)
   - Verify no slots appear or appropriate message

2. **After Hours**
   - Try to book outside working hours
   - Verify slots only within defined window

3. **Same-Day Booking**
   - Try to book for today
   - Verify only future slots appear

## Backend Unit Tests to Run

```bash
cd backend
npm test

# Specific test suites to verify:
npm test -- appointmentService.test.js
npm test -- appointmentController.test.js
npm test -- auth.middleware.test.js
```

## Expected Test Coverage

### appointmentService.js
- ✅ checkDoctorAvailability with single shift object
- ✅ checkDoctorAvailability with available=false
- ✅ getAvailableTimeSlots respects working_hours schema
- ✅ createAppointment returns plain object
- ✅ getAppointmentById returns consistent cached/non-cached data
- ✅ getPatientAppointments uses correct patient_id

### appointmentController.js
- ✅ createAppointment validates appointmentType enum
- ✅ createAppointment requires valid patientId
- ✅ getMyAppointments uses req.user.patientId

### auth.js middleware
- ✅ authenticate attaches patientId for patient role
- ✅ authenticate attaches doctorId for doctor role
- ✅ authenticate fails if patient/doctor profile missing

## Common Issues to Check

1. **Time Zone Handling**
   - Verify all dates in ISO8601 format
   - Check server and client time zone alignment

2. **Null Safety**
   - Test with missing optional fields (chiefComplaint, notes)
   - Verify nullable annotations in Dart match backend

3. **Pagination**
   - Test hasMore boundary conditions
   - Verify page count calculations

4. **Rate Limiting**
   - Attempt rapid-fire requests
   - Verify rate limit responses (429)

5. **Error Messages**
   - Verify user-friendly error messages
   - Check error logging on backend

## Performance Checks

1. **Cache Hit Rate**
   - Monitor Redis for cache hits vs misses
   - Verify 5-minute TTL working correctly

2. **Database Queries**
   - Check for N+1 query issues
   - Verify eager loading of associations

3. **Mobile Responsiveness**
   - Test on slow network (throttle to 3G)
   - Verify loading states appear correctly

## Smoke Test Script

```bash
#!/bin/bash
# Quick smoke test for backend

BASE_URL="http://localhost:3000/api/v1"
TOKEN="your-test-token"

echo "Testing doctor availability..."
curl -s "$BASE_URL/doctors/test-doctor-id/availability?date=2025-11-27&duration=30" \
  -H "Authorization: Bearer $TOKEN" | jq .

echo "Testing appointment creation..."
curl -s -X POST "$BASE_URL/appointments" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "doctorId": "test-doctor-id",
    "appointmentType": "telehealth",
    "scheduledStart": "2025-11-27T10:00:00Z",
    "scheduledEnd": "2025-11-27T10:30:00Z",
    "reasonForVisit": "Smoke test",
    "urgent": false
  }' | jq .

echo "Testing appointment list..."
curl -s "$BASE_URL/appointments?page=1&limit=10" \
  -H "Authorization: Bearer $TOKEN" | jq .

echo "Smoke test complete!"
```

## Success Criteria

✅ All backend endpoints return expected status codes  
✅ All mobile screens load without errors  
✅ Booking flow completes end-to-end  
✅ Cached and non-cached responses identical  
✅ Patient ID correctly derived from user  
✅ Appointment types validated correctly  
✅ Working hours logic handles single shift per day  
✅ No compile or runtime errors in mobile app  
✅ Error messages are user-friendly  
✅ Rate limits enforced correctly  

---

**Ready for Production** when all criteria met! 🚀
