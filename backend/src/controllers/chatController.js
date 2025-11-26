import Joi from 'joi';
import * as chatService from '../services/chatService.js';
import logger from '../config/logger.js';

/**
 * Joi validation schemas
 */
const createConversationSchema = Joi.object({
  participantIds: Joi.array().items(Joi.string().uuid()).min(2).required()
});

const sendMessageSchema = Joi.object({
  content: Joi.string().min(1).max(5000).required(),
  messageType: Joi.string().valid('text', 'image', 'file', 'system').default('text'),
  metadata: Joi.object().optional()
});

const markAsReadSchema = Joi.object({
  messageIds: Joi.array().items(Joi.string().uuid()).min(1).required()
});

const paginationSchema = Joi.object({
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(100).default(20)
});

/**
 * Get user's conversations
 */
export const getConversations = async (req, res) => {
  try {
    const { error, value } = paginationSchema.validate(req.query);
    if (error) {
      return res.status(400).json({
        success: false,
        message: 'Invalid query parameters',
        errors: error.details.map(detail => detail.message)
      });
    }
    
    const userId = req.user.id;
    const result = await chatService.getUserConversations(userId, value.page, value.limit);
    
    return res.status(200).json({
      success: true,
      message: 'Conversations retrieved successfully',
      data: result
    });
  } catch (error) {
    logger.error('Error in getConversations controller:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to retrieve conversations',
      error: error.message
    });
  }
};

/**
 * Get single conversation by ID
 */
export const getConversation = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;
    
    const conversation = await chatService.getConversationById(id, userId);
    
    if (!conversation) {
      return res.status(404).json({
        success: false,
        message: 'Conversation not found'
      });
    }
    
    return res.status(200).json({
      success: true,
      message: 'Conversation retrieved successfully',
      data: conversation
    });
  } catch (error) {
    logger.error('Error in getConversation controller:', error);
    
    if (error.message.includes('Access denied')) {
      return res.status(403).json({
        success: false,
        message: error.message
      });
    }
    
    return res.status(500).json({
      success: false,
      message: 'Failed to retrieve conversation',
      error: error.message
    });
  }
};

/**
 * Create new conversation
 */
export const createConversation = async (req, res) => {
  try {
    const { error, value } = createConversationSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        success: false,
        message: 'Invalid conversation data',
        errors: error.details.map(detail => detail.message)
      });
    }
    
    const userId = req.user.id;
    
    // Ensure current user is included in participants
    const participantIds = [...new Set([userId, ...value.participantIds])];
    
    const conversation = await chatService.getOrCreateConversation(participantIds);
    
    return res.status(201).json({
      success: true,
      message: 'Conversation created successfully',
      data: conversation
    });
  } catch (error) {
    logger.error('Error in createConversation controller:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to create conversation',
      error: error.message
    });
  }
};

/**
 * Get messages in a conversation
 */
export const getMessages = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;
    
    const { error, value } = paginationSchema.validate(req.query);
    if (error) {
      return res.status(400).json({
        success: false,
        message: 'Invalid query parameters',
        errors: error.details.map(detail => detail.message)
      });
    }
    
    const result = await chatService.getConversationMessages(id, userId, value.page, value.limit);
    
    return res.status(200).json({
      success: true,
      message: 'Messages retrieved successfully',
      data: result
    });
  } catch (error) {
    logger.error('Error in getMessages controller:', error);
    
    if (error.message.includes('Access denied') || error.message.includes('not found')) {
      return res.status(error.message.includes('not found') ? 404 : 403).json({
        success: false,
        message: error.message
      });
    }
    
    return res.status(500).json({
      success: false,
      message: 'Failed to retrieve messages',
      error: error.message
    });
  }
};

/**
 * Send a message in a conversation
 */
export const sendMessage = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;
    
    const { error, value } = sendMessageSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        success: false,
        message: 'Invalid message data',
        errors: error.details.map(detail => detail.message)
      });
    }
    
    const message = await chatService.sendMessage(
      id,
      userId,
      value.content,
      value.messageType,
      value.metadata
    );
    
    // Emit Socket.io event (handled by socket server)
    const io = req.app.get('io');
    if (io) {
      io.to(`conversation:${id}`).emit('new_message', message);
    }
    
    return res.status(201).json({
      success: true,
      message: 'Message sent successfully',
      data: message
    });
  } catch (error) {
    logger.error('Error in sendMessage controller:', error);
    
    if (error.message.includes('Access denied') || error.message.includes('not found')) {
      return res.status(error.message.includes('not found') ? 404 : 403).json({
        success: false,
        message: error.message
      });
    }
    
    return res.status(500).json({
      success: false,
      message: 'Failed to send message',
      error: error.message
    });
  }
};

/**
 * Mark messages as read
 */
export const markAsRead = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;
    
    const { error, value } = markAsReadSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        success: false,
        message: 'Invalid request data',
        errors: error.details.map(detail => detail.message)
      });
    }
    
    await chatService.markMessagesAsRead(id, userId, value.messageIds);
    
    // Emit Socket.io events
    const io = req.app.get('io');
    if (io) {
      // Emit to conversation room
      io.to(`conversation:${id}`).emit('messages_read', {
        conversationId: id,
        messageIds: value.messageIds,
        userId: userId
      });
      
      // Also emit individual message_read events for each message
      value.messageIds.forEach(messageId => {
        io.to(`conversation:${id}`).emit('message_read', {
          messageId: messageId,
          userId: userId
        });
      });
    }
    
    return res.status(200).json({
      success: true,
      message: 'Messages marked as read'
    });
  } catch (error) {
    logger.error('Error in markAsRead controller:', error);
    
    if (error.message.includes('Access denied')) {
      return res.status(403).json({
        success: false,
        message: error.message
      });
    }
    
    return res.status(500).json({
      success: false,
      message: 'Failed to mark messages as read',
      error: error.message
    });
  }
};

/**
 * Delete a message
 */
export const deleteMessage = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;
    
    await chatService.deleteMessage(id, userId);
    
    return res.status(200).json({
      success: true,
      message: 'Message deleted successfully'
    });
  } catch (error) {
    logger.error('Error in deleteMessage controller:', error);
    
    if (error.message.includes('Access denied') || error.message.includes('not found')) {
      return res.status(error.message.includes('not found') ? 404 : 403).json({
        success: false,
        message: error.message
      });
    }
    
    return res.status(500).json({
      success: false,
      message: 'Failed to delete message',
      error: error.message
    });
  }
};
