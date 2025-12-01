'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('conversations', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
        allowNull: false
      },
      type: {
        type: Sequelize.ENUM('direct', 'group'),
        allowNull: false,
        defaultValue: 'direct'
      },
      participant_ids: {
        type: Sequelize.JSONB,
        allowNull: false,
        defaultValue: []
      },
      last_message_id: {
        type: Sequelize.UUID,
        allowNull: true,
        references: {
          model: 'messages',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'SET NULL'
      },
      last_message_at: {
        type: Sequelize.DATE,
        allowNull: true
      },
      created_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
      },
      updated_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
      }
    });

    // Add GIN index for efficient participant lookups in JSONB array
    await queryInterface.sequelize.query(
      'CREATE INDEX idx_conversations_participant_ids ON conversations USING GIN (participant_ids);'
    );

    // Add index on last_message_at for sorting conversations by recency
    await queryInterface.addIndex('conversations', ['last_message_at'], {
      name: 'idx_conversations_last_message_at'
    });

    // Add index on type for filtering by conversation type
    await queryInterface.addIndex('conversations', ['type'], {
      name: 'idx_conversations_type'
    });
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('conversations');
  }
};
