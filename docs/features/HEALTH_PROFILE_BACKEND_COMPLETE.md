# Health Profile Implementation

## Overview

Complete implementation of the health profile system for VIATRA Health Platform, enabling patients to manage their medical history, chronic conditions, allergies, medications, and vital signs.

## Features Implemented

### Backend Implementation

#### 1. Database Model (`backend/src/models/HealthProfile.js`)

**Core Fields**:
- Patient relationship (one-to-one)
- Blood type
- Height and weight
- Emergency contact information
- Chronic conditions (JSONB array)
- Allergies (JSONB array)
- Current medications (JSONB array)
- Past surgeries (JSONB array)
- Family history (JSONB)
- Lifestyle information (JSONB)
- Vital signs history (JSONB array)

**Data Structures**:
```javascript
{
  "chronic_conditions": [
    {
      "condition": "Hypertension",
      "diagnosedDate": "2020-01-15",
      "status": "active",
      "notes": "Controlled with medication"
    }
  ],
  "allergies": [
    {
      "allergen": "Penicillin",
      "severity": "severe",
      "reaction": "Anaphylaxis",
      "diagnosedDate": "2015-06-20"
    }
  ],
  "medications": [
    {
      "name": "Lisinopril",
      "dosage": "10mg",
      "frequency": "once daily",
      "startDate": "2020-01-20",
      "prescribedBy": "Dr. Smith"
    }
  ]
}
```

#### 2. Controllers (`backend/src/controllers/healthProfileController.js`)

**Endpoints**:
- `getMyHealthProfile`: Retrieve authenticated patient's profile
- `createHealthProfile`: Create new health profile
- `updateHealthProfile`: Update existing profile
- `addChronicCondition`: Add chronic condition
- `updateChronicCondition`: Update chronic condition
- `removeChronicCondition`: Remove chronic condition
- `addAllergy`: Add allergy
- `updateAllergy`: Update allergy
- `removeAllergy`: Remove allergy
- `addMedication`: Add current medication
- `updateMedication`: Update medication
- `removeMedication`: Remove medication
- `addVitals`: Record vital signs
- `getVitalsHistory`: Retrieve vitals history

#### 3. Services (`backend/src/services/healthProfileService.js`)
- Business logic for health data management
- Validation of medical data
- History tracking for vital signs
- CRUD operations for nested data
- Privacy and security handling

#### 4. Validation (`backend/src/utils/validators.js`)
- Joi schemas for all health data types
- Blood type validation
- Allergy severity validation
- Medication frequency validation
- Vital signs range validation

#### 5. Routes (`backend/src/routes/healthProfile.js`)
```
GET    /api/v1/health-profile              - Get my health profile
POST   /api/v1/health-profile              - Create health profile
PUT    /api/v1/health-profile              - Update health profile
POST   /api/v1/health-profile/conditions   - Add chronic condition
PUT    /api/v1/health-profile/conditions/:id - Update condition
DELETE /api/v1/health-profile/conditions/:id - Remove condition
POST   /api/v1/health-profile/allergies    - Add allergy
PUT    /api/v1/health-profile/allergies/:id - Update allergy
DELETE /api/v1/health-profile/allergies/:id - Remove allergy
POST   /api/v1/health-profile/medications  - Add medication
PUT    /api/v1/health-profile/medications/:id - Update medication
DELETE /api/v1/health-profile/medications/:id - Remove medication
POST   /api/v1/health-profile/vitals       - Add vitals
GET    /api/v1/health-profile/vitals/history - Get vitals history
```

### Mobile Implementation

#### 1. Screens (`mobile/lib/screens/health_profile/`)
- **Health Profile Overview**: Summary view with all sections
- **Edit Profile Screen**: Update basic health information
- **Chronic Conditions Screen**: Manage chronic conditions
- **Allergies Screen**: Manage allergies
- **Medications Screen**: Manage current medications
- **Vitals Screen**: Record and view vital signs
- **History Screen**: View medical history

#### 2. Provider (`mobile/lib/providers/health_profile_provider.dart`)
- State management for health profile data
- API integration
- Local caching
- Real-time updates
- Error handling
- Form validation

#### 3. Models (`mobile/lib/models/health_profile.dart`)
- HealthProfile main model
- ChronicCondition model
- Allergy model
- Medication model
- VitalSigns model
- JSON serialization

#### 4. Widgets (`mobile/lib/widgets/health_profile/`)
- **Profile Summary Card**: Overview widget
- **Condition Card**: Chronic condition display
- **Allergy Card**: Allergy display with severity badge
- **Medication Card**: Medication display with schedule
- **Vitals Chart**: Visual representation of vitals
- **Add/Edit Forms**: Forms for each data type

## API Endpoints

