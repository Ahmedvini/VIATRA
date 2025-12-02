-- ============================================
-- VIATRA Test Patient Creation Script (VERIFIED)
-- Compatible with Supabase PostgreSQL
-- Password hashing: bcrypt with 12 rounds
-- ============================================

-- Enable pgcrypto extension for password hashing (if not already enabled)
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Start transaction
BEGIN;

-- ============================================
-- STEP 1: Create test user account
-- ============================================
-- Email: testpatient@viatra.com
-- Password: TestPatient123!
-- The password will be hashed using bcrypt with 12 rounds to match backend

-- Generate UUID for the user
DO $$
DECLARE
    v_user_id UUID := gen_random_uuid();
    v_patient_id UUID := gen_random_uuid();
    v_health_profile_id UUID := gen_random_uuid();
BEGIN
    -- Insert into users table
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
    ) VALUES (
        v_user_id,
        'testpatient@viatra.com',
        crypt('TestPatient123!', gen_salt('bf', 12)),  -- bcrypt with 12 rounds
        'Test',
        'Patient',
        '+1234567890',
        'patient',
        true,
        true,  -- Skip email verification for testing
        NOW(),
        NOW()
    )
    ON CONFLICT (email) DO NOTHING;

    -- Get the user_id if it was just created or already exists
    SELECT id INTO v_user_id FROM users WHERE email = 'testpatient@viatra.com';

    -- ============================================
    -- STEP 2: Create patient profile
    -- ============================================
    INSERT INTO patients (
        id,
        user_id,
        date_of_birth,
        gender,
        preferred_language,
        created_at,
        updated_at
    ) VALUES (
        v_patient_id,
        v_user_id,
        '1990-01-01',
        'other',
        'en',
        NOW(),
        NOW()
    )
    ON CONFLICT (user_id) DO NOTHING;

    -- Get the patient_id
    SELECT id INTO v_patient_id FROM patients WHERE user_id = v_user_id;

    -- ============================================
    -- STEP 3: Create health profile
    -- ============================================
    INSERT INTO health_profiles (
        id,
        patient_id,
        blood_type,
        height,
        weight,
        allergies,
        chronic_conditions,
        current_medications,
        emergency_contact_name,
        emergency_contact_phone,
        emergency_contact_relationship,
        created_at,
        updated_at
    ) VALUES (
        v_health_profile_id,
        v_patient_id,
        'O+',
        170.0,
        70.0,
        '[]'::JSON,
        '[]'::JSON,
        '[]'::JSON,
        'Emergency Contact',
        '+1234567891',
        'Family',
        NOW(),
        NOW()
    )
    ON CONFLICT (patient_id) DO NOTHING;

    -- ============================================
    -- STEP 4: Create sample food logs for testing
    -- ============================================
    -- Create 3 sample food logs (Breakfast, Lunch, Dinner)
    INSERT INTO food_logs (
        id,
        patient_id,
        meal_type,
        food_name,
        description,
        calories,
        protein_grams,
        carbs_grams,
        fat_grams,
        fiber_grams,
        sugar_grams,
        sodium_mg,
        serving_size,
        servings_count,
        consumed_at,
        created_at,
        updated_at
    ) VALUES 
    -- Breakfast
    (
        gen_random_uuid(),
        v_user_id,  -- food_logs.patient_id references users.id
        'breakfast',
        'Oatmeal with Berries',
        'Bowl of oatmeal topped with mixed berries',
        350.0,
        12.0,
        55.0,
        8.0,
        10.0,
        15.0,
        150.0,
        '1 bowl',
        1.0,
        NOW() - INTERVAL '2 hours',
        NOW(),
        NOW()
    ),
    -- Lunch
    (
        gen_random_uuid(),
        v_user_id,
        'lunch',
        'Grilled Chicken Salad',
        'Mixed greens with grilled chicken breast',
        450.0,
        35.0,
        25.0,
        18.0,
        6.0,
        8.0,
        580.0,
        '1 plate',
        1.0,
        NOW() - INTERVAL '4 hours',
        NOW(),
        NOW()
    ),
    -- Dinner
    (
        gen_random_uuid(),
        v_user_id,
        'dinner',
        'Salmon with Vegetables',
        'Baked salmon with steamed broccoli and carrots',
        520.0,
        38.0,
        30.0,
        22.0,
        8.0,
        6.0,
        420.0,
        '1 plate',
        1.0,
        NOW() - INTERVAL '6 hours',
        NOW(),
        NOW()
    );

    -- Output success message
    RAISE NOTICE 'Test patient created successfully!';
    RAISE NOTICE 'User ID: %', v_user_id;
    RAISE NOTICE 'Patient ID: %', v_patient_id;
    RAISE NOTICE 'Email: testpatient@viatra.com';
    RAISE NOTICE 'Password: TestPatient123!';
    
END $$;

-- Commit transaction
COMMIT;

-- ============================================
-- VERIFICATION QUERIES
-- ============================================
-- Run these queries to verify the data was created correctly

-- Check user
SELECT 
    id,
    email,
    first_name,
    last_name,
    role,
    is_active,
    email_verified,
    created_at
FROM users 
WHERE email = 'testpatient@viatra.com';

-- Check patient profile
SELECT 
    p.id,
    p.user_id,
    p.date_of_birth,
    p.gender,
    p.blood_type,
    u.email
FROM patients p
JOIN users u ON p.user_id = u.id
WHERE u.email = 'testpatient@viatra.com';

-- Check health profile
SELECT 
    hp.id,
    hp.patient_id,
    hp.blood_type,
    hp.height,
    hp.weight,
    hp.allergies,
    hp.chronic_conditions,
    hp.emergency_contact_name,
    hp.emergency_contact_phone,
    u.email
FROM health_profiles hp
JOIN patients p ON hp.patient_id = p.id
JOIN users u ON p.user_id = u.id
WHERE u.email = 'testpatient@viatra.com';

-- Check food logs
SELECT 
    fl.id,
    fl.meal_type,
    fl.food_name,
    fl.calories,
    fl.consumed_at,
    u.email
FROM food_logs fl
JOIN users u ON fl.patient_id = u.id
WHERE u.email = 'testpatient@viatra.com'
ORDER BY fl.consumed_at DESC;

-- Count total records
SELECT 
    'Total Food Logs' as record_type,
    COUNT(*) as count
FROM food_logs fl
JOIN users u ON fl.patient_id = u.id
WHERE u.email = 'testpatient@viatra.com';
