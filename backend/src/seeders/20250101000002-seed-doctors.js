'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.bulkInsert('doctors', [
      {
        id: '11b2c3d4-e5f6-7890-1234-567890abcdef',
        user_id: 'b1c2d3e4-f5a6-7890-1234-567890bcdefg', // Dr. John Smith
        license_number: 'MD123456',
        specialty: 'Internal Medicine',
        sub_specialty: 'Cardiology',
        title: 'Dr.',
        npi_number: '1234567890',
        dea_number: 'BS1234567',
        years_of_experience: 15,
        education: 'Harvard Medical School (MD), Johns Hopkins Residency',
        certifications: ['Board Certified Internal Medicine', 'Board Certified Cardiology'],
        languages_spoken: ['en', 'es'],
        bio: 'Dr. Smith is a board-certified cardiologist with over 15 years of experience treating heart conditions.',
        consultation_fee: 250.00,
        telehealth_enabled: true,
        is_accepting_patients: true,
        office_address_line1: '123 Medical Center Dr',
        office_city: 'Boston',
        office_state: 'MA',
        office_zip_code: '02101',
        office_phone: '+1617555-0101',
        working_hours: {
          monday: { start: '08:00', end: '17:00', available: true },
          tuesday: { start: '08:00', end: '17:00', available: true },
          wednesday: { start: '08:00', end: '17:00', available: true },
          thursday: { start: '08:00', end: '17:00', available: true },
          friday: { start: '08:00', end: '16:00', available: true },
          saturday: { start: null, end: null, available: false },
          sunday: { start: null, end: null, available: false }
        },
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        id: '22c2d3e4-f5a6-7890-1234-567890bcdefg',
        user_id: 'c1d2e3f4-a5b6-7890-1234-567890cdefgh', // Dr. Emily Johnson
        license_number: 'MD789012',
        specialty: 'Pediatrics',
        sub_specialty: null,
        title: 'Dr.',
        npi_number: '2345678901',
        dea_number: 'BJ2345678',
        years_of_experience: 8,
        education: 'Stanford University School of Medicine (MD), Children\'s Hospital of Philadelphia Residency',
        certifications: ['Board Certified Pediatrics'],
        languages_spoken: ['en', 'fr'],
        bio: 'Dr. Johnson specializes in pediatric care with a focus on preventive medicine and child development.',
        consultation_fee: 200.00,
        telehealth_enabled: true,
        is_accepting_patients: true,
        office_address_line1: '456 Pediatric Way',
        office_city: 'San Francisco',
        office_state: 'CA',
        office_zip_code: '94102',
        office_phone: '+1415555-0102',
        working_hours: {
          monday: { start: '09:00', end: '18:00', available: true },
          tuesday: { start: '09:00', end: '18:00', available: true },
          wednesday: { start: '09:00', end: '18:00', available: true },
          thursday: { start: '09:00', end: '18:00', available: true },
          friday: { start: '09:00', end: '17:00', available: true },
          saturday: { start: '10:00', end: '14:00', available: true },
          sunday: { start: null, end: null, available: false }
        },
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        id: '33d2e3f4-a5b6-7890-1234-567890cdefgh',
        user_id: 'd1e2f3a4-b5c6-7890-1234-567890defghi', // Dr. Michael Brown
        license_number: 'MD345678',
        specialty: 'Dermatology',
        sub_specialty: 'Cosmetic Dermatology',
        title: 'Dr.',
        npi_number: '3456789012',
        dea_number: 'BB3456789',
        years_of_experience: 12,
        education: 'Yale School of Medicine (MD), Mayo Clinic Dermatology Residency',
        certifications: ['Board Certified Dermatology', 'Cosmetic Surgery Certified'],
        languages_spoken: ['en'],
        bio: 'Dr. Brown is a dermatologist with expertise in both medical and cosmetic procedures.',
        consultation_fee: 300.00,
        telehealth_enabled: true,
        is_accepting_patients: true,
        office_address_line1: '789 Dermatology Plaza',
        office_city: 'New York',
        office_state: 'NY',
        office_zip_code: '10001',
        office_phone: '+1212555-0103',
        working_hours: {
          monday: { start: '10:00', end: '19:00', available: true },
          tuesday: { start: '10:00', end: '19:00', available: true },
          wednesday: { start: '10:00', end: '19:00', available: true },
          thursday: { start: '10:00', end: '19:00', available: true },
          friday: { start: '10:00', end: '17:00', available: true },
          saturday: { start: null, end: null, available: false },
          sunday: { start: null, end: null, available: false }
        },
        created_at: new Date(),
        updated_at: new Date()
      }
    ], {});
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.bulkDelete('doctors', null, {});
  }
};
