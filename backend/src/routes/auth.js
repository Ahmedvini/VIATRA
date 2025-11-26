import express from 'express';
import rateLimit from 'express-rate-limit';
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

// Rate limiting configurations
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 attempts per window
  message: {
    error: 'Too many login attempts',
    message: 'Too many login attempts from this IP, please try again after 15 minutes'
  },
  standardHeaders: true,
  legacyHeaders: false,
  // Skip successful requests
  skipSuccessfulRequests: true
});

const registerLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 3, // 3 registrations per hour
  message: {
    error: 'Too many registration attempts',
    message: 'Too many registration attempts from this IP, please try again after 1 hour'
  },
  standardHeaders: true,
  legacyHeaders: false
});

const passwordResetLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 3, // 3 password reset requests per hour
  message: {
    error: 'Too many password reset attempts',
    message: 'Too many password reset attempts from this IP, please try again after 1 hour'
  },
  standardHeaders: true,
  legacyHeaders: false
});

const emailVerificationLimiter = rateLimit({
  windowMs: 5 * 60 * 1000, // 5 minutes
  max: 3, // 3 verification attempts per 5 minutes
  message: {
    error: 'Too many verification attempts',
    message: 'Too many verification attempts from this IP, please try again after 5 minutes'
  },
  standardHeaders: true,
  legacyHeaders: false
});

const refreshTokenLimiter = rateLimit({
  windowMs: 5 * 60 * 1000, // 5 minutes
  max: 10, // 10 refresh attempts per 5 minutes
  message: {
    error: 'Too many token refresh attempts',
    message: 'Too many token refresh attempts from this IP, please try again after 5 minutes'
  },
  standardHeaders: true,
  legacyHeaders: false
});

// Authentication routes

/**
 * @route   POST /api/v1/auth/register
 * @desc    Register a new user (Patient, Doctor, or Admin)
 * @access  Public
 * @body    { email, password, firstName, lastName, phone, role, ...roleSpecificFields }
 */
router.post('/register', 
  registerLimiter,
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
  loginLimiter,
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
  refreshTokenLimiter,
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
  emailVerificationLimiter,
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
  passwordResetLimiter,
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
  passwordResetLimiter,
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
