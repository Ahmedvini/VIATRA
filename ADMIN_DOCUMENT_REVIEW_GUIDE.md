# Admin Document Review Guide

## Where Are Documents Uploaded?

### Storage Location
**Google Cloud Storage (GCS)** - A cloud-based file storage service

- **Service**: Google Cloud Storage
- **Bucket**: Defined in `GCS_BUCKET_NAME` environment variable
- **Path Structure**: `verification-documents/{type}/{timestamp}-{uuid}.{extension}`
- **Public URL Format**: `https://storage.googleapis.com/{bucket-name}/verification-documents/{type}/{timestamp}-{uuid}.{extension}`

### Example Paths
```
verification-documents/identity/1733155200000-a1b2c3d4-e5f6-7890-abcd-ef1234567890.jpg
verification-documents/medical_license/1733155300000-b2c3d4e5-f6a7-8901-bcde-f12345678901.pdf
verification-documents/education/1733155400000-c3d4e5f6-a7b8-9012-cdef-012345678902.pdf
```

### Database Storage
Document metadata is stored in the `verifications` table:

```sql
CREATE TABLE verifications (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL,                    -- Links to users table
  doctor_id UUID,                            -- Links to doctors table (if doctor)
  type ENUM,                                 -- Document type
  status ENUM('pending', 'verified', 'rejected', 'expired'),
  document_url VARCHAR(512),                 -- ✅ GCS URL here
  document_type VARCHAR(255),                -- Original filename
  verification_data JSONB,                   -- Additional metadata
  attempts INTEGER,
  verified_at TIMESTAMP,
  verified_by UUID,                          -- Admin who verified
  rejection_reason TEXT,
  notes TEXT,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

## Admin API Endpoints for Document Review

### 1. Get All Pending Verifications (Main Admin View)

**Endpoint**: `GET /api/v1/verification/pending`

**Authorization**: Admin only

**Query Parameters**:
- `page` (optional, default: 1) - Page number
- `limit` (optional, default: 20, max: 100) - Results per page
- `documentType` (optional) - Filter by type: `identity`, `medical_license`, `education`, `certification`, `insurance`
- `userId` (optional) - Filter by specific user

**Example Request**:
```bash
# Get all pending verifications (page 1, 20 items)
curl -X GET 'https://your-backend-url/api/v1/verification/pending' \
  -H "Authorization: Bearer <admin-token>"

# Get pending medical licenses only
curl -X GET 'https://your-backend-url/api/v1/verification/pending?documentType=medical_license' \
  -H "Authorization: Bearer <admin-token>"

# Get page 2 with 50 items per page
curl -X GET 'https://your-backend-url/api/v1/verification/pending?page=2&limit=50' \
  -H "Authorization: Bearer <admin-token>"
```

**Example Response**:
```json
{
  "success": true,
  "message": "Pending verifications retrieved successfully",
  "data": {
    "verifications": [
      {
        "id": "123e4567-e89b-12d3-a456-426614174000",
        "type": "medical_license",
        "status": "pending",
        "documentUrl": "https://storage.googleapis.com/viatra-bucket/verification-documents/medical_license/1733155200000-uuid.pdf",
        "documentType": "medical_license.pdf",
        "verificationData": {
          "description": "Document verification for medical_license",
          "uploadedAt": "2024-12-02T10:00:00.000Z",
          "originalFileName": "medical_license.pdf"
        },
        "attempts": 1,
        "maxAttempts": 5,
        "createdAt": "2024-12-02T10:00:00.000Z",
        "user": {
          "id": "user-uuid-here",
          "email": "doctor@example.com",
          "firstName": "John",
          "lastName": "Doe",
          "role": "doctor",
          "doctorProfile": {
            "id": "doctor-uuid-here",
            "specialty": "Cardiology",
            "licenseNumber": "MD12345",
            "title": "Dr."
          }
        }
      },
      {
        "id": "234e5678-e89b-12d3-a456-426614174001",
        "type": "identity",
        "status": "pending",
        "documentUrl": "https://storage.googleapis.com/viatra-bucket/verification-documents/identity/1733155300000-uuid.jpg",
        "documentType": "id_card.jpg",
        "verificationData": {
          "description": "Document verification for identity",
          "uploadedAt": "2024-12-02T10:05:00.000Z",
          "originalFileName": "id_card.jpg"
        },
        "attempts": 1,
        "maxAttempts": 5,
        "createdAt": "2024-12-02T10:05:00.000Z",
        "user": {
          "id": "patient-uuid-here",
          "email": "patient@example.com",
          "firstName": "Jane",
          "lastName": "Smith",
          "role": "patient",
          "doctorProfile": null
        }
      }
    ],
    "pagination": {
      "currentPage": 1,
      "totalPages": 5,
      "totalCount": 95,
      "limit": 20,
      "hasNext": true,
      "hasPrev": false
    }
  }
}
```

### 2. Get Specific User's Verification Status

**Endpoint**: `GET /api/v1/verification/status`

**Authorization**: User themselves or Admin

**Example Request**:
```bash
curl -X GET 'https://your-backend-url/api/v1/verification/status' \
  -H "Authorization: Bearer <user-or-admin-token>"
