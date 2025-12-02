# Database Fields for Verification Status - User Visibility

## ✅ YES - All Fields Exist in Database and Are Visible to Users!

### Database Schema (Verification Table)

```sql
CREATE TABLE verifications (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL,
  doctor_id UUID,
  type ENUM(...),
  
  -- ✅ Status Field
  status ENUM('pending', 'verified', 'rejected', 'expired') DEFAULT 'pending',
  
  -- ✅ Rejection Reason Field
  rejection_reason TEXT,
  
  -- ✅ Notes Field
  notes TEXT,
  
  -- Additional fields
  document_url VARCHAR(512),
  document_type VARCHAR(255),
  verification_data JSONB,
  verified_at TIMESTAMP,
  verified_by UUID,  -- Admin who verified/rejected
  attempts INTEGER,
  max_attempts INTEGER,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

## What Users Can See

### When User Checks Their Verification Status

**Endpoint**: `GET /api/v1/verification/status`

**Response** (from `/backend/src/services/verificationService.js`):

```javascript
return verifications.map(verification => ({
  id: verification.id,
  type: verification.type,
  
  // ✅ STATUS - User can see if approved/rejected/pending
  status: verification.status,
  
  documentUrl: verification.document_url,
  documentType: verification.document_type,
  verificationData: verification.verification_data,
  verifiedAt: verification.verified_at,
  expiresAt: verification.expires_at,
  
  // ✅ REJECTION REASON - User can see why rejected
  rejectionReason: verification.rejection_reason,
  
  attempts: verification.attempts,
  maxAttempts: verification.max_attempts,
  createdAt: verification.created_at,
  updatedAt: verification.updated_at
}));
```

### Example Response - User Sees Everything

```json
{
  "success": true,
  "message": "Verification status retrieved successfully",
  "data": {
    "verifications": [
      {
        "id": "123e4567-e89b-12d3-a456-426614174000",
        "type": "medical_license",
        
        "status": "rejected",
        
        "documentUrl": "https://storage.googleapis.com/.../medical_license.pdf",
        "documentType": "medical_license.pdf",
        
        "verificationData": {
          "description": "Document verification for medical_license",
          "uploadedAt": "2024-12-02T10:00:00.000Z",
          "rejectedAt": "2024-12-02T15:30:00.000Z",
          "rejectedBy": "admin-user-id",
          "rejectionNotes": "Image quality too low to verify details"
        },
        
        "rejectionReason": "Document is unclear. Please upload a clearer image.",
        
        "attempts": 1,
        "maxAttempts": 5,
        "createdAt": "2024-12-02T10:00:00.000Z",
        "updatedAt": "2024-12-02T15:30:00.000Z"
      },
      {
        "id": "234e5678-e89b-12d3-a456-426614174001",
        "type": "identity",
        
        "status": "verified",
        
        "documentUrl": "https://storage.googleapis.com/.../identity.jpg",
        "documentType": "id_card.jpg",
        
        "verificationData": {
          "description": "Document verification for identity",
          "uploadedAt": "2024-12-02T10:05:00.000Z",
          "approvedAt": "2024-12-02T14:00:00.000Z",
          "approvedBy": "admin-user-id",
          "approvalNotes": "Document verified successfully"
        },
        
        "verifiedAt": "2024-12-02T14:00:00.000Z",
        "rejectionReason": null,
        
        "attempts": 1,
        "maxAttempts": 5,
        "createdAt": "2024-12-02T10:05:00.000Z",
        "updatedAt": "2024-12-02T14:00:00.000Z"
      }
    ]
  }
}
```

## How Admin Actions Are Stored

### When Admin Approves Document

**Code** (`/backend/src/services/verificationService.js`):

```javascript
export const approveVerification = async (verificationId, adminId, notes = '') => {
  // Mark as verified
  await verification.markAsVerified(); // Sets status = 'verified', verified_at = NOW
  
  // Update with admin info
  await verification.update({
    verified_by: adminId,              // ✅ Stored: Admin who approved
    notes: notes,                      // ✅ Stored: Admin notes
    verification_data: {
      ...verification.verification_data,
      approvedAt: new Date().toISOString(),  // ✅ Stored in JSONB
      approvedBy: adminId,                   // ✅ Stored in JSONB
      approvalNotes: notes                   // ✅ Stored in JSONB
    }
  });
};
```

**What Gets Stored**:
```
status = 'verified'
verified_at = '2024-12-02T15:30:00.000Z'
verified_by = 'admin-uuid-123'
notes = 'Document verified successfully. License number matches.'
verification_data = {
  "uploadedAt": "2024-12-02T10:00:00.000Z",
  "approvedAt": "2024-12-02T15:30:00.000Z",
  "approvedBy": "admin-uuid-123",
  "approvalNotes": "Document verified successfully. License number matches."
}
```

### When Admin Rejects Document

**Code** (`/backend/src/services/verificationService.js`):

```javascript
export const rejectVerification = async (verificationId, adminId, reason, notes = '') => {
  // Mark as rejected
  await verification.markAsRejected(reason);  // Sets status = 'rejected', rejection_reason = reason
  
  // Update with admin info
  await verification.update({
    verified_by: adminId,              // ✅ Stored: Admin who rejected
    notes: notes,                      // ✅ Stored: Admin notes
    verification_data: {
      ...verification.verification_data,
      rejectedAt: new Date().toISOString(),  // ✅ Stored in JSONB
      rejectedBy: adminId,                   // ✅ Stored in JSONB
      rejectionNotes: notes                  // ✅ Stored in JSONB
    }
  });
};
```

**What Gets Stored**:
```
status = 'rejected'
rejection_reason = 'Document is unclear. Please upload a clearer image.'
verified_by = 'admin-uuid-456'
notes = 'Image quality too low to verify details'
verification_data = {
  "uploadedAt": "2024-12-02T10:00:00.000Z",
  "rejectedAt": "2024-12-02T15:30:00.000Z",
  "rejectedBy": "admin-uuid-456",
  "rejectionNotes": "Image quality too low to verify details"
}
```

## User Experience

### 1. User Uploads Document
```
Status: "pending"
Message: "Your document is under review"
```

### 2. Admin Approves
```
Status: "verified"
Verified At: "2024-12-02T15:30:00.000Z"
Message: "Your document has been approved!"
```

### 3. Admin Rejects
```
Status: "rejected"
Rejection Reason: "Document is unclear. Please upload a clearer image."
Message: "Your document was rejected. Please reupload."
Additional Info in verification_data.rejectionNotes: "Image quality too low to verify details"
```

### 4. User Can Reupload
- User sees rejection reason
- User uploads new document
- `attempts` counter increments
- Status changes back to "pending"

## Mobile App Display Example

```dart
class VerificationStatusCard extends StatelessWidget {
  final Verification verification;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Text('Document Type: ${verification.type}'),
          
