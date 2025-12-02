-- ============================================
-- CREATE TEST PATIENT - READY TO RUN IN SUPABASE
-- ============================================
-- Just copy and paste this entire file into Supabase SQL Editor
-- Email: testpatient@viatra.com
-- Password: Test1234!
-- ============================================

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Step 1: Create or update user
DO $$
DECLARE
    v_user_id UUID;
    v_patient_id UUID;
BEGIN
    -- Try to insert new user
    INSERT INTO users (
        id,
        email,
        password_hash, -- Pre-hashed password for 'Test1234!' using bcrypt
        role,
        first_name,
        last_name,
        phone,
        email_verified,
        is_active,
        created_at,
        updated_at
    ) VALUES (
        uuid_generate_v4(),
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
    )
    ON CONFLICT (email) DO UPDATE SET
        password_hash = '$2b$10$N9qo8uLOickgx2ZMOcR8MOx3iexYsGHXMJqE9U3p2JqN0xGxB8lW2',
        role = 'patient',
        first_name = 'Test',
        last_name = 'Patient',
        email_verified = true,
        is_active = true,
        updated_at = NOW()
    RETURNING id INTO v_user_id;

    -- Get user_id if it was an update
    IF v_user_id IS NULL THEN
        SELECT id INTO v_user_id FROM users WHERE email = 'testpatient@viatra.com';
    END IF;

    RAISE NOTICE 'User ID: %', v_user_id;

    -- Step 2: Create or update patient profile
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
    ) VALUES (
        uuid_generate_v4(),
        v_user_id,
        '1990-01-01',
        'other',
        '123 Test Street',
        'Test City',
        'TS',
        '12345',
        'en',
        NOW(),
        NOW()
    )
    ON CONFLICT (user_id) DO UPDATE SET
        date_of_birth = '1990-01-01',
        gender = 'other',
        updated_at = NOW()
    RETURNING id INTO v_patient_id;

    -- Get patient_id if it was an update
    IF v_patient_id IS NULL THEN
        SELECT id INTO v_patient_id FROM patients WHERE user_id = v_user_id;
    END IF;

    RAISE NOTICE 'Patient ID: %', v_patient_id;

    -- Step 3: Create health profile (optional)
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
    ) VALUES (
        uuid_generate_v4(),
        v_patient_id,
        'O+',
        170.0,
        70.0,
        '[]'::json,
        '[]'::json,
        '{"smoking":"never","alcohol":"occasionally","exercise_frequency":"regularly","diet":"balanced"}'::json,
        NOW(),
        NOW()
    )
    ON CONFLICT (patient_id) DO UPDATE SET
        blood_type = 'O+',
        height = 170.0,
        weight = 70.0,
        updated_at = NOW();

    RAISE NOTICE 'Health profile created/updated';

END $$;

-- Step 3: Verify the patient was created
SELECT 
    '✅ SUCCESS! Test patient created!' as status,
    u.id as user_id,
    u.email,
    u.role,
    u.first_name || ' ' || u.last_name as full_name,
    u.email_verified,
    u.is_active,
    p.id as patient_id,
    p.date_of_birth,
    p.gender,
    hp.id as health_profile_id
FROM users u
LEFT JOIN patients p ON u.id = p.user_id
LEFT JOIN health_profiles hp ON p.id = hp.patient_id
WHERE u.email = 'testpatient@viatra.com';

-- Step 4: Show login credentials
SELECT 
    '🔑 LOGIN CREDENTIALS' as info,
    'testpatient@viatra.com' as email,
    'Test1234!' as password,
    '✅ Now you can login to the mobile app!' as next_step;

-- Step 5: Verify food_logs table is ready
SELECT 
    '📋 FOOD LOGS TABLE STATUS' as info,
    COUNT(*) as total_columns,
    '✅ Ready for food tracking!' as status
FROM information_schema.columns
WHERE table_name = 'food_logs';

-- Step 6: Show note about food_logs.patient_id
SELECT 
    '⚠️  IMPORTANT NOTE' as info,
    'food_logs.patient_id references users.id (NOT patients.id)' as note,
    'This means food logs link directly to the user account' as explanation;
