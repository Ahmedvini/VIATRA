import express from 'express';
import {
  startSleepSession,
  pauseSleepSession,
  resumeSleepSession,
  endSleepSession,
  recordInterruption,
  getSleepSessions,
  getSleepSessionById,
  getSleepAnalytics,
  deleteSleepSession
} from '../controllers/sleepTrackingController.js';
import { authenticate } from '../middleware/auth.js';

const router = express.Router();

// All routes require authentication
router.use(authenticate);

// POST /api/health/sleep/start - Start a new sleep session
router.post('/start', startSleepSession);

// PUT /api/health/sleep/:sessionId/pause - Pause sleep session (wake up)
router.put('/:sessionId/pause', pauseSleepSession);

// PUT /api/health/sleep/:sessionId/resume - Resume sleep session after wake up
router.put('/:sessionId/resume', resumeSleepSession);

// PUT /api/health/sleep/:sessionId/end - End sleep session
router.put('/:sessionId/end', endSleepSession);

// POST /api/health/sleep/:sessionId/interruption - Record a sleep interruption/wake-up
router.post('/:sessionId/interruption', recordInterruption);

// GET /api/health/sleep - Get all sleep sessions for user
router.get('/', getSleepSessions);

// GET /api/health/sleep/analytics - Get sleep analytics and insights
router.get('/analytics', getSleepAnalytics);

// GET /api/health/sleep/:sessionId - Get single sleep session with interruptions
router.get('/:sessionId', getSleepSessionById);

// DELETE /api/health/sleep/:sessionId - Delete sleep session
router.delete('/:sessionId', deleteSleepSession);

export default router;
