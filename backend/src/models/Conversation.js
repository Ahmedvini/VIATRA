import { Model } from 'sequelize';

export default (sequelize, DataTypes) => {
  class Conversation extends Model {
    static associate(models) {
      // Associations are defined in models/index.js
    }
    
    /**
     * Get User models for all participants in this conversation
     * @returns {Promise<Array>} Array of User instances
     */
    async getParticipants() {
      const { User } = sequelize.models;
      return await User.findAll({
        where: {
          id: this.participant_ids
        }
      });
    }
    
    /**
     * Add a user to the conversation
     * @param {string} userId - UUID of user to add
     * @returns {Promise<Conversation>} Updated conversation instance
     */
    async addParticipant(userId) {
      if (!this.participant_ids.includes(userId)) {
        this.participant_ids = [...this.participant_ids, userId];
        await this.save();
      }
      return this;
    }
    
    /**
     * Remove a user from the conversation
     * @param {string} userId - UUID of user to remove
     * @returns {Promise<Conversation>} Updated conversation instance
     */
    async removeParticipant(userId) {
      this.participant_ids = this.participant_ids.filter(id => id !== userId);
      await this.save();
      return this;
    }
    
    /**
     * Check if a user is a participant in this conversation
     * @param {string} userId - UUID of user to check
     * @returns {boolean} True if user is a participant
     */
    isParticipant(userId) {
      return this.participant_ids.includes(userId);
    }
  }
  
  Conversation.init({
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    type: {
      type: DataTypes.ENUM('direct', 'group'),
      allowNull: false,
      defaultValue: 'direct',
      validate: {
        isIn: [['direct', 'group']]
      }
    },
    participant_ids: {
      type: DataTypes.JSONB,
      allowNull: false,
      defaultValue: [],
      validate: {
        isArray(value) {
          if (!Array.isArray(value)) {
            throw new Error('participant_ids must be an array');
          }
        },
        notEmpty(value) {
          if (value.length === 0) {
            throw new Error('Conversation must have at least one participant');
          }
        }
      }
    },
    last_message_id: {
      type: DataTypes.UUID,
      allowNull: true
    },
    last_message_at: {
      type: DataTypes.DATE,
      allowNull: true
    },
    // Virtual field for participant count
    participantCount: {
      type: DataTypes.VIRTUAL,
      get() {
        return this.participant_ids ? this.participant_ids.length : 0;
      }
    }
  }, {
    sequelize,
    modelName: 'Conversation',
    tableName: 'conversations',
    underscored: true,
    timestamps: true,
    indexes: [
      {
        fields: ['participant_ids'],
        using: 'GIN'
      },
      {
        fields: ['last_message_at']
      },
      {
        fields: ['type']
      }
    ]
  });
  
  return Conversation;
};
