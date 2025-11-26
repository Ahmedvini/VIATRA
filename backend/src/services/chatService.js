import { Op } from 'sequelize';
import { Conversation, Message, User } from '../models/index.js';
import redisClient from '../config/redis.js';
import logger from '../config/logger.js';
import { sequelize } from '../config/database.js';

/**
 * Generate Redis cache key for chat data
 */
const generateConversationsCacheKey = (userId) => {
  return `chat:conversations:${userId}`;
};

/**
 * Invalidate chat-related cache
 */
export const invalidateChatCache = async (userId, conversationId) => {
  try {
    const keys = [];
    
    // User's conversation list cache
    if (userId) {
      keys.push(generateConversationsCacheKey(userId));
    }
    
    // Conversation-specific caches
    if (conversationId) {
      keys.push(`chat:conversation:${conversationId}`);
      keys.push(`chat:messages:${conversationId}`);
    }
    
    if (keys.length > 0) {
      await Promise.all(keys.map(key => redisClient.del(key)));
      logger.info(`Invalidated ${keys.length} chat cache keys`);
    }
  } catch (error) {
    logger.error('Error invalidating chat cache:', error);
  }
};

/**
 * Get or create a conversation between participants
 */
export const getOrCreateConversation = async (participantIds) => {
  const transaction = await sequelize.transaction();
  
  try {
    // Sort participant IDs for consistent matching
    const sortedIds = [...participantIds].sort();
    
    // For direct conversations, check if one already exists
    if (sortedIds.length === 2) {
      const existing = await Conversation.findOne({
        where: {
          type: 'direct',
          participant_ids: {
            [Op.contains]: sortedIds
          }
        },
        transaction
      });
      
      if (existing) {
        await transaction.commit();
        return existing;
      }
    }
    
    // Create new conversation
    const conversation = await Conversation.create({
      type: sortedIds.length === 2 ? 'direct' : 'group',
      participant_ids: sortedIds
    }, { transaction });
    
    await transaction.commit();
    
    // Invalidate cache for all participants
    await Promise.all(sortedIds.map(id => invalidateChatCache(id, null)));
    
    logger.info(`Conversation created: ${conversation.id}`);
    return conversation;
  } catch (error) {
    await transaction.rollback();
    logger.error('Error creating conversation:', error);
    throw error;
  }
};

/**
 * Get conversation by ID with participant verification
 */
export const getConversationById = async (conversationId, userId) => {
  try {
    const conversation = await Conversation.findByPk(conversationId, {
      include: [
        {
          model: Message,
          as: 'messages',
          limit: 1,
          order: [['created_at', 'DESC']],
          include: [
            {
              model: User,
              as: 'sender',
              attributes: ['id', 'first_name', 'last_name', 'profile_image']
            }
          ]
        }
      ]
    });
    
    if (!conversation) {
      return null;
    }
    
    // Verify user is a participant
    if (!conversation.isParticipant(userId)) {
      throw new Error('Access denied: User is not a participant in this conversation');
    }
    
    return conversation;
  } catch (error) {
    logger.error('Error fetching conversation:', error);
    throw error;
  }
};

/**
 * Get user's conversations with pagination and caching
 */
export const getUserConversations = async (userId, page = 1, limit = 20) => {
  try {
    // Check cache
    const cacheKey = generateConversationsCacheKey(userId);
    const cachedData = await redisClient.get(cacheKey);
    
    if (cachedData) {
      logger.info('Conversations retrieved from cache');
      return JSON.parse(cachedData);
    }
    
    const offset = (page - 1) * limit;
    
    const { count, rows: conversations } = await Conversation.findAndCountAll({
      where: {
        participant_ids: {
          [Op.contains]: [userId]
        }
      },
      include: [
        {
          model: Message,
          as: 'messages',
          limit: 1,
          order: [['created_at', 'DESC']],
          separate: true,
          include: [
            {
              model: User,
              as: 'sender',
              attributes: ['id', 'first_name', 'last_name', 'profile_image']
            }
          ]
        }
      ],
      order: [['last_message_at', 'DESC NULLS LAST'], ['created_at', 'DESC']],
      limit: parseInt(limit),
      offset: offset,
      distinct: true
    });
    
    // Fetch participant details for each conversation
    const conversationsWithParticipants = await Promise.all(
      conversations.map(async (conv) => {
        const participants = await conv.getParticipants();
        return {
          ...conv.toJSON(),
          participants: participants.map(p => ({
            id: p.id,
            first_name: p.first_name,
            last_name: p.last_name,
            profile_image: p.profile_image,
            role: p.role
          }))
        };
      })
    );
    
    const result = {
      conversations: conversationsWithParticipants,
      pagination: {
        total: count,
        page: parseInt(page),
        limit: parseInt(limit),
        totalPages: Math.ceil(count / limit)
      }
    };
    
    // Cache result for 5 minutes
    await redisClient.setEx(cacheKey, 300, JSON.stringify(result));
    
    return result;
  } catch (error) {
    logger.error('Error fetching user conversations:', error);
    throw error;
  }
};

/**
 * Send a message in a conversation
 */
