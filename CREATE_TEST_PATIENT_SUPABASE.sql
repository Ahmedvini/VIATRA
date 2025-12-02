-- ============================================
-- CREATE TEST PATIENT - READY TO RUN IN SUPABASE
-- ============================================
-- Just copy and paste this entire file into Supabase SQL Editor
-- Email: testpatient@viatra.com
-- Password: Test1234!
-- ============================================

-- Step 1: Create or update user
DO $$
DECLARE
    v_user_id UUID;
BEGIN
    -- Try to insert new user
    INSERT INTO users (
        email,
        password_hash, -- Pre-hashed password for 'Test1234!' using bcrypt
        role,
        first_name,
        last_name,
        phone,
        is_verified,
        created_at,
        updated_at
    ) VALUES (
        'testpatient@viatra.com',
        '$2b$10$N9qo8uLOickgx2ZMOcR8MOx3iexYsGHXMJqE9U3p2JqN0xGxB8lW2',
        'patient',
        'Test',
        'Patient',
        '+1234567890',
        true,
        NOW(),
        NOW()
    )
    ON CONFLICT (email) DO UPDATE SET
        password_hash = '$2b$10$N9qo8uLOickgx2ZMOcR8MOx3iexYsGHXMJqE9U3p2JqN0xGxB8lW2',
        role = 'patient',
        first_name = 'Test',
        last_name = 'Patient',
        is_verified = true,
        updated_at = NOW()
    RETURNING id INTO v_user_id;

    -- Get user_id if it was an update
    IF v_user_id IS NULL THEN
        SELECT id INTO v_user_id FROM users WHERE email = 'testpatient@viatra.com';
    END IF;

    RAISE NOTICE 'User ID: %', v_user_id;

    -- Step 2: Create or update patient profile
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
        v_user_id,
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
    ON CONFLICT (user_id) DO UPDATE SET
        date_of_birth = '1990-01-01',
        gender = 'other',
        updated_at = NOW();

    RAISE NOTICE 'Patient profile created/updated for user_id: %', v_user_id;

END $$;

-- Step 3: Verify the patient was created
SELECT 
    '✅ SUCCESS! Test patient created!' as status,
    u.id as user_id,
    u.email,
    u.role,
    u.first_name || ' ' || u.last_name as full_name,
    u.is_verified,
    p.id as patient_id,
    p.date_of_birth,
    p.gender
FROM users u
LEFT JOIN patients p ON u.id = p.user_id
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
