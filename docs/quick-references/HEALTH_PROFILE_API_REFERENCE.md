# Health Profile API Quick Reference

## Base URL
```
/api/v1/health-profiles
```

## Authentication
All endpoints require:
- **Header:** `Authorization: Bearer {access_token}`
- **Role:** `patient` only

## Rate Limit
- **Limit:** 10 requests per minute per user
- **Headers:** `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`

---

## Endpoints

### 1. Get My Health Profile
```http
GET /me
```

**Response (200):**
```json
{
  "success": true,
  "message": "Health profile retrieved successfully",
  "data": {
    "id": "uuid",
    "patient_id": "uuid",
    "blood_type": "A+",
    "height": 175.5,
    "weight": 70.0,
    "allergies": [...],
    "chronic_conditions": [...],
    "current_medications": [...],
    "lifestyle": {...},
    "emergency_contact_name": "John Doe",
    "emergency_contact_phone": "+1234567890",
    "emergency_contact_relationship": "Spouse",
    "preferred_pharmacy": "CVS Pharmacy",
    "insurance_provider": "Blue Cross",
    "insurance_id": "BC123456",
    "notes": "Regular checkups needed",
    "created_at": "2025-01-01T00:00:00.000Z",
    "updated_at": "2025-11-26T00:00:00.000Z"
  }
}
```

**Error (404):**
```json
{
  "success": false,
  "message": "Health profile not found. Please create one first."
}
```

---

### 2. Create Health Profile
```http
POST /
Content-Type: application/json
```

**Request Body:**
```json
{
  "bloodType": "A+",
  "height": 175,
  "weight": 70,
  "allergies": [
    {
      "allergen": "Peanuts",
      "severity": "severe",
      "notes": "Anaphylaxis risk"
    }
  ],
  "chronicConditions": [
    {
      "name": "Asthma",
      "diagnosedDate": "2020-05-15",
      "severity": "mild",
      "medications": ["Albuterol"],
      "notes": "Exercise-induced"
    }
  ],
  "currentMedications": [
    {
      "name": "Lisinopril",
      "dosage": "10mg",
      "frequency": "Once daily",
      "startDate": "2024-01-01",
      "prescribedBy": "Dr. Smith"
    }
  ],
  "lifestyle": {
    "smoking": "never",
    "alcohol": "occasional",
    "exerciseFrequency": "moderate",
    "diet": "vegetarian"
  },
  "emergencyContactName": "Jane Doe",
  "emergencyContactPhone": "+1234567890",
  "emergencyContactRelationship": "Spouse",
  "preferredPharmacy": "CVS Pharmacy",
  "insuranceProvider": "Blue Cross",
  "insuranceId": "BC123456",
  "notes": "Allergic to latex"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Health profile created successfully",
  "data": {...}
}
```

**Error (409):**
```json
{
  "success": false,
  "message": "Health profile already exists for this patient"
}
```

