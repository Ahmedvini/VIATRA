import express from 'express';
import {
  submitAssessment,
  getAssessmentHistory,
  getAssessmentById,
  getAssessmentAnalytics,
  deleteAssessment,
  getQuestions
} from '../controllers/psychologicalAssessmentController.js';
import { authenticate } from '../middleware/auth.js';

const router = express.Router();

// All routes require authentication
router.use(authenticate);

// Get PHQ-9 questions (for reference)
router.get('/questions', getQuestions);

// Submit new assessment
router.post('/submit', submitAssessment);

// Get assessment history
router.get('/history', getAssessmentHistory);

// Get analytics and trends
router.get('/analytics', getAssessmentAnalytics);

// Get specific assessment
router.get('/:assessmentId', getAssessmentById);

// Delete assessment
router.delete('/:assessmentId', deleteAssessment);

export default router;
