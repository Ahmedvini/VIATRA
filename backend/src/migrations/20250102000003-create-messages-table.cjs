'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('messages', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
        allowNull: false
      },
      conversation_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: {
          model: 'conversations',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      sender_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: {
          model: 'users',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      content: {
        type: Sequelize.TEXT,
        allowNull: false
      },
      message_type: {
        type: Sequelize.ENUM('text', 'image', 'file', 'system'),
        allowNull: false,
        defaultValue: 'text'
      },
      metadata: {
        type: Sequelize.JSONB,
        allowNull: true,
        defaultValue: {}
      },
      read_by: {
        type: Sequelize.JSONB,
        allowNull: false,
        defaultValue: []
      },
      delivered_to: {
        type: Sequelize.JSONB,
        allowNull: false,
        defaultValue: []
      },
      is_deleted: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: false
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

    // Composite index for efficient message history queries (newest first)
    await queryInterface.addIndex('messages', ['conversation_id', 'created_at'], {
      name: 'idx_messages_conversation_created',
      order: [['conversation_id', 'ASC'], ['created_at', 'DESC']]
    });

    // Index on sender_id for user message lookups
    await queryInterface.addIndex('messages', ['sender_id'], {
      name: 'idx_messages_sender_id'
    });

    // Index on message_type for filtering
    await queryInterface.addIndex('messages', ['message_type'], {
      name: 'idx_messages_type'
    });

    // Index on is_deleted for filtering out deleted messages
    await queryInterface.addIndex('messages', ['is_deleted'], {
      name: 'idx_messages_is_deleted'
    });
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('messages');
  }
};
