'use strict';

const { v4: uuidv4 } = require('uuid');

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    // Get existing users from seed data (adjust UUIDs based on your seed data)
    // These should match the UUIDs from 20250101000001-seed-users.js
    
    const conversations = [
      {
        id: uuidv4(),
        type: 'direct',
        participant_ids: JSON.stringify([
          // Add actual patient and doctor UUIDs from your user seeds
          '11111111-1111-1111-1111-111111111111', // Example patient UUID
          '22222222-2222-2222-2222-222222222222'  // Example doctor UUID
        ]),
        last_message_at: new Date(Date.now() - 2 * 60 * 60 * 1000), // 2 hours ago
        created_at: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000), // 7 days ago
        updated_at: new Date()
      },
      {
        id: uuidv4(),
        type: 'direct',
        participant_ids: JSON.stringify([
          '11111111-1111-1111-1111-111111111111', // Example patient UUID
          '33333333-3333-3333-3333-333333333333'  // Another doctor UUID
        ]),
        last_message_at: new Date(Date.now() - 24 * 60 * 60 * 1000), // 1 day ago
        created_at: new Date(Date.now() - 14 * 24 * 60 * 60 * 1000), // 14 days ago
        updated_at: new Date()
      }
    ];
    
    await queryInterface.bulkInsert('conversations', conversations, {});
    
    console.log('Seeded conversations successfully');
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.bulkDelete('conversations', null, {});
  }
};
