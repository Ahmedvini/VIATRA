# Admin System Quick Start Guide

## 🚀 How to Test the Admin System

### Prerequisites
- Flutter SDK installed
- Mobile app dependencies installed (`flutter pub get`)
- Backend running and accessible
- Admin credentials or admin email configured

### Step 1: Run the Mobile App

```bash
cd /home/ahmedvini/Music/VIATRA/mobile
flutter run
```

### Step 2: Login as Admin

1. Login with your credentials
2. Navigate to the **Profile** tab (bottom navigation)
3. Look for **"Admin Panel"** option in the settings list (purple icon)
4. Tap on **Admin Panel**

> **Note:** Admin access is currently determined by email. Update `/mobile/lib/screens/profile/profile_screen.dart` if needed to add your email to the admin list.

### Step 3: Test Admin Features

#### A. Review Patients
1. From Admin Dashboard, tap **"Review Patients"**
2. Select a status:
   - **Pending** - New registrations awaiting approval
   - **Active** - Currently active patients
   - **Deactivated** - Suspended patients
3. View the list of users
4. Tap on any user to see details

#### B. Review Doctors
1. From Admin Dashboard, tap **"Review Doctors"**
2. Select a status (same as above)
3. View doctor list
4. Tap on any doctor to see details

#### C. User Details & Actions
For any user, you can:

**Pending Users:**
- ✅ **Authorize** - Approve the user and activate their account
- ❌ **Reject** - Deny the registration (requires reason)

**Active Users:**
- ⏸️ **Deactivate** - Suspend the account (requires reason)
- 🗑️ **Delete** - Permanently remove the user (requires reason + double confirmation)

**Deactivated Users:**
- ✅ **Activate** - Restore the account
- 🗑️ **Delete** - Permanently remove the user (requires reason + double confirmation)

#### D. View Documents
1. In user details, scroll to **Documents** section
2. Each document shows:
   - Document type (ID, Medical Certificate, etc.)
   - Status badge (Pending, Verified, Rejected)
   - Filename
3. Tap **"View Document"** to open in browser

### Step 4: Test Scenarios

#### Scenario 1: Approve a New Doctor
```
1. Admin Dashboard → Review Doctors
2. Select "Pending"
3. Tap on a pending doctor
4. Review their profile and documents
5. Tap "View Document" to check certificates
6. Tap "Authorize User"
7. Confirm the action
8. ✅ User is now approved and can login
```

#### Scenario 2: Reject Invalid Registration
```
1. Admin Dashboard → Review Patients
2. Select "Pending"
3. Tap on a suspicious registration
4. Tap "Reject User"
5. Enter reason: "Invalid documents"
6. Confirm
7. ❌ User registration is denied
```

#### Scenario 3: Deactivate Problematic User
```
1. Admin Dashboard → Review Doctors
2. Select "Active"
3. Tap on the problematic user
4. Tap "Deactivate User"
5. Enter reason: "Violation of terms"
6. Confirm
7. ⏸️ User account is suspended
```

#### Scenario 4: Reactivate User
```
1. Admin Dashboard → Review Patients
2. Select "Deactivated"
3. Tap on a user to restore
4. Tap "Activate User"
5. Confirm
6. ✅ User account is restored
```

### Common Issues & Solutions

#### Issue: Admin Panel Not Showing
**Solution:** 
1. Check your email in `profile_screen.dart`:
```dart
final adminEmails = [
  'admin@viatra.com',
  'ahmedvini@gmail.com',
  // Add your email here
];
```
2. Rebuild the app: `flutter run`

#### Issue: Documents Don't Open
**Solution:**
- Ensure document URLs are valid and accessible
- Check internet connection
- Try copying URL and opening in browser manually

#### Issue: "Failed to load users"
**Solution:**
- Verify backend is running
- Check API endpoints are accessible
- Check console for error messages
- Verify authentication token is valid

#### Issue: Actions Don't Complete
**Solution:**
- Check backend logs for errors
- Ensure admin permissions are set correctly
- Verify network connectivity
- Check if user ID is valid

### API Endpoints Being Used

```
GET  /api/admin/users/pending?role=doctor
GET  /api/admin/users/active?role=patient
GET  /api/admin/users/deactivated?role=doctor
GET  /api/admin/users/:userId
PATCH /api/admin/users/:userId/authorize
PATCH /api/admin/users/:userId/reject
PATCH /api/admin/users/:userId/activate
PATCH /api/admin/users/:userId/deactivate
DELETE /api/admin/users/:userId
```

### Expected Behavior

#### Success Messages
- ✅ "User has been authorized"
- ✅ "User has been activated"
- ⚠️ "User has been rejected"
- ⚠️ "User has been deactivated"
- 🗑️ "User has been deleted"

#### Error Messages
- ❌ "Failed to authorize user"
- ❌ "Failed to load user details"
- ❌ "Could not open document"

### Debug Mode

To see detailed logs:
```bash
flutter run --debug
# Watch console for API calls and responses
```

### Testing Checklist

- [ ] Login as admin user
- [ ] Access admin panel from profile
- [ ] View pending patients list
- [ ] View pending doctors list
- [ ] View active users list
- [ ] View deactivated users list
- [ ] Open user detail screen
- [ ] View user profile information
- [ ] View uploaded documents
- [ ] Open document in browser
- [ ] Authorize a pending user
- [ ] Reject a pending user (with reason)
- [ ] Activate a deactivated user
- [ ] Deactivate an active user (with reason)
- [ ] Delete a user (with reason and confirmation)
- [ ] Test pull-to-refresh on user lists
- [ ] Test back navigation
- [ ] Test empty state displays
- [ ] Test error handling (network off, invalid data)

### Video Recording Tips

When recording a demo:
1. Show the admin panel in profile
2. Navigate through patient and doctor listings
3. Show different status tabs
4. Open a user detail screen
5. Show document viewing
6. Perform one authorization action
7. Perform one rejection action
8. Show confirmation dialogs
9. Show success messages

### Production Checklist (Before Going Live)

- [ ] Replace email-based admin check with role-based
- [ ] Add proper admin authentication
- [ ] Implement audit logging
- [ ] Add rate limiting
- [ ] Set up monitoring and alerts
- [ ] Test with real documents
- [ ] Train admin users
- [ ] Create admin user manual
- [ ] Set up backup procedures
- [ ] Configure email notifications

## 📞 Support

If you encounter any issues:
1. Check the console logs
2. Review the backend logs
3. Check the documentation files:
   - `ADMIN_SYSTEM_COMPLETION.md`
   - `ADMIN_SYSTEM_IMPLEMENTATION.md`
   - `ADMIN_DOCUMENT_REVIEW_GUIDE.md`

## 🎉 Success!

If you can complete all the testing scenarios above, the admin system is working correctly! 

---

**Last Updated:** December 2, 2025  
**Version:** 1.0.0
