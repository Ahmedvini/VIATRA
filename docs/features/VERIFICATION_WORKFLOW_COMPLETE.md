# Doctor Verification Workflow - Complete Implementation

## Overview

Comprehensive doctor verification system for VIATRA Health Platform, enabling secure document submission, admin review, approval/rejection workflow, and compliance with medical licensing requirements.

## Features Implemented

### Backend Implementation

#### 1. Verification Model (`backend/src/models/Verification.js`)

**Fields**:
- `userId`: Reference to User
- `type`: Document type (medical_license, government_id, certification, degree, etc.)
- `status`: pending, approved, rejected, expired
- `documentUrl`: GCS storage URL
- `originalFileName`: Original file name
- `description`: Optional description
- `reviewedBy`: Admin user ID
- `reviewedAt`: Review timestamp
- `rejectionReason`: Reason for rejection (if rejected)
- `expiryDate`: Document expiration date
- `metadata`: Additional JSON data

**Document Types**:
```javascript
const DOCUMENT_TYPES = {
  MEDICAL_LICENSE: 'medical_license',      // Required
  GOVERNMENT_ID: 'government_id',          // Required
  MEDICAL_DEGREE: 'medical_degree',        // Required
  BOARD_CERTIFICATION: 'board_certification', // Optional
  MALPRACTICE_INSURANCE: 'malpractice_insurance', // Required
  DEA_LICENSE: 'dea_license',             // Optional (for prescribing)
  STATE_LICENSE: 'state_license',          // Required per state
  CV_RESUME: 'cv_resume',                  // Optional
};
```

#### 2. Verification Controller (`backend/src/controllers/verificationController.js`)

**Endpoints**:
- `POST /api/v1/verification/submit`: Upload verification document
- `GET /api/v1/verification/status`: Get user's verification status
- `GET /api/v1/verification/document/:id`: Get specific document
- `PUT /api/v1/verification/document/:id`: Update document
- `DELETE /api/v1/verification/document/:id`: Delete document

**Admin Endpoints**:
- `GET /api/v1/verification/pending`: List pending verifications
- `PUT /api/v1/verification/:id/approve`: Approve verification
- `PUT /api/v1/verification/:id/reject`: Reject with reason
- `GET /api/v1/verification/stats`: Verification statistics

#### 3. Verification Service (`backend/src/services/verificationService.js`)

**Core Functions**:
- `uploadVerificationDocument()`: Store document and create record
- `getVerificationStatus()`: Get user's overall verification status
- `approveVerification()`: Admin approval
- `rejectVerification()`: Admin rejection with reason
- `getPendingVerifications()`: List for admin review
- `checkVerificationCompleteness()`: Calculate completion percentage
- `sendVerificationEmail()`: Notify user of status changes

**Business Logic**:
```javascript
// Verification completeness check
function calculateCompleteness(verifications) {
  const requiredDocs = [
    'medical_license',
    'government_id',
    'medical_degree',
    'malpractice_insurance'
  ];
  
  const approved = verifications.filter(v => 
    v.status === 'approved' && 
    requiredDocs.includes(v.type)
  );
  
  return {
    completed: approved.length,
    total: requiredDocs.length,
    percentage: (approved.length / requiredDocs.length) * 100,
    isComplete: approved.length === requiredDocs.length
  };
}
```

#### 4. File Upload (`backend/src/utils/fileUpload.js`)

**Features**:
- Google Cloud Storage integration
- File validation (type, size)
- Virus scanning
- Secure URLs with expiration
- Image compression
- PDF optimization

**Allowed File Types**:
- Images: JPG, PNG, PDF
- Documents: PDF only
- Max size: 10MB per file

### Mobile Implementation

#### 1. Screens (`mobile/lib/screens/verification/`)

**Document Upload Screen**:
- Document type selection
- File picker (camera/gallery/files)
- Upload progress
- Preview before upload
- Description input

**Verification Status Screen**:
- Overall verification progress
- List of submitted documents
- Status badges per document
- Re-upload for rejected documents
- View rejection reasons

