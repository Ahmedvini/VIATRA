import * as chatService from '../services/chatService.js';
import logger from '../config/logger.js';

/**
 * Handle user joining a conversation room
 * @param {Socket} socket - Socket.io socket instance
 * @param {string} conversationId - Conversation UUID
 */
export const handleJoinConversation = async (socket, conversationId) => {
  try {
    const userId = socket.data.userId;
    
    // Verify user is a participant in this conversation
    const conversation = await chatService.getConversationById(conversationId, userId);
    
    if (!conversation) {
      socket.emit('error', {
        event: 'join_conversation',
        message: 'Conversation not found or access denied'
      });
      return;
    }
    
    // Join the Socket.io room
    const roomName = `conversation:${conversationId}`;
    socket.join(roomName);
    
    logger.info(`User ${userId} joined conversation ${conversationId}`, {
      socketId: socket.id
    });
    
    // Notify user of successful join
    socket.emit('joined_conversation', {
      conversationId,
      message: 'Successfully joined conversation'
    });
    
    // Notify other participants that user has joined
    socket.to(roomName).emit('user_joined', {
      conversationId,
      userId
    });
  } catch (error) {
    logger.error('Error in handleJoinConversation:', error);
    socket.emit('error', {
      event: 'join_conversation',
      message: error.message || 'Failed to join conversation'
    });
  }
};

/**
 * Handle user leaving a conversation room
 * @param {Socket} socket - Socket.io socket instance
 * @param {string} conversationId - Conversation UUID
 */
export const handleLeaveConversation = async (socket, conversationId) => {
  try {
    const userId = socket.data.userId;
    const roomName = `conversation:${conversationId}`;
    
    // Leave the Socket.io room
    socket.leave(roomName);
    
    logger.info(`User ${userId} left conversation ${conversationId}`, {
      socketId: socket.id
    });
    
    // Notify user of successful leave
    socket.emit('left_conversation', {
      conversationId,
      message: 'Successfully left conversation'
    });
    
    // Notify other participants that user has left
    socket.to(roomName).emit('user_left', {
      conversationId,
      userId
    });
  } catch (error) {
    logger.error('Error in handleLeaveConversation:', error);
    socket.emit('error', {
      event: 'leave_conversation',
      message: error.message || 'Failed to leave conversation'
    });
  }
};

/**
 * Handle typing start event
 * @param {Socket} socket - Socket.io socket instance
 * @param {string} conversationId - Conversation UUID
 */
export const handleTypingStart = async (socket, conversationId) => {
  try {
    const userId = socket.data.userId;
    const roomName = `conversation:${conversationId}`;
    
    // Broadcast typing indicator to other participants in the room
    socket.to(roomName).emit('user_typing', {
      conversationId,
      userId,
      isTyping: true
    });
    
    logger.debug(`User ${userId} started typing in conversation ${conversationId}`);
  } catch (error) {
    logger.error('Error in handleTypingStart:', error);
  }
};

/**
 * Handle typing stop event
 * @param {Socket} socket - Socket.io socket instance
 * @param {string} conversationId - Conversation UUID
 */
export const handleTypingStop = async (socket, conversationId) => {
  try {
    const userId = socket.data.userId;
    const roomName = `conversation:${conversationId}`;
    
    // Broadcast typing stopped indicator to other participants
    socket.to(roomName).emit('user_typing', {
      conversationId,
      userId,
      isTyping: false
    });
    
    logger.debug(`User ${userId} stopped typing in conversation ${conversationId}`);
  } catch (error) {
    logger.error('Error in handleTypingStop:', error);
  }
};

/**
 * Handle message sent event (from REST API)
 * Validates message exists and broadcasts to room
 * @param {Socket} socket - Socket.io socket instance
 * @param {Object} data - Message data with messageId and conversationId
 */
export const handleMessageSent = async (socket, data) => {
  try {
    const { messageId, conversationId } = data;
    
    if (!messageId || !conversationId) {
      socket.emit('error', {
        event: 'message_sent',
        message: 'Invalid message data'
      });
      return;
    }
    
    // Message was already created via REST API and broadcast from controller
    // This handler is for any additional real-time processing if needed
    
    logger.debug(`Message ${messageId} sent confirmation in conversation ${conversationId}`);
  } catch (error) {
    logger.error('Error in handleMessageSent:', error);
    socket.emit('error', {
      event: 'message_sent',
      message: error.message || 'Failed to process message'
    });
  }
};
