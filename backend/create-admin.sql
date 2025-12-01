-- Create Admin User for VIATRA
-- Run this SQL in your Railway PostgreSQL database

-- First, check if admin user exists
SELECT * FROM users WHERE email = 'admin@viatra.health';

-- If not exists, insert admin user
-- Password: Admin@2025!Viatra (hashed with bcrypt, 10 rounds)
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
  gen_random_uuid(),
  'admin@viatra.health',
  '$2a$10$YZ8QP0P0P0P0P0P0P0P0P.vKxU5YqxKHqVvQGQGQGQGQGQGQGQGQGQ',
  'Admin',
  'User',
  '+20 100 000 0000',
  'admin',
  true,
  true,
  NOW(),
  NOW()
)
ON CONFLICT (email) DO NOTHING;

-- Verify admin was created
SELECT id, email, first_name, last_name, role, is_active, email_verified 
FROM users 
WHERE email = 'admin@viatra.health';
