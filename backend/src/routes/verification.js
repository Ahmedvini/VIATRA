import express from 'express';
import rateLimit from 'express-rate-limit';
import {
  submitDocumentForVerification,
  getDocumentVerificationStatus,
  getUserVerificationStatus,
  updateDocumentVerificationStatus,
  resendVerificationEmailHandler,
  getPendingVerificationsHandler,
  bulkUpdateDocumentStatus,
  getVerificationStats
} from '../controllers/verificationController.js';
import { authenticate, authorize } from '../middleware/auth.js';
import { uploadSingle } from '../utils/fileUpload.js';
import { validate, documentUploadSchema, verificationActionSchema, paginationSchema } from '../utils/validators.js';

const router = express.Router();

// Rate limiting configurations
const documentUploadLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 10, // 10 uploads per hour
  message: {
    error: 'Too many upload attempts',
    message: 'Too many document uploads from this IP, please try again after 1 hour'
  },
  standardHeaders: true,
  legacyHeaders: false
});

const resendEmailLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 2, // 2 resend attempts per 15 minutes
  message: {
    error: 'Too many resend attempts',
    message: 'Too many email resend attempts, please try again after 15 minutes'
  },
  standardHeaders: true,
  legacyHeaders: false
});

const adminActionLimiter = rateLimit({
  windowMs: 5 * 60 * 1000, // 5 minutes
  max: 50, // 50 admin actions per 5 minutes
  message: {
    error: 'Too many admin actions',
    message: 'Too many admin actions, please slow down'
  },
  standardHeaders: true,
  legacyHeaders: false
});

// Document verification routes

/**
 * @route   POST /api/v1/verification/submit
 * @desc    Submit a document for verification
 * @access  Private (Doctor, Hospital, Pharmacy, Admin)
 * @headers Authorization: Bearer <token>
 * @body    Multipart form with file and { type, description }
 */
router.post('/submit',
  authenticate,
  authorize('doctor', 'hospital', 'pharmacy', 'patient', 'admin'),
  documentUploadLimiter,
  uploadSingle('document'),
  validate(documentUploadSchema),
  submitDocumentForVerification
);

/**
 * @route   GET /api/v1/verification/document/:documentId
 * @desc    Get specific document verification status
 * @access  Private (Owner or Admin)
 * @headers Authorization: Bearer <token>
 */
router.get('/document/:documentId',
  authenticate,
  getDocumentVerificationStatus
);

/**
 * @route   GET /api/v1/verification/status
 * @desc    Get user's overall verification status
 * @access  Private
 * @headers Authorization: Bearer <token>
 */
router.get('/status',
  authenticate,
  getUserVerificationStatus
);

/**
 * @route   PATCH /api/v1/verification/document/:documentId/status
 * @desc    Update document verification status (Admin only)
 * @access  Private (Admin only)
 * @headers Authorization: Bearer <token>
 * @body    { status: 'approved' | 'rejected', reason?, notes? }
 */
router.patch('/document/:documentId/status',
  authenticate,
  authorize('admin'),
  adminActionLimiter,
  validate(verificationActionSchema),
  updateDocumentVerificationStatus
);

/**
 * @route   POST /api/v1/verification/resend-email
 * @desc    Resend email verification code
 * @access  Private
 * @headers Authorization: Bearer <token>
 */
router.post('/resend-email',
  authenticate,
  resendEmailLimiter,
  resendVerificationEmailHandler
);

/**
 * @route   GET /api/v1/verification/pending
 * @desc    Get all pending verifications with pagination (Admin only)
 * @access  Private (Admin only)
 * @headers Authorization: Bearer <token>
 * @query   { page?, limit?, documentType?, userId? }
 */
router.get('/pending',
  authenticate,
  authorize('admin'),
  validate(paginationSchema, 'query'),
  getPendingVerificationsHandler
);

/**
 * @route   POST /api/v1/verification/bulk-update
 * @desc    Bulk update document verification statuses (Admin only)
 * @access  Private (Admin only)
 * @headers Authorization: Bearer <token>
 * @body    { documentIds: string[], status: string, comments?: string }
 */
router.post('/bulk-update',
  authenticate,
  authorize('admin'),
  adminActionLimiter,
  bulkUpdateDocumentStatus
);

/**
 * @route   GET /api/v1/verification/stats
 * @desc    Get verification statistics (Admin only)
 * @access  Private (Admin only)
 * @headers Authorization: Bearer <token>
 */
router.get('/stats',
  authenticate,
  authorize('admin'),
  getVerificationStats
);

// Legacy routes for backward compatibility

/**
 * @route   POST /api/v1/verification/upload-document
 * @desc    Legacy route for document upload (redirects to /submit)
 * @access  Private (Doctor, Admin)
 * @headers Authorization: Bearer <token>
 * @deprecated Use /submit instead
 */
router.post('/upload-document',
  authenticate,
  authorize('doctor', 'hospital', 'pharmacy', 'admin'),
  documentUploadLimiter,
  (req, res, next) => {
    // Redirect to the new submit endpoint
    req.url = '/submit';
    next();
  },
  submitDocumentForVerification
);

/**
 * @route   GET /api/v1/verification/my-verifications
 * @desc    Legacy route for getting user verifications (redirects to /status)
 * @access  Private
 * @headers Authorization: Bearer <token>
 * @deprecated Use /status instead
 */
router.get('/my-verifications',
  authenticate,
  (req, res, next) => {
    // Redirect to the new status endpoint
    req.url = '/status';
    next();
  },
  getUserVerificationStatus
);

/**
 * @route   POST /api/v1/verification/approve/:verificationId
 * @desc    Legacy route for approving verification
 * @access  Private (Admin only)
 * @headers Authorization: Bearer <token>
 * @deprecated Use PATCH /document/:documentId/status instead
 */
router.post('/approve/:verificationId',
  authenticate,
  authorize('admin'),
  adminActionLimiter,
  (req, res, next) => {
    // Transform the request for the new endpoint
    req.params.documentId = req.params.verificationId;
    req.body = { status: 'approved', comments: req.body.comments || 'Approved via legacy endpoint' };
    next();
  },
  updateDocumentVerificationStatus
);

/**
 * @route   POST /api/v1/verification/reject/:verificationId
 * @desc    Legacy route for rejecting verification
 * @access  Private (Admin only)
 * @headers Authorization: Bearer <token>
 * @deprecated Use PATCH /document/:documentId/status instead
 */
router.post('/reject/:verificationId',
  authenticate,
  authorize('admin'),
  adminActionLimiter,
  (req, res, next) => {
    // Transform the request for the new endpoint
    req.params.documentId = req.params.verificationId;
    req.body = { 
      status: 'rejected', 
      comments: req.body.reason || req.body.comments || 'Rejected via legacy endpoint'
    };
    next();
  },
  updateDocumentVerificationStatus
);

export default router;