          // ✅ Show Status
          _buildStatusChip(verification.status),
          
          // ✅ Show Rejection Reason if rejected
          if (verification.status == 'rejected' && 
              verification.rejectionReason != null)
            Text(
              'Reason: ${verification.rejectionReason}',
              style: TextStyle(color: Colors.red),
            ),
          
          // ✅ Show Additional Notes if available
          if (verification.verificationData?['rejectionNotes'] != null)
            Text(
              'Details: ${verification.verificationData['rejectionNotes']}',
              style: TextStyle(color: Colors.grey),
            ),
          
          // ✅ Show verified date if approved
          if (verification.status == 'verified' && 
              verification.verifiedAt != null)
            Text('Verified on: ${formatDate(verification.verifiedAt)}'),
          
          // ✅ Show reupload button if rejected
          if (verification.status == 'rejected')
            ElevatedButton(
              onPressed: () => reuploadDocument(verification.type),
              child: Text('Reupload Document'),
            ),
        ],
      ),
    );
  }
  
  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;
    String label;
    
    switch (status) {
      case 'verified':
        color = Colors.green;
        icon = Icons.check_circle;
        label = 'Approved';
        break;
      case 'rejected':
        color = Colors.red;
        icon = Icons.cancel;
        label = 'Rejected';
        break;
      case 'pending':
        color = Colors.orange;
        icon = Icons.hourglass_empty;
        label = 'Under Review';
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
        label = status;
    }
    
    return Chip(
      avatar: Icon(icon, color: color),
      label: Text(label),
      backgroundColor: color.withOpacity(0.2),
    );
  }
}
```

## Summary

### ✅ Fields That Exist and Are Visible to Users:

1. **`status`** ✅
   - Type: ENUM('pending', 'verified', 'rejected', 'expired')
   - **User can see**: Yes, always included in response
   - Shows current state of verification

2. **`rejection_reason`** ✅
   - Type: TEXT
   - **User can see**: Yes, included in response when rejected
   - Contains the main reason for rejection (set by admin)

3. **`notes`** ✅
   - Type: TEXT
   - **User can see**: NO, this is admin-only field
   - **HOWEVER**: Admin notes are stored in `verification_data.rejectionNotes` or `verification_data.approvalNotes`
   - **User CAN see**: `verification_data` object which includes these notes

4. **`verification_data`** ✅
   - Type: JSONB (JSON object)
   - **User can see**: Yes, entire object returned
   - Contains:
     - Upload timestamp
     - Approval/rejection timestamp
     - Admin ID who processed it
     - Approval/rejection notes (detailed feedback)

### Where Each Field Is Used:

| Field | Set By | Visible To User | Purpose |
|-------|--------|----------------|---------|
| `status` | System/Admin | ✅ Yes | Current verification state |
| `rejection_reason` | Admin | ✅ Yes | Main reason for rejection |
| `notes` | Admin | ❌ No (admin only) | Internal admin notes |
| `verification_data.rejectionNotes` | Admin | ✅ Yes | Detailed feedback to user |
| `verification_data.approvalNotes` | Admin | ✅ Yes | Approval confirmation message |
| `verified_by` | System | ❌ No (could expose) | Admin who processed |
| `verified_at` | System | ✅ Yes | When it was processed |

## Recommendation: Update Response to Include Notes

If you want users to see the `notes` field directly, update the service:

```javascript
// In verificationService.js - getVerificationStatus function
return verifications.map(verification => ({
  // ...existing fields...
  rejectionReason: verification.rejection_reason,
  notes: verification.notes,  // ✅ Add this line
  // ...rest of fields...
}));
```

But currently, users get detailed feedback through:
- `rejectionReason` - Main reason
- `verification_data.rejectionNotes` - Detailed notes
- `verification_data.approvalNotes` - Approval message

So they DO have access to all the information they need! 🎉