### Get Health Profile
```http
GET /api/v1/health-profile
Authorization: Bearer <token>

Response:
{
  "success": true,
  "data": {
    "id": "uuid",
    "patientId": "uuid",
    "bloodType": "A+",
    "height": 175,
    "weight": 70,
    "chronicConditions": [...],
    "allergies": [...],
    "medications": [...],
    "vitals": {...}
  }
}
```

### Create Health Profile
```http
POST /api/v1/health-profile
Authorization: Bearer <token>

{
  "bloodType": "A+",
  "height": 175,
  "weight": 70,
  "emergencyContact": {
    "name": "John Doe",
    "relationship": "Spouse",
    "phone": "+1234567890"
  }
}
```

### Add Chronic Condition
```http
POST /api/v1/health-profile/conditions
Authorization: Bearer <token>

{
  "condition": "Diabetes Type 2",
  "diagnosedDate": "2020-01-15",
  "status": "active",
  "notes": "Managed with diet and exercise"
}
```

### Add Allergy
```http
POST /api/v1/health-profile/allergies
Authorization: Bearer <token>

{
  "allergen": "Penicillin",
  "severity": "severe",
  "reaction": "Anaphylaxis",
  "diagnosedDate": "2015-06-20"
}
```

### Record Vitals
```http
POST /api/v1/health-profile/vitals
Authorization: Bearer <token>

{
  "bloodPressureSystolic": 120,
  "bloodPressureDiastolic": 80,
  "heartRate": 72,
  "temperature": 36.6,
  "weight": 70,
  "oxygenSaturation": 98,
  "recordedAt": "2024-01-15T10:00:00Z"
}
```

## Data Models

### Blood Types
- A+, A-, B+, B-, AB+, AB-, O+, O-

### Allergy Severity
- `mild`: Minor discomfort
- `moderate`: Noticeable symptoms
- `severe`: Life-threatening

### Medication Frequency
- `once_daily`, `twice_daily`, `three_times_daily`
- `every_x_hours`, `as_needed`, `weekly`, `monthly`

### Condition Status
- `active`: Currently present
- `in_remission`: Temporarily inactive
- `resolved`: No longer present

### Vital Signs Ranges
- **Blood Pressure**: 90-180 (systolic), 60-120 (diastolic) mmHg
- **Heart Rate**: 40-200 bpm
- **Temperature**: 35-42°C
- **Oxygen Saturation**: 70-100%
- **Weight**: 20-300 kg
- **Height**: 50-250 cm

## Business Rules

1. **One Profile Per Patient**: Each patient has exactly one health profile
2. **Required Fields**: Blood type and emergency contact
3. **Historical Data**: All changes tracked with timestamps
4. **Privacy**: Only patient and their doctors can access
5. **Validation**: Medical data validated for safety
6. **Completeness**: Profile completeness score calculated

## Security & Privacy

1. **Access Control**: Patient-only access (unless shared with doctor)
2. **Data Encryption**: Sensitive medical data encrypted at rest
3. **Audit Logging**: All access and modifications logged
4. **HIPAA Compliance**: Medical data handling compliant
5. **Consent Management**: Explicit consent for data sharing

## Testing

### Backend Tests
```bash
cd backend
npm test -- healthProfile
```

### Mobile Tests
```bash
cd mobile
flutter test test/health_profile_test.dart
```

### Integration Tests
```bash
cd mobile
flutter test integration_test/health_profile_test.dart
```

## Database Schema

```sql
CREATE TABLE health_profiles (
  id UUID PRIMARY KEY,
  patient_id UUID UNIQUE REFERENCES patients(id),
  blood_type VARCHAR(10),
  height DECIMAL(5,2),
  weight DECIMAL(5,2),
  emergency_contact JSONB,
  chronic_conditions JSONB,
  allergies JSONB,
  medications JSONB,
  past_surgeries JSONB,
  family_history JSONB,
  lifestyle JSONB,
  vitals_history JSONB,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

CREATE INDEX idx_health_profiles_patient ON health_profiles(patient_id);
```

## Future Enhancements

- [ ] Lab results integration
- [ ] Immunization records
- [ ] Insurance information
- [ ] Medical device data (wearables)
- [ ] PDF export of health summary
- [ ] Doctor notes/observations
- [ ] Prescription history
- [ ] Imaging results (X-rays, MRI, etc.)
- [ ] Health goals and tracking
- [ ] Integration with Apple Health / Google Fit

## Dependencies

### Backend
- `joi`: Validation
- `sequelize`: ORM

### Mobile
- `provider`: State management
- `fl_chart`: Vitals visualization
- `intl`: Date formatting

## Documentation Links

- [API Documentation](../api/HEALTH_PROFILE_API.md)
- [Testing Guide](../TESTING_GUIDE.md)
- [Privacy Policy](../legal/PRIVACY_POLICY.md)

---

**Status**: ✅ Complete  
**Last Updated**: November 2024  
**Maintained By**: Platform Team