export const sendMessage = async (conversationId, senderId, content, messageType = 'text', metadata = {}) => {
  const transaction = await sequelize.transaction();
  
  try {
    // Verify conversation exists and user is a participant
    const conversation = await Conversation.findByPk(conversationId, { transaction });
    if (!conversation) {
      throw new Error('Conversation not found');
    }
    
    if (!conversation.isParticipant(senderId)) {
      throw new Error('Access denied: User is not a participant in this conversation');
    }
    
    // Create message
    const message = await Message.create({
      conversation_id: conversationId,
      sender_id: senderId,
      content,
      message_type: messageType,
      metadata,
      delivered_to: [senderId], // Sender automatically has delivery
      read_by: [senderId] // Sender automatically has read
    }, { transaction });
    
    // Update conversation's last message
    await conversation.update({
      last_message_id: message.id,
      last_message_at: message.created_at
    }, { transaction });
    
    await transaction.commit();
    
    // Invalidate caches for all participants
    await Promise.all(
      conversation.participant_ids.map(id => invalidateChatCache(id, conversationId))
    );
    
    // Fetch message with associations
    const messageWithSender = await Message.findByPk(message.id, {
      include: [
        {
          model: User,
          as: 'sender',
          attributes: ['id', 'first_name', 'last_name', 'profile_image', 'role']
        }
      ]
    });
    
    logger.info(`Message sent: ${message.id} in conversation ${conversationId}`);
    return messageWithSender.toJSON();
  } catch (error) {
    await transaction.rollback();
    logger.error('Error sending message:', error);
    throw error;
  }
};

/**
 * Get messages in a conversation with pagination
 */
export const getConversationMessages = async (conversationId, userId, page = 1, limit = 50) => {
  try {
    // Verify user is a participant
    const conversation = await Conversation.findByPk(conversationId);
    if (!conversation) {
      throw new Error('Conversation not found');
    }
    
    if (!conversation.isParticipant(userId)) {
      throw new Error('Access denied: User is not a participant in this conversation');
    }
    
    const offset = (page - 1) * limit;
    
    const { count, rows: messages } = await Message.findAndCountAll({
      where: {
        conversation_id: conversationId,
        is_deleted: false
      },
      include: [
        {
          model: User,
          as: 'sender',
          attributes: ['id', 'first_name', 'last_name', 'profile_image', 'role']
        }
      ],
      order: [['created_at', 'DESC']],
      limit: parseInt(limit),
      offset: offset
    });
    
    return {
      messages: messages.map(m => m.toJSON()),
      pagination: {
        total: count,
        page: parseInt(page),
        limit: parseInt(limit),
        totalPages: Math.ceil(count / limit)
      }
    };
  } catch (error) {
    logger.error('Error fetching conversation messages:', error);
    throw error;
  }
};

/**
 * Mark messages as read by user
 */
export const markMessagesAsRead = async (conversationId, userId, messageIds) => {
  const transaction = await sequelize.transaction();
  
  try {
    // Verify user is a participant
    const conversation = await Conversation.findByPk(conversationId, { transaction });
    if (!conversation || !conversation.isParticipant(userId)) {
      throw new Error('Access denied');
    }
    
    // Update messages
    const messages = await Message.findAll({
      where: {
        id: messageIds,
        conversation_id: conversationId
      },
      transaction
    });
    
    for (const message of messages) {
      await message.markAsRead(userId);
    }
    
    await transaction.commit();
    
    // Invalidate cache
    await invalidateChatCache(userId, conversationId);
    
    logger.info(`${messageIds.length} messages marked as read by user ${userId}`);
    return true;
  } catch (error) {
    await transaction.rollback();
    logger.error('Error marking messages as read:', error);
    throw error;
  }
};

/**
 * Mark messages as delivered to user
 */
export const markMessagesAsDelivered = async (conversationId, userId, messageIds) => {
  const transaction = await sequelize.transaction();
  
  try {
    const messages = await Message.findAll({
      where: {
        id: messageIds,
        conversation_id: conversationId
      },
      transaction
    });
    
    for (const message of messages) {
      await message.markAsDelivered(userId);
    }
    
    await transaction.commit();
    
    logger.info(`${messageIds.length} messages marked as delivered to user ${userId}`);
    return true;
  } catch (error) {
    await transaction.rollback();
    logger.error('Error marking messages as delivered:', error);
    throw error;
  }
};

/**
 * Delete a message (soft delete)
 */
export const deleteMessage = async (messageId, userId) => {
  const transaction = await sequelize.transaction();
  
  try {
    const message = await Message.findByPk(messageId, { transaction });
    
    if (!message) {
      throw new Error('Message not found');
    }
    
    // Only sender can delete their own message
    if (message.sender_id !== userId) {
      throw new Error('Access denied: You can only delete your own messages');
    }
    
    // Soft delete
    await message.update({ is_deleted: true }, { transaction });
    
    await transaction.commit();
    
    // Invalidate cache
    const conversation = await Conversation.findByPk(message.conversation_id);
    if (conversation) {
      await Promise.all(
        conversation.participant_ids.map(id => invalidateChatCache(id, message.conversation_id))
      );
    }
    
    logger.info(`Message deleted: ${messageId}`);
    return true;
  } catch (error) {
    await transaction.rollback();
    logger.error('Error deleting message:', error);
    throw error;
  }
};
