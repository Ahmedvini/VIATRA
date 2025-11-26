import express from 'express';
import * as appointmentController from '../controllers/appointmentController.js';
import { requireAuth, requireRole } from '../middleware/auth.js';
import rateLimit from 'express-rate-limit';

const router = express.Router();

/**
 * Rate limiters for appointment endpoints
 */
const createAppointmentLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 20,
  message: 'Too many appointment creation requests, please try again later'
});

const listAppointmentsLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 30,
  message: 'Too many requests, please try again later'
});

const detailsLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 60,
  message: 'Too many requests, please try again later'
});

const updateAppointmentLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 10,
  message: 'Too many update requests, please try again later'
});

const cancelAppointmentLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 10,
  message: 'Too many cancellation requests, please try again later'
});

const availabilityLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 30,
  message: 'Too many requests, please try again later'
});

/**
 * @route   POST /api/v1/appointments
 * @desc    Create new appointment
 * @access  Private (Patient only)
 */
router.post(
  '/',
  requireAuth,
  requireRole(['patient']),
  createAppointmentLimiter,
  appointmentController.createAppointment
);

/**
 * @route   GET /api/v1/appointments
 * @desc    Get all appointments for authenticated patient
 * @access  Private (Patient only)
 */
router.get(
  '/',
  requireAuth,
  requireRole(['patient']),
  listAppointmentsLimiter,
  appointmentController.getMyAppointments
);

/**
 * @route   GET /api/v1/appointments/doctor/me
 * @desc    Get all appointments for authenticated doctor
 * @access  Private (Doctor only)
 */
router.get(
  '/doctor/me',
  requireAuth,
  requireRole(['doctor']),
  listAppointmentsLimiter,
  appointmentController.getDoctorAppointments
);

/**
 * @route   GET /api/v1/appointments/doctor/dashboard
 * @desc    Get doctor dashboard statistics
 * @access  Private (Doctor only)
 */
router.get(
  '/doctor/dashboard',
  requireAuth,
  requireRole(['doctor']),
  detailsLimiter,
  appointmentController.getDoctorDashboardStats
);

/**
 * @route   POST /api/v1/appointments/:id/accept
 * @desc    Accept and confirm appointment
 * @access  Private (Doctor only)
 */
router.post(
  '/:id/accept',
  requireAuth,
  requireRole(['doctor']),
  updateAppointmentLimiter,
  appointmentController.acceptAppointment
);

/**
 * @route   POST /api/v1/appointments/:id/reschedule
 * @desc    Reschedule appointment to new time
 * @access  Private (Doctor only)
 */
router.post(
  '/:id/reschedule',
  requireAuth,
  requireRole(['doctor']),
  updateAppointmentLimiter,
  appointmentController.rescheduleAppointment
);

/**
 * @route   GET /api/v1/appointments/:id
 * @desc    Get appointment by ID
 * @access  Private (Patient or Doctor)
 */
router.get(
  '/:id',
  requireAuth,
  detailsLimiter,
  appointmentController.getAppointmentById
);

/**
 * @route   PATCH /api/v1/appointments/:id
 * @desc    Update appointment
 * @access  Private (Patient or Doctor)
 */
router.patch(
  '/:id',
  requireAuth,
  updateAppointmentLimiter,
  appointmentController.updateAppointment
);

/**
 * @route   POST /api/v1/appointments/:id/cancel
 * @desc    Cancel appointment
 * @access  Private (Patient or Doctor)
 */
router.post(
  '/:id/cancel',
  requireAuth,
  cancelAppointmentLimiter,
  appointmentController.cancelAppointment
);

export default router;