**Error (400):**
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": [
    {
      "field": "height",
      "message": "Height must be at least 30 cm"
    }
  ]
}
```

---

### 3. Update Health Profile
```http
PATCH /me
Content-Type: application/json
```

**Request Body (all fields optional):**
```json
{
  "bloodType": "A+",
  "height": 176,
  "weight": 72.5,
  "notes": "Updated notes"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Health profile updated successfully",
  "data": {...}
}
```

---

### 4. Add Chronic Condition
```http
POST /me/chronic-conditions
Content-Type: application/json
```

**Request Body:**
```json
{
  "name": "Type 2 Diabetes",
  "diagnosedDate": "2023-01-15",
  "severity": "moderate",
  "medications": ["Metformin 500mg", "Insulin"],
  "notes": "Monitor blood sugar regularly"
}
```

**Field Validations:**
- `name`: Required, 2-200 characters
- `diagnosedDate`: Optional, cannot be in future
- `severity`: Required, one of: `mild`, `moderate`, `severe`
- `medications`: Optional array of strings
- `notes`: Optional, max 1000 characters

**Response (200):**
```json
{
  "success": true,
  "message": "Chronic condition added successfully",
  "data": {...}
}
```

---

### 5. Remove Chronic Condition
```http
DELETE /me/chronic-conditions/:conditionId
```

**Path Parameters:**
- `conditionId`: Condition ID (timestamp-based string)

**Response (200):**
```json
{
  "success": true,
  "message": "Chronic condition removed successfully",
  "data": {...}
}
```

---

### 6. Add Allergy
```http
POST /me/allergies
Content-Type: application/json
```

**Request Body:**
```json
{
  "allergen": "Penicillin",
  "severity": "life-threatening",
  "notes": "Causes anaphylaxis"
}
```

**Field Validations:**
- `allergen`: Required, 2-200 characters
- `severity`: Required, one of: `mild`, `moderate`, `severe`, `life-threatening`
- `notes`: Optional, max 500 characters

**Response (200):**
```json
{
  "success": true,
  "message": "Allergy added successfully",
  "data": {...}
}
```

---

### 7. Remove Allergy
```http
DELETE /me/allergies/:allergen
```

**Path Parameters:**
- `allergen`: Allergen name (URL-encoded)

**Example:**
```
DELETE /me/allergies/Penicillin
DELETE /me/allergies/Bee%20Stings
```

**Response (200):**
```json
{
  "success": true,
  "message": "Allergy removed successfully",
  "data": {...}
}
```

---

### 8. Update Vitals
```http
PATCH /me/vitals
Content-Type: application/json
```

**Request Body (at least one field required):**
```json
{
  "height": 176,
  "weight": 72.5,
  "bloodType": "A+"
}
```

**Field Validations:**
- `height`: 30-300 cm
- `weight`: 1-1000 kg
- `bloodType`: One of: `A+`, `A-`, `B+`, `B-`, `AB+`, `AB-`, `O+`, `O-`

**Response (200):**
```json
{
  "success": true,
  "message": "Vitals updated successfully",
  "data": {...}
}
```

---

## Data Models

### Blood Types
```javascript
['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
```

### Allergy Severity
```javascript
['mild', 'moderate', 'severe', 'life-threatening']
```

### Condition Severity
```javascript
['mild', 'moderate', 'severe']
```

### Lifestyle - Smoking
```javascript
['never', 'former', 'current', 'occasional']
```

### Lifestyle - Alcohol
```javascript
['never', 'occasional', 'moderate', 'heavy']
```

### Lifestyle - Exercise Frequency
```javascript
['sedentary', 'light', 'moderate', 'active', 'very-active']
```

### Lifestyle - Diet
```javascript
['omnivore', 'vegetarian', 'vegan', 'pescatarian', 'other']
```

---

## Common Errors

### 401 Unauthorized
```json
{
  "error": "Authentication required",
  "message": "Bearer token not provided"
}
```

### 403 Forbidden
```json
{
  "error": "Access denied",
  "message": "Insufficient permissions. Required role: patient"
}
```

### 404 Not Found
```json
{
  "success": false,
  "message": "Health profile not found"
}
```

### 429 Too Many Requests
```json
{
  "message": "Too many requests to health profile API, please try again later"
}
```

### 500 Internal Server Error
```json
{
  "success": false,
  "message": "Failed to create health profile",
  "error": "Error details"
}
```

---

## Caching

- **Backend:** Redis cache with 5-minute TTL
- **Cache Key:** `health_profile:{patientId}`
- **Invalidation:** Automatic on any update/create operation
- **Cache Hit:** Logged as INFO
- **Cache Miss:** Logged as INFO, data fetched from DB and cached

---

## Best Practices

### 1. Initial Profile Creation
```javascript
// Create comprehensive profile on first use
POST /api/v1/health-profiles
{
  "bloodType": "A+",
  "height": 175,
  "weight": 70,
  "emergencyContactName": "Emergency Contact",
  "emergencyContactPhone": "+1234567890",
  "emergencyContactRelationship": "Spouse"
}
```

### 2. Incremental Updates
```javascript
// Update only changed fields
PATCH /api/v1/health-profiles/me
{
  "weight": 71
}
```

### 3. Managing Conditions
```javascript
// Add conditions individually for better tracking
POST /api/v1/health-profiles/me/chronic-conditions
{
  "name": "Hypertension",
  "diagnosedDate": "2024-01-15",
  "severity": "moderate"
}

// Remove by ID returned from add operation
DELETE /api/v1/health-profiles/me/chronic-conditions/1732614000000
```

### 4. Managing Allergies
```javascript
// Add allergies with severity
POST /api/v1/health-profiles/me/allergies
{
  "allergen": "Shellfish",
  "severity": "severe",
  "notes": "Causes hives and breathing difficulty"
}

// Remove by exact allergen name
DELETE /api/v1/health-profiles/me/allergies/Shellfish
```

### 5. Vitals Tracking
```javascript
// Update vitals separately for history tracking
PATCH /api/v1/health-profiles/me/vitals
{
  "weight": 72.5
}
```

---

## Mobile Integration Example

```dart
class HealthProfileService {
  final ApiService _apiService;
  
  Future<ApiResponse<HealthProfile>> getHealthProfile() async {
    final response = await _apiService.get('/health-profiles/me');
    
    if (response.isSuccess) {
      final profile = HealthProfile.fromJson(response.data['data']);
      return ApiResponse.success(profile);
    }
    
    return ApiResponse.error(response.message);
  }
  
  Future<ApiResponse<HealthProfile>> createHealthProfile(
    Map<String, dynamic> data
  ) async {
    final response = await _apiService.post('/health-profiles', data);
    
    if (response.isSuccess) {
      final profile = HealthProfile.fromJson(response.data['data']);
      return ApiResponse.success(profile);
    }
    
    return ApiResponse.error(response.message);
  }
  
  Future<ApiResponse<HealthProfile>> updateVitals(
    double? height,
    double? weight,
    String? bloodType,
  ) async {
    final data = {};
    if (height != null) data['height'] = height;
    if (weight != null) data['weight'] = weight;
    if (bloodType != null) data['bloodType'] = bloodType;
    
    final response = await _apiService.patch('/health-profiles/me/vitals', data);
    
    if (response.isSuccess) {
      final profile = HealthProfile.fromJson(response.data['data']);
      return ApiResponse.success(profile);
    }
    
    return ApiResponse.error(response.message);
  }
}
```

---

## Testing with cURL

### Get Profile
```bash
curl -X GET \
  https://api.viatra.health/api/v1/health-profiles/me \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Create Profile
```bash
curl -X POST \
  https://api.viatra.health/api/v1/health-profiles \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "bloodType": "A+",
    "height": 175,
    "weight": 70,
    "emergencyContactName": "John Doe",
    "emergencyContactPhone": "+1234567890"
  }'
```

### Update Vitals
```bash
curl -X PATCH \
  https://api.viatra.health/api/v1/health-profiles/me/vitals \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "weight": 72
  }'
```

### Add Allergy
```bash
curl -X POST \
  https://api.viatra.health/api/v1/health-profiles/me/allergies \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "allergen": "Penicillin",
    "severity": "severe",
    "notes": "Anaphylaxis risk"
  }'
```

---

**Last Updated:** November 26, 2025  
**API Version:** 1.0.0  
**Status:** Production Ready
