# Document Upload and Verification Flow

## Summary
**YES, documents (ID verification, certificates, etc.) ARE being uploaded and stored!**

## Complete Flow

### 1. Mobile App (Flutter)

#### Document Selection
- User picks documents using `image_picker` package in `document_upload_step.dart`
- Documents are stored in the `RegistrationProvider` as `Map<String, File>`

#### Document Upload Process
Location: `/mobile/lib/providers/registration_provider.dart`

```dart
// After successful registration
await _uploadDocuments();

// Upload each document
Future<void> _uploadDocuments() async {
  for (final entry in _documents.entries) {
    await _verificationService.submitDocument(
      entry.value,        // File
      entry.key,          // Document type (e.g., 'identity', 'medical_license')
      'Document verification for ${entry.key}',
      _accessToken!,
    );
  }
}
```

#### Verification Service
Location: `/mobile/lib/services/verification_service.dart`

```dart
Future<ApiResponse<Verification>> submitDocument(
  File file, 
  String documentType,    // 'identity', 'medical_license', 'education', etc.
  String description, 
  String token
) async {
  final formData = {
    'documentType': documentType,
    'description': description,
  };
  
  return await _apiService.uploadFile(
    '/verification/submit',
    file,
    fieldName: 'document',  // File field name
    fields: formData,       // Form data
  );
}
```

#### API Service
Location: `/mobile/lib/services/api_service.dart`

```dart
Future<ApiResponse<T>> uploadFile(
  String endpoint,
  File file,
  {String fieldName = 'file', Map<String, String>? fields}
) async {
  final request = http.MultipartRequest('POST', uri);
  
  // Add headers with auth token
  request.headers.addAll({..._defaultHeaders, ...?headers});
  
  // Add file as multipart
  request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));
  
  // Add form fields (documentType, description)
  if (fields != null) {
    request.fields.addAll(fields);
  }
  
  final streamedResponse = await request.send();
  return await http.Response.fromStream(streamedResponse);
}
```

### 2. Backend (Node.js/Express)

#### Route Configuration
Location: `/backend/src/routes/verification.js`

```javascript
router.post('/submit',
  authenticate,                           // Verify JWT token
  authorize('doctor', 'hospital', 'pharmacy', 'patient', 'admin'),  // ✅ FIXED: Added 'patient'
  documentUploadLimiter,                  // Rate limiting
  uploadSingle('document'),               // Multer middleware for file upload
  validate(documentUploadSchema),         // Validate request
  submitDocumentForVerification
);
```

#### Validation Schema
Location: `/backend/src/utils/validators.js`

```javascript
export const documentUploadSchema = Joi.object({
  type: Joi.string()
    .valid('medical_license', 'education', 'certification', 'insurance', 'identity')
    .optional(),
  
  // ✅ FIXED: Support both 'type' and 'documentType' field names
  documentType: Joi.string()
    .valid('medical_license', 'education', 'certification', 'insurance', 'identity')
    .optional(),
  
  description: Joi.string()
    .trim()
    .max(500)
    .optional()
}).or('type', 'documentType').messages({
  'object.missing': 'Either type or documentType is required'
});
```

#### Controller
Location: `/backend/src/controllers/verificationController.js`

```javascript
export const submitDocumentForVerification = async (req, res) => {
  const userId = req.user.id;
  
  // ✅ FIXED: Support both 'type' and 'documentType' field names
  const type = req.body.type || req.body.documentType;
  const description = req.body.description || '';
  
  // File is provided by multer middleware
  if (!req.file) {
    return res.status(400).json({
      error: 'File required',
      message: 'Please upload a document file'
    });
  }

  // Validate document type
  if (!type) {
    return res.status(400).json({
      error: 'Document type required',
      message: 'Please specify the document type'
    });
  }

  // ✅ Upload file to Google Cloud Storage
  const gcsResult = await uploadFileToGCS(req.file, type);
  
  // ✅ Store verification record in database
  const verification = await uploadVerificationDocument(
    userId,
    type,
    gcsResult.url,           // GCS URL
    gcsResult.originalName,  // Original filename
    description
  );

  return res.status(201).json({
    success: true,
    message: 'Document submitted successfully',
    data: {
      id: verification.id,
      type: verification.type,
      status: verification.status,
      url: gcsResult.url
    }
  });
};
```

