import express from 'express';
import { authenticate, authorize } from '../middleware/auth.js';
import {
  getMyHealthProfile,
  createHealthProfile,
  updateHealthProfile,
  addChronicCondition,
  removeChronicCondition,
  addAllergy,
  removeAllergy,
  updateVitals,
} from '../controllers/healthProfileController.js';
import rateLimit from 'express-rate-limit';

const router = express.Router();

// Rate limiting: 10 requests per minute per user
const healthProfileLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 10,
  message: 'Too many requests to health profile API, please try again later',
  standardHeaders: true,
  legacyHeaders: false,
});

// Apply authentication and rate limiting to all routes
router.use(authenticate);
router.use(authorize('patient'));
router.use(healthProfileLimiter);

/**
 * @route   GET /api/v1/health-profiles/me
 * @desc    Get authenticated patient's health profile
 * @access  Private (Patient only)
 */
router.get('/me', getMyHealthProfile);

/**
 * @route   POST /api/v1/health-profiles
 * @desc    Create health profile for authenticated patient
 * @access  Private (Patient only)
 */
router.post('/', createHealthProfile);

/**
 * @route   PATCH /api/v1/health-profiles/me
 * @desc    Update health profile for authenticated patient
 * @access  Private (Patient only)
 */
router.patch('/me', updateHealthProfile);

/**
 * @route   POST /api/v1/health-profiles/me/chronic-conditions
 * @desc    Add chronic condition to health profile
 * @access  Private (Patient only)
 */
router.post('/me/chronic-conditions', addChronicCondition);

/**
 * @route   DELETE /api/v1/health-profiles/me/chronic-conditions/:conditionId
 * @desc    Remove chronic condition from health profile
 * @access  Private (Patient only)
 */
router.delete('/me/chronic-conditions/:conditionId', removeChronicCondition);

/**
 * @route   POST /api/v1/health-profiles/me/allergies
 * @desc    Add allergy to health profile
 * @access  Private (Patient only)
 */
router.post('/me/allergies', addAllergy);

/**
 * @route   DELETE /api/v1/health-profiles/me/allergies/:allergen
 * @desc    Remove allergy from health profile
 * @access  Private (Patient only)
 */
router.delete('/me/allergies/:allergen', removeAllergy);

/**
 * @route   PATCH /api/v1/health-profiles/me/vitals
 * @desc    Update vitals in health profile
 * @access  Private (Patient only)
 */
router.patch('/me/vitals', updateVitals);

export default router;
