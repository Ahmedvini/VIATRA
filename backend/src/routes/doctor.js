import express from 'express';
import rateLimit from 'express-rate-limit';
import * as doctorController from '../controllers/doctorController.js';
import { authenticate } from '../middleware/auth.js';

const router = express.Router();

/**
 * Rate limiter for doctor search endpoint
 * 30 requests per minute
 */
const searchRateLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 30,
  message: {
    success: false,
    message: 'Too many search requests, please try again later'
  },
  standardHeaders: true,
  legacyHeaders: false
});

/**
 * Rate limiter for doctor detail endpoints
 * 60 requests per minute
 */
const detailRateLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 60,
  message: {
    success: false,
    message: 'Too many requests, please try again later'
  },
  standardHeaders: true,
  legacyHeaders: false
});

/**
 * @route   GET /api/v1/doctors/search
 * @desc    Search doctors with filters
 * @access  Public
 * @query   specialty, subSpecialty, city, state, zipCode, minFee, maxFee, languages, isAcceptingPatients, telehealthEnabled, page, limit, sortBy, sortOrder
 */
router.get('/search', searchRateLimiter, doctorController.searchDoctors);

/**
 * @route   GET /api/v1/doctors/:id
 * @desc    Get doctor by ID
 * @access  Public
 */
router.get('/:id', detailRateLimiter, doctorController.getDoctorById);

/**
 * @route   GET /api/v1/doctors/:id/availability
 * @desc    Get doctor availability
 * @access  Public
 */
router.get('/:id/availability', detailRateLimiter, doctorController.getDoctorAvailability);

export default router;