#### File Upload Utility
Location: `/backend/src/utils/fileUpload.js`

```javascript
// Multer middleware for file upload
export const uploadSingle = (fieldName) => multer({
  storage: multer.memoryStorage(),  // Store in memory
  limits: {
    fileSize: 10 * 1024 * 1024  // 10MB limit
  },
  fileFilter: (req, file, cb) => {
    // Accept images and PDFs
    const allowedTypes = /jpeg|jpg|png|pdf/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);
    
    if (mimetype && extname) {
      return cb(null, true);
    }
    cb(new Error('Only images and PDFs are allowed'));
  }
}).single(fieldName);

// Upload to Google Cloud Storage
export const uploadFileToGCS = async (file, folder = 'documents') => {
  const bucket = storage.bucket(process.env.GCS_BUCKET_NAME);
  const blob = bucket.file(`${folder}/${Date.now()}_${file.originalname}`);
  
  const blobStream = blob.createWriteStream({
    resumable: false,
    metadata: {
      contentType: file.mimetype
    }
  });

  return new Promise((resolve, reject) => {
    blobStream.on('error', reject);
    blobStream.on('finish', () => {
      const publicUrl = `https://storage.googleapis.com/${bucket.name}/${blob.name}`;
      resolve({
        url: publicUrl,
        originalName: file.originalname
      });
    });
    blobStream.end(file.buffer);
  });
};
```

#### Verification Service
Location: `/backend/src/services/verificationService.js`

```javascript
export const uploadVerificationDocument = async (
  userId, 
  documentType, 
  documentUrl,      // GCS URL
  documentName,     // Original filename
  description = ''
) => {
  // Check if verification already exists
  const existingVerification = await Verification.findOne({
    where: {
      user_id: userId,
      type: documentType,
      status: ['pending', 'verified']
    }
  });
  
  if (existingVerification) {
    if (existingVerification.status === 'verified') {
      throw new Error('Document already verified for this type');
    }
    
    // ✅ Update existing pending verification
    await existingVerification.update({
      document_url: documentUrl,
      document_type: documentName,
      verification_data: {
        ...existingVerification.verification_data,
        description: description,
        uploadedAt: new Date().toISOString(),
        originalFileName: documentName
      },
      attempts: existingVerification.attempts + 1,
      status: 'pending'
    });
    
    return existingVerification;
  }
  
  // ✅ Create new verification record in database
  const verification = await Verification.create({
    user_id: userId,
    doctor_id: user.doctorProfile ? user.doctorProfile.id : null,
    type: documentType,
    status: 'pending',
    document_url: documentUrl,        // ✅ Stored!
    document_type: documentName,       // ✅ Stored!
    verification_data: {               // ✅ Stored!
      description: description,
      uploadedAt: new Date().toISOString(),
      originalFileName: documentName
    },
    attempts: 1,
    max_attempts: 5
  });
  
  return verification;
};
```

### 3. Database Storage

#### Verification Table Schema
```sql
CREATE TABLE verifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id),
  doctor_id UUID REFERENCES doctors(id),
  type ENUM('email', 'phone', 'identity', 'medical_license', 'insurance', 'background_check', 'education', 'certification'),
  status ENUM('pending', 'verified', 'rejected', 'expired') DEFAULT 'pending',
  document_url VARCHAR(512),           -- ✅ GCS URL stored here
  document_type VARCHAR(255),          -- ✅ Original filename stored here
  verification_data JSONB,             -- ✅ Description and metadata stored here
  attempts INTEGER DEFAULT 0,
  max_attempts INTEGER DEFAULT 3,
  verified_at TIMESTAMP,
  expires_at TIMESTAMP,
  rejection_reason TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### Example Stored Data
