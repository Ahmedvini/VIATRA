import express from 'express';
import {
  requestConsent,
  checkConsent,
  revokeConsent,
  getHealthSummary,
  sendMessage,
  getChatHistory,
  clearHistory,
  getHealthInsights,
} from '../controllers/aiHealthChatbotController.js';
import { authenticate } from '../middleware/auth.js';

const router = express.Router();

// All routes require authentication
router.use(authenticate);

// Consent management
router.post('/consent', requestConsent);
router.get('/consent', checkConsent);
router.delete('/consent', revokeConsent);

// Health data
router.get('/health-summary', getHealthSummary);
router.get('/insights', getHealthInsights);

// Chat functionality
router.post('/chat', sendMessage);
router.get('/history', getChatHistory);
router.delete('/history', clearHistory);

export default router;
