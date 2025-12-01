import express from 'express';
import {
  register,
  login,
  logout,
  refreshToken,
  verifyEmailHandler,
  requestPasswordResetHandler,
  resetPasswordHandler,
  getCurrentUser,
  updateFcmToken
} from '../controllers/authController.js';
import {
  registerSchema,
  loginSchema,
  emailVerificationSchema,
  passwordResetRequestSchema,
  passwordResetSchema,
  refreshTokenSchema,
  validate
} from '../utils/validators.js';
import { authenticate } from '../middleware/auth.js';

const router = express.Router();

// Authentication routes

/**
 * @route   POST /api/v1/auth/register
 * @desc    Register a new user (Patient, Doctor, or Admin)
 * @access  Public
 * @body    { email, password, firstName, lastName, phone, role, ...roleSpecificFields }
 */
router.post('/register', 
  // registerLimiter, // TEMPORARILY DISABLED FOR TESTING
  validate(registerSchema),
  register
);

/**
 * @route   POST /api/v1/auth/login
 * @desc    Login user and return JWT tokens
 * @access  Public
 * @body    { email, password, remember? }
 */
router.post('/login',
  // loginLimiter, // TEMPORARILY DISABLED FOR TESTING
  validate(loginSchema),
  login
);

/**
 * @route   POST /api/v1/auth/logout
 * @desc    Logout user and invalidate session
 * @access  Private
 * @headers Authorization: Bearer <token>
 */
router.post('/logout',
  authenticate,
  logout
);

/**
 * @route   POST /api/v1/auth/refresh-token
 * @desc    Refresh access token using refresh token
 * @access  Public
 * @body    { refreshToken }
 */
router.post('/refresh-token',
  validate(refreshTokenSchema),
  refreshToken
);

/**
 * @route   POST /api/v1/auth/verify-email
 * @desc    Verify user email with verification code
 * @access  Public
 * @body    { email, code }
 */
router.post('/verify-email',
  validate(emailVerificationSchema),
  verifyEmailHandler
);

/**
 * @route   POST /api/v1/auth/request-password-reset
 * @desc    Request password reset email
 * @access  Public
 * @body    { email }
 */
router.post('/request-password-reset',
  validate(passwordResetRequestSchema),
  requestPasswordResetHandler
);

/**
 * @route   POST /api/v1/auth/reset-password
 * @desc    Reset password with reset token
 * @access  Public
 * @body    { token, newPassword }
 */
router.post('/reset-password',
  validate(passwordResetSchema),
  resetPasswordHandler
);

/**
 * @route   GET /api/v1/auth/me
 * @desc    Get current authenticated user profile
 * @access  Private
 * @headers Authorization: Bearer <token>
 */
router.get('/me',
  authenticate,
  getCurrentUser
);

/**
 * @route   GET /api/v1/auth/validate-token
 * @desc    Validate current token and return user info
 * @access  Private
 * @headers Authorization: Bearer <token>
 */
router.get('/validate-token',
  authenticate,
  (req, res) => {
    // If we reach here, the token is valid (authenticate middleware passed)
    res.status(200).json({
      message: 'Token is valid',
      data: {
        valid: true,
        user: {
          id: req.user.id,
          email: req.user.email,
          role: req.user.role,
          emailVerified: req.user.emailVerified
        },
        tokenInfo: {
          type: 'Bearer',
          expiresAt: req.user.sessionData.expiresAt || null
        }
      }
    });
  }
);

/**
 * @route   POST /api/v1/auth/fcm-token
 * @desc    Register or update user's FCM token for push notifications
 * @access  Private
 * @headers Authorization: Bearer <token>
 * @body    { token }
 */
router.post('/fcm-token',
  authenticate,
  rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 10,
    message: {
      error: 'Too many requests',
      message: 'Too many FCM token update attempts'
    }
  }),
  updateFcmToken
);

export default router;
