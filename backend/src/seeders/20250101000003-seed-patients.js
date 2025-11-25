'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.bulkInsert('patients', [
      {
        id: '44e1f2a3-b4c5-d678-9012-3456789abcde',
        user_id: 'e1f2a3b4-c5d6-7890-1234-567890efghij', // Sarah Davis
        date_of_birth: '1990-05-15',
        gender: 'female',
        address_line1: '123 Maple Street',
        address_line2: 'Apt 4B',
        city: 'Boston',
        state: 'MA',
        zip_code: '02134',
        preferred_language: 'en',
        marital_status: 'single',
        occupation: 'Software Engineer',
        employer: 'TechCorp Inc.',
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        id: '55f1a2b3-c4d5-e678-9012-3456789bcdef',
        user_id: 'f1a2b3c4-d5e6-7890-1234-567890fghijk', // Robert Wilson
        date_of_birth: '1985-11-22',
        gender: 'male',
        address_line1: '456 Oak Avenue',
        address_line2: null,
        city: 'San Francisco',
        state: 'CA',
        zip_code: '94117',
        preferred_language: 'en',
        marital_status: 'married',
        occupation: 'Marketing Manager',
        employer: 'AdCorp Solutions',
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        id: '66a2b3c4-d5e6-f789-0123-456789cdefgh',
        user_id: 'a2b3c4d5-e6f7-8901-2345-678901abcdef', // Lisa Anderson
        date_of_birth: '1992-03-08',
        gender: 'female',
        address_line1: '789 Pine Road',
        address_line2: 'Unit 12',
        city: 'New York',
        state: 'NY',
        zip_code: '10025',
        preferred_language: 'en',
        marital_status: 'single',
        occupation: 'Teacher',
        employer: 'NYC Public Schools',
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        id: '77b2c3d4-e5f6-a789-0123-456789defghi',
        user_id: 'b2c3d4e5-f6a7-8901-2345-678901bcdefg', // James Miller
        date_of_birth: '1978-09-12',
        gender: 'male',
        address_line1: '321 Elm Street',
        address_line2: null,
        city: 'Chicago',
        state: 'IL',
        zip_code: '60614',
        preferred_language: 'en',
        marital_status: 'divorced',
        occupation: 'Accountant',
        employer: 'Financial Services LLC',
        created_at: new Date(),
        updated_at: new Date()
      }
    ], {});
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.bulkDelete('patients', null, {});
  }
};
