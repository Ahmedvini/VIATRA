-- ============================================
-- SIMPLE TEST PATIENT CREATION - SUPABASE
-- ============================================
-- Copy and paste this ENTIRE script into Supabase SQL Editor
-- Then click "Run"
-- 
-- Credentials:
-- Email: testpatient@viatra.com
-- Password: Test1234!
-- ============================================

-- Step 1: Delete existing test patient (if exists)
DELETE FROM health_profiles 
WHERE patient_id IN (
    SELECT id FROM patients WHERE user_id IN (
        SELECT id FROM users WHERE email = 'testpatient@viatra.com'
    )
);

DELETE FROM patients 
WHERE user_id IN (
    SELECT id FROM users WHERE email = 'testpatient@viatra.com'
);

DELETE FROM food_logs
WHERE patient_id IN (
    SELECT id FROM users WHERE email = 'testpatient@viatra.com'
);

DELETE FROM users WHERE email = 'testpatient@viatra.com';

-- Step 2: Create new test user
-- Password hash for 'Test1234!' using bcrypt
INSERT INTO users (
    id,
    email,
    password_hash,
    role,
    first_name,
    last_name,
    phone,
    email_verified,
    is_active,
    created_at,
    updated_at
) VALUES (
    gen_random_uuid(),
    'testpatient@viatra.com',
    '$2b$10$N9qo8uLOickgx2ZMOcR8MOx3iexYsGHXMJqE9U3p2JqN0xGxB8lW2',
    'patient',
    'Test',
    'Patient',
    '+1234567890',
    true,
    true,
    NOW(),
    NOW()
);

-- Step 3: Create patient profile
INSERT INTO patients (
    id,
    user_id,
    date_of_birth,
    gender,
    address_line1,
    city,
    state,
    zip_code,
    preferred_language,
    created_at,
    updated_at
)
SELECT 
    gen_random_uuid(),
    id,
    '1990-01-01'::date,
    'other',
    '123 Test Street',
    'Test City',
    'TS',
    '12345',
    'en',
    NOW(),
    NOW()
FROM users WHERE email = 'testpatient@viatra.com';

-- Step 4: Create health profile
INSERT INTO health_profiles (
    id,
    patient_id,
    blood_type,
    height,
    weight,
    allergies,
    chronic_conditions,
    lifestyle,
    created_at,
    updated_at
)
SELECT 
    gen_random_uuid(),
    p.id,
    'O+',
    170.0,
    70.0,
    '[]'::json,
    '[]'::json,
    '{"smoking":"never","alcohol":"occasionally","exercise_frequency":"regularly","diet":"balanced"}'::json,
    NOW(),
    NOW()
FROM patients p
JOIN users u ON p.user_id = u.id
WHERE u.email = 'testpatient@viatra.com';

-- Step 5: Verify creation
SELECT 
    'Test patient created successfully!' as message,
    u.id as user_id,
    u.email,
    u.role,
    p.id as patient_id,
    hp.id as health_profile_id
FROM users u
LEFT JOIN patients p ON p.user_id = u.id
LEFT JOIN health_profiles hp ON hp.patient_id = p.id
WHERE u.email = 'testpatient@viatra.com';