```

**Example Response**:
```json
{
  "success": true,
  "message": "Verification status retrieved successfully",
  "data": {
    "verifications": [
      {
        "id": "verification-uuid-1",
        "type": "identity",
        "status": "pending",
        "documentUrl": "https://storage.googleapis.com/.../identity/...",
        "createdAt": "2024-12-02T10:00:00.000Z"
      },
      {
        "id": "verification-uuid-2",
        "type": "medical_license",
        "status": "verified",
        "documentUrl": "https://storage.googleapis.com/.../medical_license/...",
        "verifiedAt": "2024-12-02T12:00:00.000Z",
        "createdAt": "2024-12-02T10:05:00.000Z"
      }
    ]
  }
}
```

### 3. Get Specific Document Details

**Endpoint**: `GET /api/v1/verification/document/:documentId`

**Authorization**: User themselves or Admin

**Example Request**:
```bash
curl -X GET 'https://your-backend-url/api/v1/verification/document/123e4567-e89b-12d3-a456-426614174000' \
  -H "Authorization: Bearer <admin-token>"
```

### 4. Approve Document (Admin Action)

**Endpoint**: `PATCH /api/v1/verification/document/:documentId/status`

**Authorization**: Admin only

**Request Body**:
```json
{
  "status": "approved",
  "notes": "Document verified successfully. License number matches."
}
```

**Example Request**:
```bash
curl -X PATCH 'https://your-backend-url/api/v1/verification/document/123e4567-e89b-12d3-a456-426614174000/status' \
  -H "Authorization: Bearer <admin-token>" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "approved",
    "notes": "Document verified successfully"
  }'
```

**Example Response**:
```json
{
  "success": true,
  "message": "Document verification status updated successfully",
  "data": {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "type": "medical_license",
    "status": "verified",
    "verifiedAt": "2024-12-02T15:30:00.000Z",
    "verifiedBy": "admin-user-id",
    "notes": "Document verified successfully"
  }
}
```

### 5. Reject Document (Admin Action)

**Endpoint**: `PATCH /api/v1/verification/document/:documentId/status`

**Authorization**: Admin only

**Request Body**:
```json
{
  "status": "rejected",
  "reason": "Document is unclear. Please upload a clearer image.",
  "notes": "Image quality too low to verify details"
}
```

**Example Request**:
```bash
curl -X PATCH 'https://your-backend-url/api/v1/verification/document/123e4567-e89b-12d3-a456-426614174000/status' \
  -H "Authorization: Bearer <admin-token>" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "rejected",
    "reason": "Document is unclear. Please upload a clearer image.",
    "notes": "Image quality too low to verify details"
  }'
```

**Example Response**:
```json
{
  "success": true,
  "message": "Document verification status updated successfully",
  "data": {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "type": "medical_license",
    "status": "rejected",
    "rejectionReason": "Document is unclear. Please upload a clearer image.",
    "notes": "Image quality too low to verify details",
    "rejectedAt": "2024-12-02T15:30:00.000Z",
    "rejectedBy": "admin-user-id"
  }
}
```

### 6. Bulk Approve/Reject Documents

**Endpoint**: `POST /api/v1/verification/bulk-update`

**Authorization**: Admin only

**Request Body**:
```json
{
  "documentIds": [
    "123e4567-e89b-12d3-a456-426614174000",
    "234e5678-e89b-12d3-a456-426614174001",
    "345e6789-e89b-12d3-a456-426614174002"
  ],
  "status": "approved",
  "notes": "Batch verification completed"
}
```

**Example Request**:
```bash
curl -X POST 'https://your-backend-url/api/v1/verification/bulk-update' \
  -H "Authorization: Bearer <admin-token>" \
  -H "Content-Type: application/json" \
  -d '{
    "documentIds": ["uuid1", "uuid2", "uuid3"],
    "status": "approved",
    "notes": "Batch verification completed"
  }'
