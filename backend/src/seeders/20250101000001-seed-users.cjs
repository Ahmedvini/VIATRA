'use strict';
const bcrypt = require('bcrypt');

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    const hashedPassword = await bcrypt.hash('password123', 12);
    
    await queryInterface.bulkInsert('users', [
      {
        id: 'a1b2c3d4-e5f6-7890-1234-567890abcdef',
        email: 'admin@viatra.health',
        password_hash: hashedPassword,
        first_name: 'System',
        last_name: 'Administrator',
        phone: '+1234567890',
        role: 'admin',
        is_active: true,
        email_verified: true,
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        id: 'b1c2d3e4-f5a6-7890-1234-567890bcdefg',
        email: 'dr.smith@viatra.health',
        password_hash: hashedPassword,
        first_name: 'John',
        last_name: 'Smith',
        phone: '+1234567891',
        role: 'doctor',
        is_active: true,
        email_verified: true,
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        id: 'c1d2e3f4-a5b6-7890-1234-567890cdefgh',
        email: 'dr.johnson@viatra.health',
        password_hash: hashedPassword,
        first_name: 'Emily',
        last_name: 'Johnson',
        phone: '+1234567892',
        role: 'doctor',
        is_active: true,
        email_verified: true,
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        id: 'd1e2f3a4-b5c6-7890-1234-567890defghi',
        email: 'dr.brown@viatra.health',
        password_hash: hashedPassword,
        first_name: 'Michael',
        last_name: 'Brown',
        phone: '+1234567893',
        role: 'doctor',
        is_active: true,
        email_verified: true,
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        id: 'e1f2a3b4-c5d6-7890-1234-567890efghij',
        email: 'patient1@example.com',
        password_hash: hashedPassword,
        first_name: 'Sarah',
        last_name: 'Davis',
        phone: '+1234567894',
        role: 'patient',
        is_active: true,
        email_verified: true,
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        id: 'f1a2b3c4-d5e6-7890-1234-567890fghijk',
        email: 'patient2@example.com',
        password_hash: hashedPassword,
        first_name: 'Robert',
        last_name: 'Wilson',
        phone: '+1234567895',
        role: 'patient',
        is_active: true,
        email_verified: true,
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        id: 'a2b3c4d5-e6f7-8901-2345-678901abcdef',
        email: 'patient3@example.com',
        password_hash: hashedPassword,
        first_name: 'Lisa',
        last_name: 'Anderson',
        phone: '+1234567896',
        role: 'patient',
        is_active: true,
        email_verified: true,
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        id: 'b2c3d4e5-f6a7-8901-2345-678901bcdefg',
        email: 'patient4@example.com',
        password_hash: hashedPassword,
        first_name: 'James',
        last_name: 'Miller',
        phone: '+1234567897',
        role: 'patient',
        is_active: true,
        email_verified: true,
        created_at: new Date(),
        updated_at: new Date()
      }
    ], {});
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.bulkDelete('users', null, {});
  }
};