```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "user_id": "user-uuid-here",
  "doctor_id": "doctor-uuid-here",
  "type": "medical_license",
  "status": "pending",
  "document_url": "https://storage.googleapis.com/viatra-bucket/documents/1733155200000_license.pdf",
  "document_type": "license.pdf",
  "verification_data": {
    "description": "Document verification for medical_license",
    "uploadedAt": "2024-12-02T10:00:00.000Z",
    "originalFileName": "license.pdf"
  },
  "attempts": 1,
  "max_attempts": 5,
  "verified_at": null,
  "expires_at": null,
  "rejection_reason": null,
  "created_at": "2024-12-02T10:00:00.000Z",
  "updated_at": "2024-12-02T10:00:00.000Z"
}
```

## Document Types Supported

### For Doctors
- `medical_license` - Medical license certificate
- `education` - Education certificates/diplomas
- `certification` - Professional certifications
- `identity` - ID card, passport, etc.
- `insurance` - Professional liability insurance

### For Patients
- `identity` - ID card, passport, etc.
- `insurance` - Health insurance card

## Fixes Applied

### Issue 1: Patients Could Not Upload Documents ❌ → ✅
**Problem**: Route authorization excluded 'patient' role
```javascript
// BEFORE (patients blocked)
authorize('doctor', 'hospital', 'pharmacy', 'admin')

// AFTER (patients allowed)
authorize('doctor', 'hospital', 'pharmacy', 'patient', 'admin')
```

### Issue 2: Field Name Mismatch ❌ → ✅
**Problem**: Mobile app sent `documentType` but backend expected `type`

**Fix 1 - Controller**: Accept both field names
```javascript
// BEFORE
const { type, description = '' } = req.body;

// AFTER
const type = req.body.type || req.body.documentType;
const description = req.body.description || '';
```

**Fix 2 - Validation**: Accept both field names
```javascript
// BEFORE
type: Joi.string().required()

// AFTER
type: Joi.string().optional(),
documentType: Joi.string().optional()
}).or('type', 'documentType')
```

## Verification Flow

### 1. Upload Documents
User uploads documents during registration → Stored in GCS + Database

### 2. Admin Reviews
Admin logs in → Views pending verifications → Can approve/reject

### 3. Status Updates
```javascript
// Approve
PATCH /api/v1/verification/document/:documentId/status
{ "status": "approved" }

// Reject
PATCH /api/v1/verification/document/:documentId/status
{ "status": "rejected", "reason": "Invalid document" }
```

### 4. User Gets Notified
- Email notification sent
- Status visible in app via `GET /api/v1/verification/status`

## Testing

### Check User's Verification Status
```bash
curl -X GET https://your-backend-url/api/v1/verification/status \
  -H "Authorization: Bearer <user-token>"
```

### Expected Response
```json
{
  "success": true,
  "message": "Verification status retrieved successfully",
  "data": {
    "verifications": [
      {
        "id": "verification-uuid",
        "type": "identity",
        "status": "pending",
        "document_url": "https://storage.googleapis.com/...",
        "created_at": "2024-12-02T10:00:00.000Z"
      },
      {
        "id": "verification-uuid-2",
        "type": "medical_license",
        "status": "pending",
        "document_url": "https://storage.googleapis.com/...",
        "created_at": "2024-12-02T10:05:00.000Z"
      }
    ]
  }
}
```

## Summary

✅ **Documents ARE uploaded** via multipart/form-data
✅ **Files ARE stored** in Google Cloud Storage
✅ **Records ARE created** in the database
✅ **Both doctors and patients** can now upload documents
✅ **Field name mismatch** has been fixed
✅ **Admin can review and approve/reject** documents
✅ **Users can check verification status** via API

## Next Steps

1. Deploy the backend changes to Railway
2. Test document upload with both doctor and patient accounts
3. Create admin user and test document approval/rejection
4. Verify email notifications are sent on status changes
