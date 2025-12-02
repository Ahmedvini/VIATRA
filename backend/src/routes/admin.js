import express from 'express';
import rateLimit from 'express-rate-limit';
import {
  getPendingUsers,
  getActiveUsers,
  getDeactivatedUsers,
  activateUser,
  deactivateUser,
  deleteUser,
  authorizeUser,
  rejectUser,
  getUserDetails
} from '../controllers/adminUserController.js';
import { authenticate, authorize } from '../middleware/auth.js';

const router = express.Router();

// Rate limiting for admin actions
const adminActionLimiter = rateLimit({
  windowMs: 5 * 60 * 1000, // 5 minutes
  max: 100, // 100 actions per 5 minutes
  message: {
    error: 'Too many admin actions',
    message: 'Too many admin actions, please slow down'
  },
  standardHeaders: true,
  legacyHeaders: false
});

/**
 * @route   GET /api/v1/admin/users/pending
 * @desc    Get all pending users (doctors or patients) with their documents
 * @access  Private (Admin only)
 * @query   { role?: 'doctor' | 'patient', page?, limit? }
 */
router.get('/users/pending',
  authenticate,
  authorize('admin'),
  getPendingUsers
);

/**
 * @route   GET /api/v1/admin/users/active
 * @desc    Get all active users (doctors or patients)
 * @access  Private (Admin only)
 * @query   { role?: 'doctor' | 'patient', page?, limit? }
 */
router.get('/users/active',
  authenticate,
  authorize('admin'),
  getActiveUsers
);

/**
 * @route   GET /api/v1/admin/users/deactivated
 * @desc    Get all deactivated users (doctors or patients)
 * @access  Private (Admin only)
 * @query   { role?: 'doctor' | 'patient', page?, limit? }
 */
router.get('/users/deactivated',
  authenticate,
  authorize('admin'),
  getDeactivatedUsers
);

/**
 * @route   GET /api/v1/admin/users/:userId
 * @desc    Get detailed user information with all documents
 * @access  Private (Admin only)
 */
router.get('/users/:userId',
  authenticate,
  authorize('admin'),
  getUserDetails
);

/**
 * @route   PATCH /api/v1/admin/users/:userId/authorize
 * @desc    Authorize a pending user (approve registration)
 * @access  Private (Admin only)
 * @body    { notes?: string }
 */
router.patch('/users/:userId/authorize',
  authenticate,
  authorize('admin'),
  adminActionLimiter,
  authorizeUser
);

/**
 * @route   PATCH /api/v1/admin/users/:userId/reject
 * @desc    Reject a pending user
 * @access  Private (Admin only)
 * @body    { reason: string, notes?: string }
 */
router.patch('/users/:userId/reject',
  authenticate,
  authorize('admin'),
  adminActionLimiter,
  rejectUser
);

/**
 * @route   PATCH /api/v1/admin/users/:userId/activate
 * @desc    Activate a deactivated user
 * @access  Private (Admin only)
 * @body    { notes?: string }
 */
router.patch('/users/:userId/activate',
  authenticate,
  authorize('admin'),
  adminActionLimiter,
  activateUser
);

/**
 * @route   PATCH /api/v1/admin/users/:userId/deactivate
 * @desc    Deactivate an active user
 * @access  Private (Admin only)
 * @body    { reason: string, notes?: string }
 */
router.patch('/users/:userId/deactivate',
  authenticate,
  authorize('admin'),
  adminActionLimiter,
  deactivateUser
);

/**
 * @route   DELETE /api/v1/admin/users/:userId
 * @desc    Delete a user permanently
 * @access  Private (Admin only)
 * @body    { reason: string, confirmation: true }
 */
router.delete('/users/:userId',
  authenticate,
  authorize('admin'),
  adminActionLimiter,
  deleteUser
);

export default router;
