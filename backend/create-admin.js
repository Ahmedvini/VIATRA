import bcrypt from 'bcryptjs';
import { User } from './src/models/index.js';
import { getSequelize } from './src/config/database.js';

/**
 * Create admin user script
 * Usage: node create-admin.js
 */

async function createAdmin() {
  try {
    const sequelize = getSequelize();
    await sequelize.authenticate();
    console.log('✓ Database connected');

    // Admin credentials
    const adminData = {
      email: 'admin@viatra.health',
      password: 'Admin@2025!Viatra',
      first_name: 'Admin',
      last_name: 'User',
      phone: '+20 100 000 0000',
      role: 'admin',
      is_active: true,
      email_verified: true,
    };

    // Check if admin already exists
    const existingAdmin = await User.findOne({ 
      where: { email: adminData.email } 
    });

    if (existingAdmin) {
      console.log('⚠ Admin user already exists');
      console.log('Email:', adminData.email);
      console.log('You may need to reset the password');
      process.exit(0);
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const password_hash = await bcrypt.hash(adminData.password, salt);

    // Create admin user
    const admin = await User.create({
      ...adminData,
      password_hash,
    });

    console.log('\n✓ Admin user created successfully!');
    console.log('\n================================');
    console.log('ADMIN CREDENTIALS:');
    console.log('================================');
    console.log('Email:    ', adminData.email);
    console.log('Password: ', adminData.password);
    console.log('Role:     ', adminData.role);
    console.log('================================');
    console.log('\n⚠ IMPORTANT: Save these credentials securely!');
    console.log('⚠ Change the password after first login!\n');

    process.exit(0);
  } catch (error) {
    console.error('✗ Error creating admin user:', error.message);
    console.error(error);
    process.exit(1);
  }
}

createAdmin();
