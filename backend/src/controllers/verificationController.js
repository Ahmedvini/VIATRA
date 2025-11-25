import {
  uploadVerificationDocument,
  getVerificationStatus,
  approveVerification,
  rejectVerification,
  resendVerificationEmail,
  getPendingVerifications
} from '../services/verificationService.js';
import { uploadFileToGCS } from '../utils/fileUpload.js';
import logger from '../config/logger.js';

/**
 * Submit a document for verification
 * POST /api/v1/verification/submit
 */
export const submitDocumentForVerification = async (req, res) => {
  try {
    // First validate the request data
    const { error, value } = validateSubmitDocument(req.body);
    if (error) {
      return res.status(400).json({
        error: 'Validation failed',
        message: error.details[0].message,
        details: error.details
      });
    }

    const userId = req.user.id;
    const { documentType, description } = value;

    // Handle file upload using multer middleware
    uploadSingle('document')(req, res, async (err) => {
      if (err) {
        logger.error('File upload error:', err);
        return res.status(400).json({
          error: 'File upload failed',
          message: err.message
        });
      }

      if (!req.file) {
        return res.status(400).json({
          error: 'File required',
          message: 'Please upload a document file'
        });
      }

      try {
        const result = await submitDocument({
          userId,
          documentType,
          description,
          filePath: req.file.path,
          fileName: req.file.originalname,
          fileSize: req.file.size,
          mimeType: req.file.mimetype,
          publicUrl: req.file.publicUrl
        });

        logger.info('Document submitted for verification', {
          userId,
          documentType,
          documentId: result.id
        });

        res.status(201).json({
          message: 'Document submitted successfully',
          data: {
            id: result.id,
            documentType: result.documentType,
            status: result.status,
            submittedAt: result.submittedAt
          }
        });
      } catch (error) {
        logger.error('Document submission error:', error);
        res.status(500).json({
          error: 'Submission failed',
          message: 'Failed to submit document for verification'
        });
      }
    });
  } catch (error) {
    logger.error('Verification controller error:', error);
    res.status(500).json({
      error: 'Internal server error',
      message: 'An unexpected error occurred'
    });
  }
};

/**
 * Get document verification status
 * GET /api/v1/verification/document/:documentId
 */
export const getDocumentVerificationStatus = async (req, res) => {
  try {
    const { documentId } = req.params;
    const userId = req.user.id;
    const userRole = req.user.role;

    const document = await getDocumentStatus(documentId, userId, userRole);

    if (!document) {
      return res.status(404).json({
        error: 'Document not found',
        message: 'Document not found or access denied'
      });
    }

    res.status(200).json({
      message: 'Document status retrieved successfully',
      data: document
    });
  } catch (error) {
    logger.error('Get document status error:', error);
    res.status(500).json({
      error: 'Retrieval failed',
      message: 'Failed to retrieve document status'
    });
  }
};

/**
 * Get user's overall verification status
 * GET /api/v1/verification/status
 */
export const getUserVerificationStatus = async (req, res) => {
  try {
    const userId = req.user.id;

    const status = await getVerificationStatus(userId);

    res.status(200).json({
      message: 'Verification status retrieved successfully',
      data: status
    });
  } catch (error) {
    logger.error('Get verification status error:', error);
    res.status(500).json({
      error: 'Retrieval failed',
      message: 'Failed to retrieve verification status'
    });
  }
};

/**
 * Update document verification status (Admin only)
 * PATCH /api/v1/verification/document/:documentId/status
 */
export const updateDocumentVerificationStatus = async (req, res) => {
  try {
    const { documentId } = req.params;
    const adminId = req.user.id;

    // Validate request data
    const { error, value } = validateUpdateStatus(req.body);
    if (error) {
      return res.status(400).json({
        error: 'Validation failed',
        message: error.details[0].message,
        details: error.details
      });
    }

    const { status, comments } = value;

    const result = await updateDocumentStatus({
      documentId,
      status,
      comments,
      adminId
    });

    if (!result) {
      return res.status(404).json({
        error: 'Document not found',
        message: 'Document not found or already processed'
      });
    }

    logger.info('Document status updated', {
      documentId,
      status,
      adminId
    });

    res.status(200).json({
      message: 'Document status updated successfully',
      data: result
    });
  } catch (error) {
    logger.error('Update document status error:', error);
    res.status(500).json({
      error: 'Update failed',
      message: 'Failed to update document status'
    });
  }
};