**Document Viewer Screen**:
- Display uploaded document
- Download option
- Delete option
- Re-upload option

#### 2. Widgets (`mobile/lib/widgets/verification/`)

**Verification Status Card**:
```dart
class VerificationStatusCard extends StatelessWidget {
  final Verification verification;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: _getStatusIcon(verification.status),
        title: Text(_formatDocumentType(verification.type)),
        subtitle: Text(_getStatusText(verification.status)),
        trailing: _buildActions(verification),
      ),
    );
  }
}
```

**Upload Progress Widget**:
```dart
class UploadProgressWidget extends StatelessWidget {
  final double progress;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LinearProgressIndicator(value: progress),
        SizedBox(height: 8),
        Text('${(progress * 100).toInt()}% uploaded'),
      ],
    );
  }
}
```

#### 3. Provider (`mobile/lib/providers/verification_provider.dart`)

**State Management**:
- List of verifications
- Upload progress
- Overall verification status
- Error handling

**Key Methods**:
- `submitDocument()`: Upload new document
- `getVerificationStatus()`: Fetch status
- `deleteDocument()`: Remove document
- `resubmitDocument()`: Re-upload rejected document

## API Endpoints

### Submit Document
```http
POST /api/v1/verification/submit
Authorization: Bearer <token>
Content-Type: multipart/form-data

{
  "file": <binary>,
  "type": "medical_license",
  "description": "California Medical License",
  "expiryDate": "2025-12-31"
}

Response:
{
  "success": true,
  "message": "Document submitted successfully",
  "data": {
    "id": "uuid",
    "type": "medical_license",
    "status": "pending",
    "url": "https://storage.googleapis.com/..."
  }
}
```

### Get Verification Status
```http
GET /api/v1/verification/status
Authorization: Bearer <token>

Response:
{
  "success": true,
  "data": {
    "verifications": [
      {
        "id": "uuid",
        "type": "medical_license",
        "status": "approved",
        "documentUrl": "...",
        "reviewedAt": "2024-01-15T10:00:00Z"
      }
    ],
    "completeness": {
      "completed": 3,
      "total": 4,
      "percentage": 75,
      "isComplete": false
    }
  }
}
```

### Admin: Get Pending Verifications
```http
GET /api/v1/verification/pending?page=1&limit=20
Authorization: Bearer <admin-token>

Response:
{
  "success": true,
  "data": {
    "verifications": [
      {
        "id": "uuid",
        "user": {
          "id": "uuid",
          "firstName": "John",
          "lastName": "Doe",
          "email": "john@example.com"
        },
        "doctor": {
          "specialty": "Cardiology",
          "licenseNumber": "MD123456"
        },
        "type": "medical_license",
        "status": "pending",
        "documentUrl": "...",
        "submittedAt": "2024-01-15T10:00:00Z"
      }
    ],
    "pagination": {...}
  }
}
```

### Admin: Approve Verification
```http
PUT /api/v1/verification/:id/approve
Authorization: Bearer <admin-token>

{
  "notes": "License verified with state board"
}

Response:
{
  "success": true,
  "message": "Verification approved successfully"
}
```

### Admin: Reject Verification
```http
PUT /api/v1/verification/:id/reject
Authorization: Bearer <admin-token>

{
  "reason": "Document is expired. Please upload current license.",
  "suggestedAction": "reupload"
}

Response:
{
  "success": true,
  "message": "Verification rejected"
}
```

## Workflow Diagram

```
┌─────────────────┐
│  Doctor Signup  │
└────────┬────────┘
         │
         ▼
┌─────────────────────────┐
│ Upload Required Docs    │
│ - Medical License       │
│ - Government ID         │
│ - Medical Degree        │
│ - Malpractice Insurance │
└────────┬────────────────┘
         │
         ▼
┌─────────────────┐
│ Status: PENDING │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Admin Review   │
└────────┬────────┘
         │
    ┌────┴────┐
    ▼         ▼
┌────────┐  ┌──────────┐
│APPROVED│  │ REJECTED │
└───┬────┘  └────┬─────┘
    │            │
    │       ┌────▼──────────┐
    │       │ Resubmit Docs │
    │       └────┬──────────┘
    │            │
    └────────┬───┘
             │
             ▼
    ┌─────────────────┐
    │ Doctor Verified │
    │ Can Accept Appts│
    └─────────────────┘
```

