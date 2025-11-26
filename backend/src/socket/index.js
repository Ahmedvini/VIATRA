import { Server } from 'socket.io';
import { verifyToken } from '../utils/jwt.js';
import * as presenceService from '../services/presenceService.js';
import * as chatHandlers from './chatHandlers.js';
import logger from '../config/logger.js';
import config from '../config/index.js';

let io = null;

/**
 * Initialize Socket.io server
 * @param {http.Server} httpServer - HTTP server instance
 * @returns {Server} Socket.io server instance
 */
export const initializeSocketServer = (httpServer) => {
  io = new Server(httpServer, {
    cors: {
      origin: config.corsOrigin || '*',
      methods: ['GET', 'POST'],
      credentials: true
    },
    transports: ['websocket', 'polling']
  });
  
  // JWT authentication middleware
  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth.token;
      
      if (!token) {
        return next(new Error('Authentication token required'));
      }
      
      // Verify JWT token
      const decoded = verifyToken(token);
      
      if (!decoded || !decoded.userId) {
        return next(new Error('Invalid authentication token'));
      }
      
      // Attach user data to socket
      socket.data.userId = decoded.userId;
      socket.data.userRole = decoded.role;
      socket.data.userEmail = decoded.email;
      
      logger.debug(`Socket authenticated for user ${decoded.userId}`);
      next();
    } catch (error) {
      logger.error('Socket authentication error:', error);
      next(new Error('Authentication failed'));
    }
  });
  
  // Connection event
  io.on('connection', async (socket) => {
    const userId = socket.data.userId;
    
    logger.info(`User ${userId} connected via WebSocket`, {
      socketId: socket.id,
      role: socket.data.userRole
    });
    
    // Set user as online
    await presenceService.setUserOnline(userId, socket.id);
    
    // Broadcast user online status to relevant conversations
    socket.broadcast.emit('user_online', { userId });
    
    // Handle joining a conversation room
    socket.on('join_conversation', async (data) => {
      await chatHandlers.handleJoinConversation(socket, data.conversationId);
    });
    
    // Handle leaving a conversation room
    socket.on('leave_conversation', async (data) => {
      await chatHandlers.handleLeaveConversation(socket, data.conversationId);
    });
    
    // Handle typing indicators
    socket.on('typing_start', async (data) => {
      await chatHandlers.handleTypingStart(socket, data.conversationId);
    });
    
    socket.on('typing_stop', async (data) => {
      await chatHandlers.handleTypingStop(socket, data.conversationId);
    });
    
    // Handle message sent confirmation (from REST API)
    socket.on('message_sent', async (data) => {
      await chatHandlers.handleMessageSent(socket, data);
    });
    
    // Periodically renew presence
    const presenceInterval = setInterval(async () => {
      await presenceService.renewUserPresence(userId);
    }, 60000); // Every minute
    
    // Disconnection event
    socket.on('disconnect', async (reason) => {
      logger.info(`User ${userId} disconnected`, {
        socketId: socket.id,
        reason
      });
      
      clearInterval(presenceInterval);
      
      // Set user as offline
      await presenceService.setUserOffline(userId);
      
      // Broadcast user offline status
      socket.broadcast.emit('user_offline', { userId });
    });
    
    // Error handling
    socket.on('error', (error) => {
      logger.error(`Socket error for user ${userId}:`, error);
    });
  });
  
  logger.info('Socket.io server initialized successfully');
  return io;
};

/**
 * Get Socket.io server instance
 * @returns {Server|null}
 */
export const getIO = () => {
  if (!io) {
    throw new Error('Socket.io server not initialized');
  }
  return io;
};

/**
 * Emit event to specific user's socket
 * @param {string} userId - User UUID
 * @param {string} event - Event name
 * @param {*} data - Event data
 */
export const emitToUser = async (userId, event, data) => {
  try {
    const socketId = await presenceService.getUserSocketId(userId);
    if (socketId && io) {
      io.to(socketId).emit(event, data);
      logger.debug(`Emitted ${event} to user ${userId}`);
    }
  } catch (error) {
    logger.error(`Error emitting to user ${userId}:`, error);
  }
};

/**
 * Emit event to conversation room
 * @param {string} conversationId - Conversation UUID
 * @param {string} event - Event name
 * @param {*} data - Event data
 */
export const emitToConversation = (conversationId, event, data) => {
  try {
    if (io) {
      io.to(`conversation:${conversationId}`).emit(event, data);
      logger.debug(`Emitted ${event} to conversation ${conversationId}`);
    }
  } catch (error) {
    logger.error(`Error emitting to conversation ${conversationId}:`, error);
  }
};

export default { initializeSocketServer, getIO, emitToUser, emitToConversation };
