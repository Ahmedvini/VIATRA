-- Create Test Patient for Food Tracking Feature Testing
-- Run this in your Supabase SQL Editor or pgAdmin

-- This script creates a test patient account you can use to login and test food tracking

-- 1. First, let's check if the users table exists and create test user
INSERT INTO users (
  email,
  password_hash,
  role,
  first_name,
  last_name,
  phone,
  is_verified,
  created_at,
  updated_at
) VALUES (
  'testpatient@viatra.com',
  -- Password: Test1234! (bcrypt hash)
  '$2b$10$YourHashHere', -- You'll need to generate this
  'patient',
  'Test',
  'Patient',
  '+1234567890',
  true,
  NOW(),
  NOW()
) 
ON CONFLICT (email) DO UPDATE SET
  first_name = 'Test',
  last_name = 'Patient',
  role = 'patient',
  is_verified = true
RETURNING id;

-- Note: Save the returned ID, you'll need it for the next steps

-- 2. Create patient profile (replace USER_ID with the ID from step 1)
-- If you already have the user ID, use it here
INSERT INTO patients (
  user_id,
  date_of_birth,
  gender,
  blood_type,
  height_cm,
  weight_kg,
  emergency_contact_name,
  emergency_contact_phone,
  address,
  city,
  created_at,
  updated_at
) VALUES (
  'USER_ID_HERE', -- Replace with actual user ID
  '1990-01-01',
  'other',
  'O+',
  170.0,
  70.0,
  'Emergency Contact',
  '+1234567891',
  '123 Test Street',
  'Test City',
  NOW(),
  NOW()
)
ON CONFLICT (user_id) DO NOTHING;

-- 3. Verify the patient was created
SELECT 
  u.id as user_id,
  u.email,
  u.role,
  u.first_name,
  u.last_name,
  p.id as patient_id,
  p.date_of_birth,
  p.gender
FROM users u
LEFT JOIN patients p ON u.id = p.user_id
WHERE u.email = 'testpatient@viatra.com';

-- 4. Check if food_logs table exists and is ready
SELECT 
  table_name,
  column_name,
  data_type
FROM information_schema.columns
WHERE table_name = 'food_logs'
ORDER BY ordinal_position;

-- ============================================
-- QUICK METHOD: Use this if you want to quickly test
-- ============================================

-- If your backend has a registration endpoint, you can also use this:
-- POST to /api/auth/register with:
-- {
--   "email": "testpatient@viatra.com",
--   "password": "Test1234!",
--   "firstName": "Test",
--   "lastName": "Patient",
--   "role": "patient",
--   "dateOfBirth": "1990-01-01",
--   "gender": "other"
-- }
