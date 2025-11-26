import { Model } from 'sequelize';

export default (sequelize, DataTypes) => {
  class Message extends Model {
    static associate(models) {
      // Associations are defined in models/index.js
    }
    
    /**
     * Mark message as read by a user
     * @param {string} userId - UUID of user who read the message
     * @returns {Promise<Message>} Updated message instance
     */
    async markAsRead(userId) {
      if (!this.read_by.includes(userId)) {
        this.read_by = [...this.read_by, userId];
        await this.save();
      }
      return this;
    }
    
    /**
     * Mark message as delivered to a user
     * @param {string} userId - UUID of user who received the message
     * @returns {Promise<Message>} Updated message instance
     */
    async markAsDelivered(userId) {
      if (!this.delivered_to.includes(userId)) {
        this.delivered_to = [...this.delivered_to, userId];
        await this.save();
      }
      return this;
    }
    
    /**
     * Check if message has been read by a user
     * @param {string} userId - UUID of user to check
     * @returns {boolean} True if user has read the message
     */
    isReadBy(userId) {
      return this.read_by.includes(userId);
    }
    
    /**
     * Check if message has been delivered to a user
     * @param {string} userId - UUID of user to check
     * @returns {boolean} True if message was delivered to user
     */
    isDeliveredTo(userId) {
      return this.delivered_to.includes(userId);
    }
  }
  
  Message.init({
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    conversation_id: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'conversations',
        key: 'id'
      }
    },
    sender_id: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'users',
        key: 'id'
      }
    },
    content: {
      type: DataTypes.TEXT,
      allowNull: false,
      validate: {
        notEmpty: {
          msg: 'Message content cannot be empty'
        },
        len: {
          args: [1, 5000],
          msg: 'Message content must be between 1 and 5000 characters'
        }
      }
    },
    message_type: {
      type: DataTypes.ENUM('text', 'image', 'file', 'system'),
      allowNull: false,
      defaultValue: 'text',
      validate: {
        isIn: [['text', 'image', 'file', 'system']]
      }
    },
    metadata: {
      type: DataTypes.JSONB,
      allowNull: true,
      defaultValue: {}
    },
    read_by: {
      type: DataTypes.JSONB,
      allowNull: false,
      defaultValue: [],
      validate: {
        isArray(value) {
          if (!Array.isArray(value)) {
            throw new Error('read_by must be an array');
          }
        }
      }
    },
    delivered_to: {
      type: DataTypes.JSONB,
      allowNull: false,
      defaultValue: [],
      validate: {
        isArray(value) {
          if (!Array.isArray(value)) {
            throw new Error('delivered_to must be an array');
          }
        }
      }
    },
    is_deleted: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: false
    },
    // Virtual field to check if all participants have read the message
    isRead: {
      type: DataTypes.VIRTUAL,
      get() {
        // This would need conversation participant info to be accurate
        // For now, just check if read_by array is not empty
        return this.read_by && this.read_by.length > 0;
      }
    }
  }, {
    sequelize,
    modelName: 'Message',
    tableName: 'messages',
    underscored: true,
    timestamps: true,
    indexes: [
      {
        fields: ['conversation_id', 'created_at']
      },
      {
        fields: ['sender_id']
      },
      {
        fields: ['message_type']
      },
      {
        fields: ['is_deleted']
      }
    ]
  });
  
  return Message;
};
