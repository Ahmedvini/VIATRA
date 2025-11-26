'use strict';

const { v4: uuidv4 } = require('uuid');

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    // Fetch conversations to get IDs and participant info
    const conversations = await queryInterface.sequelize.query(
      'SELECT id, participant_ids FROM conversations LIMIT 2;',
      { type: Sequelize.QueryTypes.SELECT }
    );
    
    if (conversations.length === 0) {
      console.log('No conversations found. Run conversation seeder first.');
      return;
    }
    
    const messages = [];
    
    // Create messages for each conversation
    conversations.forEach((conv, index) => {
      const participants = JSON.parse(conv.participant_ids);
      const [patient, doctor] = participants;
      
      // Create conversation messages with alternating senders
      const conversationMessages = [
        {
          id: uuidv4(),
          conversation_id: conv.id,
          sender_id: patient,
          content: 'Hello Dr., I have a question about my recent appointment.',
          message_type: 'text',
          metadata: JSON.stringify({}),
          read_by: JSON.stringify([patient, doctor]),
          delivered_to: JSON.stringify([patient, doctor]),
          is_deleted: false,
          created_at: new Date(Date.now() - (10 - index) * 24 * 60 * 60 * 1000),
          updated_at: new Date()
        },
        {
          id: uuidv4(),
          conversation_id: conv.id,
          sender_id: doctor,
          content: 'Hello! I\'d be happy to help. What would you like to know?',
          message_type: 'text',
          metadata: JSON.stringify({}),
          read_by: JSON.stringify([patient, doctor]),
          delivered_to: JSON.stringify([patient, doctor]),
          is_deleted: false,
          created_at: new Date(Date.now() - (9 - index) * 24 * 60 * 60 * 1000),
          updated_at: new Date()
        },
        {
          id: uuidv4(),
          conversation_id: conv.id,
          sender_id: patient,
          content: 'I was wondering about the medication you prescribed. When should I take it?',
          message_type: 'text',
          metadata: JSON.stringify({}),
          read_by: JSON.stringify([patient, doctor]),
          delivered_to: JSON.stringify([patient, doctor]),
          is_deleted: false,
          created_at: new Date(Date.now() - (8 - index) * 24 * 60 * 60 * 1000),
          updated_at: new Date()
        },
        {
          id: uuidv4(),
          conversation_id: conv.id,
          sender_id: doctor,
          content: 'Take the medication twice daily with meals - once in the morning and once in the evening.',
          message_type: 'text',
          metadata: JSON.stringify({}),
          read_by: JSON.stringify([patient, doctor]),
          delivered_to: JSON.stringify([patient, doctor]),
          is_deleted: false,
          created_at: new Date(Date.now() - (7 - index) * 24 * 60 * 60 * 1000),
          updated_at: new Date()
        },
        {
          id: uuidv4(),
          conversation_id: conv.id,
          sender_id: patient,
          content: 'Thank you! That\'s very helpful.',
          message_type: 'text',
          metadata: JSON.stringify({}),
          read_by: JSON.stringify([patient]),
          delivered_to: JSON.stringify([patient, doctor]),
          is_deleted: false,
          created_at: new Date(Date.now() - (6 - index) * 24 * 60 * 60 * 1000),
          updated_at: new Date()
        },
        {
          id: uuidv4(),
          conversation_id: conv.id,
          sender_id: 'system',
          content: 'Appointment confirmed for tomorrow at 10:00 AM',
          message_type: 'system',
          metadata: JSON.stringify({ appointmentId: uuidv4() }),
          read_by: JSON.stringify([patient, doctor]),
          delivered_to: JSON.stringify([patient, doctor]),
          is_deleted: false,
          created_at: new Date(Date.now() - (5 - index) * 24 * 60 * 60 * 1000),
          updated_at: new Date()
        }
      ];
      
      messages.push(...conversationMessages);
    });
    
    await queryInterface.bulkInsert('messages', messages, {});
    
    // Update conversations with last_message_id
    for (const conv of conversations) {
      const lastMessage = messages
        .filter(m => m.conversation_id === conv.id)
        .sort((a, b) => b.created_at - a.created_at)[0];
      
      if (lastMessage) {
        await queryInterface.sequelize.query(
          `UPDATE conversations SET last_message_id = '${lastMessage.id}', 
           last_message_at = '${lastMessage.created_at.toISOString()}' 
           WHERE id = '${conv.id}';`
        );
      }
    }
    
    console.log(`Seeded ${messages.length} messages successfully`);
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.bulkDelete('messages', null, {});
  }
};