```

### 7. Get Verification Statistics

**Endpoint**: `GET /api/v1/verification/stats`

**Authorization**: Admin only

**Example Request**:
```bash
curl -X GET 'https://your-backend-url/api/v1/verification/stats' \
  -H "Authorization: Bearer <admin-token>"
```

**Example Response**:
```json
{
  "success": true,
  "data": {
    "totalPending": 95,
    "totalVerified": 320,
    "totalRejected": 15,
    "byType": {
      "identity": { "pending": 20, "verified": 150, "rejected": 5 },
      "medical_license": { "pending": 45, "verified": 100, "rejected": 8 },
      "education": { "pending": 30, "verified": 70, "rejected": 2 }
    },
    "recentActivity": [
      {
        "date": "2024-12-02",
        "approved": 25,
        "rejected": 3
      }
    ]
  }
}
```

## Admin Panel Implementation Guide

### Frontend Flow for Admin Review Panel

#### 1. Fetch Pending Documents
```javascript
// Admin Panel - Pending Documents List
async function fetchPendingDocuments(page = 1, limit = 20, documentType = null) {
  let url = `/api/v1/verification/pending?page=${page}&limit=${limit}`;
  if (documentType) {
    url += `&documentType=${documentType}`;
  }
  
  const response = await fetch(url, {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${adminToken}`,
      'Content-Type': 'application/json'
    }
  });
  
  return await response.json();
}
```

#### 2. Display Document Preview
```javascript
// Document Preview Component
function DocumentPreview({ documentUrl, documentType, userData }) {
  return (
    <div className="document-card">
      <div className="user-info">
        <h3>{userData.firstName} {userData.lastName}</h3>
        <p>Email: {userData.email}</p>
        <p>Role: {userData.role}</p>
        {userData.doctorProfile && (
          <div>
            <p>Specialty: {userData.doctorProfile.specialty}</p>
            <p>License #: {userData.doctorProfile.licenseNumber}</p>
          </div>
        )}
      </div>
      
      <div className="document-viewer">
        <h4>Document: {documentType}</h4>
        {/* Show image or PDF preview */}
        {documentUrl.endsWith('.pdf') ? (
          <iframe src={documentUrl} width="100%" height="600px" />
        ) : (
          <img src={documentUrl} alt="Document" style={{maxWidth: '100%'}} />
        )}
      </div>
      
      <div className="action-buttons">
        <button onClick={() => approveDocument(verification.id)}>
          ✓ Approve
        </button>
        <button onClick={() => rejectDocument(verification.id)}>
          ✗ Reject
        </button>
      </div>
    </div>
  );
}
```

#### 3. Approve Document
```javascript
async function approveDocument(documentId, notes = '') {
  const response = await fetch(`/api/v1/verification/document/${documentId}/status`, {
    method: 'PATCH',
    headers: {
      'Authorization': `Bearer ${adminToken}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      status: 'approved',
      notes: notes || 'Document verified successfully'
    })
  });
  
  const result = await response.json();
  if (result.success) {
    alert('Document approved successfully!');
    // Refresh the list
    fetchPendingDocuments();
  }
}
```

#### 4. Reject Document
```javascript
async function rejectDocument(documentId, reason) {
  const response = await fetch(`/api/v1/verification/document/${documentId}/status`, {
    method: 'PATCH',
    headers: {
      'Authorization': `Bearer ${adminToken}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      status: 'rejected',
      reason: reason || 'Document does not meet requirements',
      notes: 'Additional review needed'
    })
  });
  
  const result = await response.json();
  if (result.success) {
    alert('Document rejected. User will be notified.');
    // Refresh the list
    fetchPendingDocuments();
  }
}
```

## User Account Management (Activate/Deactivate/Delete)

### Current Implementation
The verification system marks documents as approved/rejected, but it doesn't automatically activate/deactivate user accounts. You need to implement this separately.

### Recommended Implementation

#### 1. User Status Management Endpoints

**Add to**: `/backend/src/routes/admin.js` (create if doesn't exist)

```javascript
// Admin route to activate user
router.patch('/users/:userId/activate',
  authenticate,
  authorize('admin'),
  async (req, res) => {
    const user = await User.findByPk(req.params.userId);
    await user.update({ is_active: true, activated_at: new Date() });
    res.json({ success: true, message: 'User activated' });
  }
);

// Admin route to deactivate user
router.patch('/users/:userId/deactivate',
  authenticate,
  authorize('admin'),
  async (req, res) => {
    const user = await User.findByPk(req.params.userId);
    await user.update({ is_active: false, deactivated_at: new Date() });
    res.json({ success: true, message: 'User deactivated' });
  }
);

// Admin route to delete user
router.delete('/users/:userId',
  authenticate,
  authorize('admin'),
  async (req, res) => {
    const user = await User.findByPk(req.params.userId);
    await user.destroy();
    res.json({ success: true, message: 'User deleted' });
  }
);
```

#### 2. Combined Verification + Activation Flow

When admin approves ALL required documents for a user, automatically activate their account:

```javascript
// In verificationService.js - approveVerification function
export const approveVerification = async (verificationId, adminId, notes = '') => {
  // ... existing approval code ...
  
  // Check if all required verifications are approved
  const user = await User.findByPk(verification.user_id);
  const allVerifications = await Verification.findAll({
    where: { user_id: user.id }
  });
  
  const requiredTypes = user.role === 'doctor' 
    ? ['identity', 'medical_license', 'education']
    : ['identity'];
  
  const allApproved = requiredTypes.every(type => 
    allVerifications.some(v => v.type === type && v.status === 'verified')
  );
  
  if (allApproved && !user.is_active) {
    // Automatically activate user when all docs approved
    await user.update({ 
      is_active: true, 
      activated_at: new Date(),
      verification_completed: true 
    });
    
    logger.info('User automatically activated after all verifications approved', {
      userId: user.id,
      email: user.email
    });
  }
  
  return verification;
};
```

## Flutter Admin Panel Implementation

### Example Admin Documents Screen

```dart
class AdminDocumentsScreen extends StatefulWidget {
  @override
  _AdminDocumentsScreenState createState() => _AdminDocumentsScreenState();
}

class _AdminDocumentsScreenState extends State<AdminDocumentsScreen> {
  List<Verification> pendingDocs = [];
  int currentPage = 1;
  bool isLoading = false;
  
  @override
  void initState() {
    super.initState();
    fetchPendingDocuments();
  }
  
  Future<void> fetchPendingDocuments() async {
    setState(() => isLoading = true);
    
    final response = await _verificationService.getPendingVerifications(
      page: currentPage,
      limit: 20,
    );
    
    if (response.success) {
      setState(() {
        pendingDocs = response.data;
        isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pending Documents')),
      body: isLoading
          ? CircularProgressIndicator()
          : ListView.builder(
              itemCount: pendingDocs.length,
              itemBuilder: (context, index) {
                final doc = pendingDocs[index];
                return DocumentCard(
                  verification: doc,
                  onApprove: () => approveDocument(doc.id),
                  onReject: () => rejectDocument(doc.id),
                );
              },
            ),
    );
  }
  
  Future<void> approveDocument(String docId) async {
    final response = await _verificationService.updateDocumentStatus(
      docId,
      'approved',
      notes: 'Verified by admin',
    );
    
    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Document approved')),
      );
      fetchPendingDocuments(); // Refresh list
    }
  }
  
  Future<void> rejectDocument(String docId) async {
    // Show dialog to get rejection reason
    final reason = await showReasonDialog();
    
    if (reason != null) {
      final response = await _verificationService.updateDocumentStatus(
        docId,
        'rejected',
        reason: reason,
      );
      
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Document rejected')),
        );
        fetchPendingDocuments(); // Refresh list
      }
    }
  }
}
```

## Summary

### ✅ Where Documents Are Stored
- **Cloud Storage**: Google Cloud Storage (GCS)
- **Path**: `verification-documents/{type}/{timestamp}-{uuid}.{extension}`
- **Database**: `verifications` table with document URL and metadata

### ✅ How to Retrieve for Admin Review
1. **GET** `/api/v1/verification/pending` - List all pending documents
2. **GET** `/api/v1/verification/document/:id` - Get specific document
3. **Document URL** in response - Direct link to view/download file

### ✅ Admin Actions
1. **Approve**: `PATCH /api/v1/verification/document/:id/status` with `status: "approved"`
2. **Reject**: `PATCH /api/v1/verification/document/:id/status` with `status: "rejected"` + reason
3. **Bulk**: `POST /api/v1/verification/bulk-update` with array of document IDs

### ✅ User Account Management
- Implement activate/deactivate endpoints in admin routes
- Optionally auto-activate when all required documents approved
- Can delete users via admin endpoint

### 🔑 Key Points
- Both doctors and patients upload documents
- Documents are publicly accessible URLs (secured by obscure paths)
- Admin can view document preview directly from URL
- Status updates trigger email notifications to users
- Can filter by document type, user, or status
