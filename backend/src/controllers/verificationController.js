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
 * Multer middleware (uploadSingle) is applied in routes before this handler
 */
export const submitDocumentForVerification = async (req, res) => {
  try {
    // Extract data (validation already done by route middleware)
    const userId = req.user.id;
    const { type, description = '' } = req.body;
    
    // req.file is populated by uploadSingle middleware in routes
    if (!req.file) {
      return res.status(400).json({
        error: 'File required',
        message: 'Please upload a document file'
      });
    }

    // Upload file to GCS
    const gcsResult = await uploadFileToGCS(req.file, type);
    
    // Store verification in database
    const verification = await uploadVerificationDocument(
      userId,
      type,
      gcsResult.url,
      gcsResult.originalName,
      description
    );

    logger.info('Document submitted for verification', {
      userId,
      type,
      verificationId: verification.id
    });

    return res.status(201).json({
      success: true,
      message: 'Document submitted successfully',
      data: {
        id: verification.id,
        type: verification.type,
        status: verification.status,
        url: gcsResult.url
      }
    });
  } catch (error) {
    logger.error('Document submission error:', error);
    return res.status(500).json({
      success: false,
      error: 'Submission failed',
      message: error.message || 'Failed to submit document for verification'
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

    // Get all verifications for user
    const verifications = await getVerificationStatus(userId);

    return res.status(200).json({
      success: true,
      message: 'Verification status retrieved successfully',
      data: {
        verifications
      }
    });
  } catch (error) {
    logger.error('Get verification status error:', error);
    return res.status(500).json({
      success: false,
      error: 'Retrieval failed',
      message: error.message || 'Failed to retrieve verification status'
    });
  }
};

/**
 * Get specific document verification status
 * GET /api/v1/verification/document/:documentId
 */
export const getDocumentVerificationStatus = async (req, res) => {
  try {
    const { documentId } = req.params;
    const userId = req.user.id;
    const userRole = req.user.role;

    // Get all user verifications and find the specific document
    const verifications = await getVerificationStatus(userId);
    const document = verifications.find(v => v.id === documentId);

    // If not found and user is not admin, check if document exists but belongs to someone else
    if (!document) {
      // Admins can view any document, others can only view their own
      if (userRole !== 'admin') {
        return res.status(404).json({
          success: false,
          error: 'Document not found',
          message: 'Document not found or access denied'
        });
      }
      
      // For admin, try to get the document without user filter
      // (This would need a service function to get by ID, but for now return 404)
      return res.status(404).json({
        success: false,
        error: 'Document not found',
        message: 'Document not found'
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Document status retrieved successfully',
      data: document
    });
  } catch (error) {
    logger.error('Get document status error:', error);
    return res.status(500).json({
      success: false,
      error: 'Retrieval failed',
      message: error.message || 'Failed to retrieve document status'
    });
  }
};

/**
 * Update document verification status (Admin only)
 * PATCH /api/v1/verification/document/:documentId/status
 * Validation middleware applied in routes
 */
export const updateDocumentVerificationStatus = async (req, res) => {
  try {
    const { documentId } = req.params;
    const adminId = req.user.id;
    const { status, reason = '', notes = '' } = req.body;

    // Validate status value
    if (!['approved', 'rejected', 'pending'].includes(status)) {
      return res.status(400).json({
        success: false,
        error: 'Invalid status',
        message: 'Status must be one of: approved, rejected, pending'
      });
    }

    let result;

    // Call appropriate service function based on status
    if (status === 'approved') {
      result = await approveVerification(documentId, adminId, notes);
    } else if (status === 'rejected') {
      if (!reason && !notes) {
        return res.status(400).json({
          success: false,
          error: 'Reason required',
          message: 'Reason or notes are required when rejecting a document'
        });
      }
      result = await rejectVerification(documentId, adminId, reason || notes, notes);
    } else {
      // For 'pending' status, we might need to reset - currently not implemented in service
      return res.status(400).json({
        success: false,
        error: 'Status not supported',
        message: 'Resetting to pending status is not currently supported'
      });
    }

    logger.info('Document status updated', {
      documentId,
      status,
      adminId
    });

    return res.status(200).json({
      success: true,
      message: 'Document status updated successfully',
      data: {
        id: result.id,
        type: result.type,
        status: result.status,
        verifiedAt: result.verified_at,
        rejectionReason: result.rejection_reason
      }
    });
  } catch (error) {
    logger.error('Update document status error:', error);
    
    // Handle specific error cases
    if (error.message === 'Verification record not found') {
      return res.status(404).json({
        success: false,
        error: 'Document not found',
        message: error.message
      });
    }
    
    if (error.message.includes('not pending')) {
      return res.status(400).json({
        success: false,
        error: 'Invalid operation',
        message: error.message
      });
    }
    
    return res.status(500).json({
      success: false,
      error: 'Update failed',
      message: error.message || 'Failed to update document status'
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
    const preferredLanguage = req.user.preferredLanguage || 'en';

    // Call service to resend email
    await resendVerificationEmail(userId, preferredLanguage);

    logger.info('Verification email resent', { userId });

    return res.status(200).json({
      success: true,
      message: 'Verification email sent successfully'
    });
  } catch (error) {
    logger.error('Resend verification email error:', error);
    
    // Handle specific errors
    if (error.message === 'Email already verified') {
      return res.status(400).json({
        success: false,
        error: 'Already verified',
        message: error.message
      });
    }
    
    if (error.message.includes('Maximum verification attempts')) {
      return res.status(429).json({
        success: false,
        error: 'Rate limit exceeded',
        message: error.message
      });
    }
    
    return res.status(500).json({
      success: false,
      error: 'Email send failed',
      message: error.message || 'Failed to send verification email'
    });
  }
};

/**
 * Get pending verifications (Admin only)
 * GET /api/v1/verification/pending
 * Query params: page, limit, documentType (filters.type), userId (filters.role)
 */
export const getPendingVerificationsHandler = async (req, res) => {
  try {
    // Parse query parameters with defaults
    const page = parseInt(req.query.page) || 1;
    const limit = Math.min(parseInt(req.query.limit) || 20, 100); // Max 100
    const documentType = req.query.documentType;
    const userId = req.query.userId;
    
    // Build filters object
    const filters = {};
    if (documentType) {
      filters.type = documentType;
    }
    // Note: userId filter would require service modification to filter by user_id
    // For now, filtering by role in the service if needed
    
    // Call service with pagination and filters
    const result = await getPendingVerifications(
      { page, limit },
      filters
    );

    return res.status(200).json({
      success: true,
      message: 'Pending verifications retrieved successfully',
      data: {
        verifications: result.verifications,
        pagination: result.pagination
      }
    });
  } catch (error) {
    logger.error('Get pending verifications error:', error);
    return res.status(500).json({
      success: false,
      error: 'Retrieval failed',
      message: error.message || 'Failed to retrieve pending verifications'
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
    const { documentIds, status, reason = '', notes = '' } = req.body;

    if (!Array.isArray(documentIds) || documentIds.length === 0) {
      return res.status(400).json({
        success: false,
        error: 'Invalid request',
        message: 'documentIds must be a non-empty array'
      });
    }

    if (!['approved', 'rejected'].includes(status)) {
      return res.status(400).json({
        success: false,
        error: 'Invalid status',
        message: 'Status must be one of: approved, rejected'
      });
    }

    const results = {
      updated: 0,
      failed: 0,
      errors: []
    };

    // Process each document
    for (const documentId of documentIds) {
      try {
        if (status === 'approved') {
          await approveVerification(documentId, adminId, notes);
        } else if (status === 'rejected') {
          await rejectVerification(documentId, adminId, reason || notes, notes);
        }
        results.updated++;
      } catch (error) {
        results.failed++;
        results.errors.push({
          documentId,
          error: error.message
        });
        logger.error(`Bulk update failed for document ${documentId}:`, error);
      }
    }

    logger.info('Bulk document status update completed', {
      documentCount: documentIds.length,
      status,
      adminId,
      updated: results.updated,
      failed: results.failed
    });

    return res.status(200).json({
      success: true,
      message: 'Bulk update completed',
      data: {
        updated: results.updated,
        failed: results.failed,
        total: documentIds.length,
        errors: results.errors
      }
    });
  } catch (error) {
    logger.error('Bulk update document status error:', error);
    return res.status(500).json({
      success: false,
      error: 'Bulk update failed',
      message: error.message || 'Failed to update document statuses'
    });
  }
};

/**
 * Get verification statistics (Admin only)
 * GET /api/v1/verification/stats
 */
export const getVerificationStats = async (req, res) => {
  try {
    // Get total pending count
    const pendingResult = await getPendingVerifications(
      { page: 1, limit: 1 },
      {}
    );
    
    return res.status(200).json({
      success: true,
      message: 'Verification statistics retrieved successfully',
      data: {
        totalPending: pendingResult.pagination.totalCount || 0,
        lastUpdated: new Date().toISOString()
      }
    });
  } catch (error) {
    logger.error('Get verification stats error:', error);
    return res.status(500).json({
      success: false,
      error: 'Retrieval failed',
      message: error.message || 'Failed to retrieve verification statistics'
    });
  }
};
