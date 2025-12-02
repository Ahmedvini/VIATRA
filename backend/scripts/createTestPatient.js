/**
 * Create Test Patient Script
 * 
 * This script creates a test patient account for testing the food tracking feature.
 * 
 * Usage:
 *   cd backend
 *   node scripts/createTestPatient.js
 * 
 * Test Credentials:
 *   Email: testpatient@viatra.com
 *   Password: Test1234!
 */

import bcrypt from 'bcrypt';
import { Sequelize } from 'sequelize';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Load environment variables
dotenv.config({ path: path.join(__dirname, '..', '.env') });

// Database connection
const sequelize = new Sequelize(process.env.DATABASE_URL, {
  dialect: 'postgres',
  logging: false,
  dialectOptions: {
    ssl: {
      require: true,
      rejectUnauthorized: false
    }
  }
});

async function createTestPatient() {
  try {
    console.log('🔌 Connecting to database...');
    await sequelize.authenticate();
    console.log('✅ Database connected successfully!');

    const email = 'testpatient@viatra.com';
    const password = 'Test1234!';
    
    console.log('\n📝 Creating test patient...');
    console.log('Email:', email);
    console.log('Password:', password);

    // Hash password
    const passwordHash = await bcrypt.hash(password, 10);

    // Check if user already exists
    const [existingUser] = await sequelize.query(
      `SELECT id, email FROM users WHERE email = $1`,
      {
        bind: [email],
        type: Sequelize.QueryTypes.SELECT
      }
    );

    let userId;

    if (existingUser) {
      console.log('\n⚠️  User already exists with ID:', existingUser.id);
      userId = existingUser.id;
      
      // Update the user
      await sequelize.query(
        `UPDATE users 
         SET password_hash = $1, 
             role = 'patient',
             is_verified = true,
             first_name = 'Test',
             last_name = 'Patient',
             updated_at = NOW()
         WHERE id = $2`,
        {
          bind: [passwordHash, userId]
        }
      );
      console.log('✅ User updated with new password');
    } else {
      // Create new user
      const [newUser] = await sequelize.query(
        `INSERT INTO users (
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
          $1, $2, 'patient', 'Test', 'Patient', '+1234567890', true, NOW(), NOW()
        ) RETURNING id`,
        {
          bind: [email, passwordHash],
          type: Sequelize.QueryTypes.INSERT
        }
      );
      
      userId = newUser[0].id;
      console.log('✅ User created with ID:', userId);
    }

    // Check if patient profile exists
    const [existingPatient] = await sequelize.query(
      `SELECT id FROM patients WHERE user_id = $1`,
      {
        bind: [userId],
        type: Sequelize.QueryTypes.SELECT
      }
    );

    if (existingPatient) {
      console.log('✅ Patient profile already exists with ID:', existingPatient.id);
    } else {
      // Create patient profile
      const [newPatient] = await sequelize.query(
        `INSERT INTO patients (
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
          $1, '1990-01-01', 'other', 'O+', 170.0, 70.0,
          'Emergency Contact', '+1234567891', '123 Test Street', 'Test City',
          NOW(), NOW()
        ) RETURNING id`,
        {
          bind: [userId],
          type: Sequelize.QueryTypes.INSERT
        }
      );
      
      console.log('✅ Patient profile created with ID:', newPatient[0].id);
    }

    // Verify the created patient
    const [verifyResult] = await sequelize.query(
      `SELECT 
        u.id as user_id,
        u.email,
        u.role,
        u.first_name,
        u.last_name,
        u.is_verified,
        p.id as patient_id,
        p.date_of_birth,
        p.gender
       FROM users u
       LEFT JOIN patients p ON u.id = p.user_id
       WHERE u.email = $1`,
      {
        bind: [email],
        type: Sequelize.QueryTypes.SELECT
      }
    );

    console.log('\n✅ Test patient created successfully!');
    console.log('\n📋 Patient Details:');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('User ID:     ', verifyResult.user_id);
    console.log('Patient ID:  ', verifyResult.patient_id);
    console.log('Email:       ', verifyResult.email);
    console.log('Role:        ', verifyResult.role);
    console.log('Name:        ', verifyResult.first_name, verifyResult.last_name);
    console.log('Verified:    ', verifyResult.is_verified);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('\n🔑 Login Credentials:');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('Email:    ', email);
    console.log('Password: ', password);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('\n🚀 You can now login to the app and test food tracking!');

  } catch (error) {
    console.error('\n❌ Error creating test patient:', error.message);
    console.error('Stack:', error.stack);
    process.exit(1);
  } finally {
    await sequelize.close();
  }
}

// Run the script
createTestPatient();
