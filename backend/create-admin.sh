`#!/bin/bash
# Script to create admin user via Railway CLI
# Make sure you have Railway CLI installed and logged in

echo "Creating Admin User for VIATRA..."
echo ""

# Generate bcrypt hash for password: Admin@2025!Viatra
# You can use online bcrypt generator or node script

cat << 'EOF'
================================
ADMIN USER INSTRUCTIONS
================================

To create the admin user, run this SQL query in Railway PostgreSQL:

1. Go to Railway Dashboard
2. Open your PostgreSQL database
3. Click on "Query" tab
4. Run this SQL:

-- Create admin user with password: Admin@2025!Viatra
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

-- Verify admin was created
SELECT id, email, first_name, last_name, role, is_active, email_verified 
FROM users 
WHERE email = 'admin@viatra.health';

================================
ADMIN CREDENTIALS:
================================
Email:     admin@viatra.health
Password:  Admin@2025!Viatra
Role:      admin
================================

⚠ IMPORTANT: 
- Save these credentials securely!
- Change the password after first login!
- Make sure to enable pgcrypto extension first:
  CREATE EXTENSION IF NOT EXISTS pgcrypto;

EOF