## Business Rules

1. **Required Documents**: Minimum 4 documents must be approved
2. **Expiry Checking**: Documents with expiry dates monitored
3. **Automatic Notifications**: Email sent on status changes
4. **Re-verification**: Required annually or on document expiry
5. **Access Control**: Unverified doctors have limited platform access
6. **Document Retention**: Documents retained for 7 years
7. **Privacy**: Only admin and document owner can view

## Email Notifications

### Document Submitted
```
Subject: Document Received - Under Review

Hi Dr. Smith,

We've received your medical license document. Our team will review it within 2-3 business days.

You can track your verification status in the app.

Thanks,
VIATRA Health Team
```

### Document Approved
```
Subject: Document Approved ✓

Hi Dr. Smith,

Great news! Your medical license has been approved.

Verification Progress: 3/4 documents approved

Upload remaining documents to complete verification.

Thanks,
VIATRA Health Team
```

### Document Rejected
```
Subject: Document Requires Attention

Hi Dr. Smith,

Your medical license submission requires attention:

Reason: Document is expired. Please upload current license.

Please re-upload an updated document.

Thanks,
VIATRA Health Team
```

### Verification Complete
```
Subject: Verification Complete - Welcome! 🎉

Hi Dr. Smith,

Congratulations! Your verification is complete. You can now:
- Accept patient appointments
- Access full platform features
- Receive patient bookings

Get started now!

Thanks,
VIATRA Health Team
```

## Security & Compliance

1. **HIPAA Compliance**: Secure document handling
2. **Encryption**: Documents encrypted at rest and in transit
3. **Access Logs**: All document access logged
4. **Audit Trail**: Complete verification history tracked
5. **Secure URLs**: Time-limited signed URLs for viewing
6. **Data Retention**: Compliant with medical records laws
7. **PII Protection**: Personal information redacted where possible

## Testing

### Backend Tests
```bash
cd backend
npm test -- verification
```

### Mobile Tests
```bash
cd mobile
flutter test test/verification_test.dart
```

### Integration Tests
```bash
cd mobile
flutter test integration_test/verification_flow_test.dart
```

## Admin Dashboard

Features for admin verification review:
- List of pending verifications
- Batch approval
- Document viewer with zoom
- Notes and comments
- Verification history
- Statistics and analytics
- Export reports

## Future Enhancements

- [ ] OCR for automatic document data extraction
- [ ] AI-powered document verification
- [ ] Integration with medical board APIs
- [ ] Automatic expiry notifications (30/60/90 days)
- [ ] Video verification for identity
- [ ] Blockchain-based credential verification
- [ ] Multi-jurisdiction support
- [ ] Delegated verification (third-party services)
- [ ] Mobile document scanning with edge detection
- [ ] Real-time verification status updates (WebSocket)

## Dependencies

### Backend
- `multer`: File upload handling
- `@google-cloud/storage`: GCS integration
- `sharp`: Image processing
- `pdf-lib`: PDF manipulation

### Mobile
- `file_picker`: File selection
- `image_picker`: Camera/gallery access
- `path_provider`: File system access
- `dio`: HTTP client with upload progress

## Documentation Links

- [Verification API Documentation](../api/VERIFICATION_API.md)
- [Admin Guide](../guides/ADMIN_VERIFICATION_GUIDE.md)
- [Compliance Documentation](../legal/COMPLIANCE.md)
- [Testing Guide](../TESTING_GUIDE.md)

---

**Status**: ✅ Complete  
**Last Updated**: November 2024  
**Maintained By**: Platform Team
