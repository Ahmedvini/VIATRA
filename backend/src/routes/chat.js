import express from 'express';
import * as chatController from '../controllers/chatController.js';
import { authenticate } from '../middleware/auth.js';
import rateLimit from 'express-rate-limit';

const router = express.Router();

/**
 * Rate limiters for chat endpoints
 */
const listRateLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 60,
  message: 'Too many requests, please try again later'
});

const createRateLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 30,
  message: 'Too many requests, please try again later'
});

const messageRateLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 30,
  message: 'Too many message requests, please try again later'
});

/**
 * @route   GET /api/v1/chat/conversations
 * @desc    Get user's conversations
 * @access  Private
 */
router.get(
  '/conversations',
  authenticate,
  listRateLimiter,
  chatController.getConversations
);

/**
 * @route   POST /api/v1/chat/conversations
 * @desc    Create new conversation
 * @access  Private
 */
router.post(
  '/conversations',
  authenticate,
  createRateLimiter,
  chatController.createConversation
);

/**
 * @route   GET /api/v1/chat/conversations/:id
 * @desc    Get conversation by ID
 * @access  Private
 */
router.get(
  '/conversations/:id',
  authenticate,
  listRateLimiter,
  chatController.getConversation
);

/**
 * @route   GET /api/v1/chat/conversations/:id/messages
 * @desc    Get messages in a conversation
 * @access  Private
 */
router.get(
  '/conversations/:id/messages',
  authenticate,
  listRateLimiter,
  chatController.getMessages
);

/**
 * @route   POST /api/v1/chat/conversations/:id/messages
 * @desc    Send a message in a conversation
 * @access  Private
 */
router.post(
  '/conversations/:id/messages',
  authenticate,
  messageRateLimiter,
  chatController.sendMessage
);

/**
 * @route   POST /api/v1/chat/conversations/:id/read
 * @desc    Mark messages as read
 * @access  Private
 */
router.post(
  '/conversations/:id/read',
  authenticate,
  messageRateLimiter,
  chatController.markAsRead
);

/**
 * @route   DELETE /api/v1/chat/messages/:id
 * @desc    Delete a message
 * @access  Private
 */
router.delete(
  '/messages/:id',
  authenticate,
  messageRateLimiter,
  chatController.deleteMessage
);

export default router;
