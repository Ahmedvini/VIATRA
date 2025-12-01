# VIATRA Admin User Setup

## Admin Credentials

**Email:** `admin@viatra.health`  
**Password:** `Admin@2025!Viatra`  
**Role:** `admin`

---

## Option 1: Create Admin via Railway PostgreSQL Query (RECOMMENDED)

### Steps:

1. **Go to Railway Dashboard**
   - Navigate to https://railway.app
   - Select your VIATRA project
   - Click on your PostgreSQL database service

2. **Open Query Tab**
   - Click on the "Query" tab in the database service

3. **Enable pgcrypto Extension** (if not already enabled)
   ```sql
   CREATE EXTENSION IF NOT EXISTS pgcrypto;
   ```

4. **Run the Admin Creation Query**
   ```sql
   -- Create admin user
   INSERT INTO users (
     id,
     email,
     password_hash,
     first_name,
     last_name,
     phone,
     role,
     is_active,
     email_verified,
     created_at,
     updated_at
   ) 
   SELECT 
     gen_random_uuid(),
     'admin@viatra.health',
     crypt('Admin@2025!Viatra', gen_salt('bf', 10)),
     'Admin',
     'User',
     '+20 100 000 0000',
     'admin',
     true,
     true,
     NOW(),
     NOW()
   WHERE NOT EXISTS (
     SELECT 1 FROM users WHERE email = 'admin@viatra.health'
   );
   ```

5. **Verify Admin was Created**
   ```sql
   SELECT id, email, first_name, last_name, role, is_active, email_verified 
   FROM users 
   WHERE email = 'admin@viatra.health';
   ```

---

## Option 2: Create Admin via API (After Backend is Running)

You can also create the admin user by sending a POST request to your registration endpoint:

```bash
curl -X POST https://your-backend-url.railway.app/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@viatra.health",
    "password": "Admin@2025!Viatra",
    "firstName": "Admin",
    "lastName": "User",
    "phone": "+20 100 000 0000",
    "role": "admin"
  }'
```

---

## Option 3: Using the Backend Script

If you have Node.js installed locally and can connect to the Railway database:

```bash
cd backend
node create-admin.js
```

---

## Admin User Capabilities

With the admin role, you can:

- ✅ Verify doctor accounts
- ✅ Verify patient accounts
- ✅ Manage user accounts
- ✅ View all appointments
- ✅ Access admin dashboard
- ✅ Moderate content
- ✅ View system analytics

---

## Security Notes

⚠️ **IMPORTANT:**

1. **Change the password immediately after first login**
2. **Never commit admin credentials to version control**
3. **Use strong, unique passwords in production**
4. **Enable 2FA for admin accounts (if available)**
5. **Regularly rotate admin passwords**
6. **Monitor admin account activity**

---

## Login Instructions

### Via Mobile App:
1. Open the VIATRA mobile app
2. Click "Sign In"
3. Enter email: `admin@viatra.health`
4. Enter password: `Admin@2025!Viatra`
5. Click "Login"

### Via Web Dashboard (if available):
1. Navigate to admin dashboard URL
2. Enter admin credentials
3. Access admin panel

---

## Troubleshooting

### If admin user already exists:
```sql
-- Update password
UPDATE users 
SET password_hash = crypt('Admin@2025!Viatra', gen_salt('bf', 10)),
    updated_at = NOW()
WHERE email = 'admin@viatra.health';
```

### If you need to delete and recreate:
```sql
-- Delete existing admin
DELETE FROM users WHERE email = 'admin@viatra.health';

-- Then run the INSERT query again
```

### Check if pgcrypto is enabled:
```sql
SELECT * FROM pg_extension WHERE extname = 'pgcrypto';
```

---

## Files Created

- `/backend/create-admin.js` - Node.js script to create admin
- `/backend/create-admin.sql` - SQL script for manual creation
- `/backend/create-admin.sh` - Bash script with instructions
- `/backend/ADMIN_SETUP.md` - This file

---

## Next Steps

After creating the admin user:

1. ✅ Test login with admin credentials
2. ✅ Change the default password
3. ✅ Set up admin panel routes
4. ✅ Implement account verification endpoints
5. ✅ Create admin dashboard UI
6. ✅ Add role-based access control (RBAC)

---

**Created:** December 2, 2025  
**Last Updated:** December 2, 2025
