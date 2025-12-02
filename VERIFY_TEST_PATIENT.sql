-- ============================================
-- VERIFY TEST PATIENT EXISTS
-- ============================================
-- Run this in Supabase SQL Editor to check if test patient was created

-- Check if user exists
SELECT 
    'USER' as record_type,
    id,
    email,
    role,
    first_name,
    last_name,
    email_verified,
    is_active,
    created_at
FROM users 
WHERE email = 'testpatient@viatra.com';

-- Check if patient exists
SELECT 
    'PATIENT' as record_type,
    p.id as patient_id,
    p.user_id,
    u.email,
    p.date_of_birth,
    p.gender,
    p.created_at
FROM patients p
JOIN users u ON p.user_id = u.id
WHERE u.email = 'testpatient@viatra.com';

-- Check if health profile exists
SELECT 
    'HEALTH_PROFILE' as record_type,
    hp.id as profile_id,
    hp.patient_id,
    u.email,
    hp.blood_type,
    hp.height,
    hp.weight,
    hp.created_at
FROM health_profiles hp
JOIN patients p ON hp.patient_id = p.id
JOIN users u ON p.user_id = u.id
WHERE u.email = 'testpatient@viatra.com';

-- Count food logs for this patient
SELECT 
    'FOOD_LOGS_COUNT' as record_type,
    COUNT(*) as total_logs,
    u.email
FROM food_logs fl
JOIN users u ON fl.patient_id = u.id
WHERE u.email = 'testpatient@viatra.com'
GROUP BY u.email;

-- Show the complete patient data structure
SELECT 
    u.id as user_id,
    u.email,
    u.role,
    u.first_name,
    u.last_name,
    p.id as patient_id,
    p.date_of_birth,
    p.gender,
    hp.id as health_profile_id,
    hp.blood_type,
    hp.height,
    hp.weight
FROM users u
LEFT JOIN patients p ON p.user_id = u.id
LEFT JOIN health_profiles hp ON hp.patient_id = p.id
WHERE u.email = 'testpatient@viatra.com';