/**
 * Resend verification email
 * POST /api/v1/verification/resend-email
 */
export const resendVerificationEmailHandler = async (req, res) => {
  try {
    const userId = req.user.id;
    const userEmail = req.user.email;

    const result = await resendVerificationEmail(userId, userEmail);

    if (!result.success) {
      return res.status(429).json({
        error: 'Rate limit exceeded',
        message: result.message,
        retryAfter: result.retryAfter
      });
    }

    logger.info('Verification email resent', { userId });

    res.status(200).json({
      message: 'Verification email sent successfully',
      data: {
        sentAt: result.sentAt,
        expiresAt: result.expiresAt
      }
    });
  } catch (error) {
    logger.error('Resend verification email error:', error);
    res.status(500).json({
      error: 'Email send failed',
      message: 'Failed to send verification email'
    });
  }
};

/**
 * Get pending verifications (Admin only)
 * GET /api/v1/verification/pending
 */
export const getPendingVerificationsHandler = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const documentType = req.query.documentType;
    const userId = req.query.userId;

    const result = await getPendingVerifications({
      page,
      limit,
      documentType,
      userId
    });

    res.status(200).json({
      message: 'Pending verifications retrieved successfully',
      data: result.documents,
      pagination: {
        page: result.page,
        limit: result.limit,
        total: result.total,
        pages: result.totalPages
      }
    });
  } catch (error) {
    logger.error('Get pending verifications error:', error);
    res.status(500).json({
      error: 'Retrieval failed',
      message: 'Failed to retrieve pending verifications'
    });
  }
};

/**
 * Bulk update document statuses (Admin only)
 * POST /api/v1/verification/bulk-update
 */
export const bulkUpdateDocumentStatus = async (req, res) => {
  try {
    const adminId = req.user.id;
    const { documentIds, status, comments } = req.body;

    if (!Array.isArray(documentIds) || documentIds.length === 0) {
      return res.status(400).json({
        error: 'Invalid request',
        message: 'documentIds must be a non-empty array'
      });
    }

    if (!['approved', 'rejected', 'pending'].includes(status)) {
      return res.status(400).json({
        error: 'Invalid status',
        message: 'Status must be one of: approved, rejected, pending'
      });
    }

    const result = await bulkUpdateStatus({
      documentIds,
      status,
      comments,
      adminId
    });

    logger.info('Bulk document status update completed', {
      documentCount: documentIds.length,
      status,
      adminId
    });

    res.status(200).json({
      message: 'Bulk update completed successfully',
      data: {
        updated: result.updated,
        failed: result.failed,
        total: documentIds.length
      }
    });
  } catch (error) {
    logger.error('Bulk update document status error:', error);
    res.status(500).json({
      error: 'Bulk update failed',
      message: 'Failed to update document statuses'
    });
  }
};

/**
 * Get verification statistics (Admin only)
 * GET /api/v1/verification/stats
 */
export const getVerificationStats = async (req, res) => {
  try {
    // This could be expanded based on actual requirements
    // For now, returning basic counts from pending verifications
    const pendingResult = await getPendingVerifications({ page: 1, limit: 1 });
    
    res.status(200).json({
      message: 'Verification statistics retrieved successfully',
      data: {
        totalPending: pendingResult.total,
        // Add more statistics as needed
        lastUpdated: new Date().toISOString()
      }
    });
  } catch (error) {
    logger.error('Get verification stats error:', error);
    res.status(500).json({
      error: 'Retrieval failed',
      message: 'Failed to retrieve verification statistics'
    });
  }
};
