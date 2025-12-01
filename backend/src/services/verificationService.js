import crypto from 'crypto';
import { sendVerificationEmail } from '../utils/email.js';
import { User, Doctor, Verification } from '../models/index.js';
import logger from '../config/logger.js';
import config from '../config/index.js';

// Create models object for easier access
const models = { User, Doctor, Verification };

/**
 * Generate 6-digit verification code
 * @returns {string} - 6-digit numeric code
 */
const generateVerificationCode = () => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

/**
 * Upload verification document
 * @param {string} userId - User ID
 * @param {string} documentType - Type of document
 * @param {string} documentUrl - URL of uploaded document
 * @param {string} documentName - Original document name
 * @param {string} description - Optional description
 * @returns {Promise<Object>} - Verification record
 */
export const uploadVerificationDocument = async (userId, documentType, documentUrl, documentName, description = '') => {
  try {
    // Find user and doctor profile if applicable
    const user = await models.User.findByPk(userId, {
      include: [{
        model: models.Doctor,
        as: 'doctorProfile',
        required: false
      }]
    });
    
    if (!user) {
      throw new Error('User not found');
    }
    
    // Check if verification already exists and is pending/verified
    const existingVerification = await models.Verification.findOne({
      where: {
        user_id: userId,
        type: documentType,
        status: ['pending', 'verified']
      }
    });
    
    if (existingVerification) {
      if (existingVerification.status === 'verified') {
        throw new Error('Document already verified for this type');
      }
      
      // Update existing pending verification
      await existingVerification.update({
        document_url: documentUrl,
        document_type: documentName,
        verification_data: {
          ...existingVerification.verification_data,
          description: description,
          uploadedAt: new Date().toISOString(),
          originalFileName: documentName
        },
        attempts: existingVerification.attempts + 1,
        status: 'pending'
      });
      
      logger.info('Verification document updated', {
        userId: userId,
        verificationId: existingVerification.id,
        documentType: documentType
      });
      
      return existingVerification;
    }
    
    // Create new verification record
    const verification = await models.Verification.create({
      user_id: userId,
      doctor_id: user.doctorProfile ? user.doctorProfile.id : null,
      type: documentType,
      status: 'pending',
      document_url: documentUrl,
      document_type: documentName,
      verification_data: {
        description: description,
        uploadedAt: new Date().toISOString(),
        originalFileName: documentName
      },
      attempts: 1,
      max_attempts: 5 // Allow multiple document upload attempts
    });
    
    logger.info('Verification document uploaded', {
      userId: userId,
      verificationId: verification.id,
      documentType: documentType
    });
    
    return verification;
  } catch (error) {
    logger.error('Document upload verification failed:', error);
    throw error;
  }
};

/**
 * Get verification status for a user
 * @param {string} userId - User ID
 * @param {string} documentType - Optional filter by document type
 * @returns {Promise<Array>} - Array of verification records
 */
export const getVerificationStatus = async (userId, documentType = null) => {
  try {
    const whereClause = { user_id: userId };
    if (documentType) {
      whereClause.type = documentType;
    }
    
    const verifications = await models.Verification.findAll({
      where: whereClause,
      include: [{
        model: models.User,
        as: 'user',
        attributes: ['id', 'email', 'first_name', 'last_name', 'role']
      }],
      order: [['created_at', 'DESC']]
    });
    
    return verifications.map(verification => ({
      id: verification.id,
      type: verification.type,
      status: verification.status,
      documentUrl: verification.document_url,
      documentType: verification.document_type,
      verificationData: verification.verification_data,
      verifiedAt: verification.verified_at,
      expiresAt: verification.expires_at,
      rejectionReason: verification.rejection_reason,
      attempts: verification.attempts,
      maxAttempts: verification.max_attempts,
      createdAt: verification.created_at,
      updatedAt: verification.updated_at
    }));
  } catch (error) {
    logger.error('Failed to get verification status:', error);
    throw error;
  }
};

/**
 * Approve verification (admin function)
 * @param {string} verificationId - Verification record ID
 * @param {string} adminId - Admin user ID
 * @param {string} notes - Optional approval notes
 * @returns {Promise<Object>} - Updated verification record
 */
export const approveVerification = async (verificationId, adminId, notes = '') => {
  try {
    const verification = await models.Verification.findByPk(verificationId, {
      include: [{
        model: models.User,
        as: 'user',
        attributes: ['id', 'email', 'first_name', 'last_name', 'role']
      }]
    });
    
    if (!verification) {
      throw new Error('Verification record not found');
    }
    
    if (verification.status !== 'pending') {
      throw new Error('Verification is not pending approval');
    }
    
    // Mark verification as verified
    await verification.markAsVerified();
    
    // Update verification with admin details
    await verification.update({
      verified_by: adminId,
      notes: notes,
      verification_data: {
        ...verification.verification_data,
        approvedAt: new Date().toISOString(),
        approvedBy: adminId,
        approvalNotes: notes
      }
    });
    
    // Send approval email
    try {
      // Note: You would implement sendApprovalEmail function in email utils
      logger.info('Verification approved - email notification would be sent here', {
        userId: verification.user.id,
        email: verification.user.email,
        verificationType: verification.type
      });
    } catch (emailError) {
      logger.warn('Failed to send approval email:', emailError);
    }
    
    // If this is a doctor's medical license verification, enable patient acceptance
    if (verification.type === 'medical_license' && verification.user.role === 'doctor') {
      const doctor = await models.Doctor.findOne({
        where: { user_id: verification.user_id }
      });
      
      if (doctor) {
        await doctor.update({
          is_accepting_patients: true
        });
        
        logger.info('Doctor enabled for patient acceptance after license verification', {
          doctorId: doctor.id,
          userId: verification.user.id
        });
      }
    }
    
    logger.info('Verification approved successfully', {
      verificationId: verificationId,
      userId: verification.user.id,
      type: verification.type,
      adminId: adminId
    });
    
    return verification;
  } catch (error) {
    logger.error('Verification approval failed:', error);
    throw error;
  }
};

/**
 * Reject verification (admin function)
 * @param {string} verificationId - Verification record ID
 * @param {string} adminId - Admin user ID
 * @param {string} reason - Rejection reason
 * @param {string} notes - Optional additional notes
 * @returns {Promise<Object>} - Updated verification record
 */
export const rejectVerification = async (verificationId, adminId, reason, notes = '') => {
  try {
    const verification = await models.Verification.findByPk(verificationId, {
      include: [{
        model: models.User,
        as: 'user',
        attributes: ['id', 'email', 'first_name', 'last_name', 'role']
      }]
    });
    
    if (!verification) {
      throw new Error('Verification record not found');
    }
    
    if (verification.status !== 'pending') {
      throw new Error('Verification is not pending approval');
    }
    
    // Mark verification as rejected
    await verification.markAsRejected(reason);
    
    // Update verification with admin details
    await verification.update({
      verified_by: adminId,
      notes: notes,
      verification_data: {
        ...verification.verification_data,
        rejectedAt: new Date().toISOString(),
        rejectedBy: adminId,
        rejectionNotes: notes
      }
    });
    
    // Send rejection email
    try {
      // Note: You would implement sendRejectionEmail function in email utils
      logger.info('Verification rejected - email notification would be sent here', {
        userId: verification.user.id,
        email: verification.user.email,
        verificationType: verification.type,
        reason: reason
      });
    } catch (emailError) {
      logger.warn('Failed to send rejection email:', emailError);
    }
    
    logger.info('Verification rejected', {
      verificationId: verificationId,
      userId: verification.user.id,
      type: verification.type,
      reason: reason,
      adminId: adminId
    });
    
    return verification;
  } catch (error) {
    logger.error('Verification rejection failed:', error);
    throw error;
  }
};

/**
 * Resend verification email
 * @param {string} userId - User ID
 * @param {string} language - Preferred language
 * @returns {Promise<boolean>} - Success status
 */
export const resendVerificationEmail = async (userId, language = 'en') => {
  try {
    // Find user and pending email verification
    const user = await models.User.findByPk(userId);
    if (!user) {
      throw new Error('User not found');
    }
    
    if (user.email_verified) {
      throw new Error('Email already verified');
    }
    
    // Find existing email verification
    let verification = await models.Verification.findOne({
      where: {
        user_id: userId,
        type: 'email',
        status: 'pending'
      }
    });
    
    if (!verification) {
      // Create new verification if none exists
      const verificationCode = generateVerificationCode();
      const expiresAt = new Date(Date.now() + config.email.verificationCodeExpiry);
      
      verification = await models.Verification.create({
        user_id: userId,
        type: 'email',
        status: 'pending',
        verification_code: verificationCode,
        expires_at: expiresAt,
        attempts: 0,
        max_attempts: 3
      });
    } else {
      // Check if max attempts exceeded
      if (verification.attempts >= verification.max_attempts) {
        throw new Error('Maximum verification attempts exceeded. Please contact support.');
      }
      
      // Generate new code and extend expiry
      const verificationCode = generateVerificationCode();
      const expiresAt = new Date(Date.now() + config.email.verificationCodeExpiry);
      
      await verification.update({
        verification_code: verificationCode,
        expires_at: expiresAt,
        attempts: verification.attempts + 1
      });
    }
    
    // Send verification email
    const emailSent = await sendVerificationEmail(
      user.email,
      user.first_name,
      verification.verification_code,
      language
    );
    
    if (!emailSent) {
      throw new Error('Failed to send verification email');
    }
    
    logger.info('Verification email resent', {
      userId: userId,
      email: user.email,
      attempts: verification.attempts
    });
    
    return true;
  } catch (error) {
    logger.error('Failed to resend verification email:', error);
    throw error;
  }
};

/**
 * Get all pending verifications (admin function)
 * @param {Object} pagination - Pagination options
 * @param {Object} filters - Filter options
 * @returns {Promise<Object>} - Paginated verification records
 */
export const getPendingVerifications = async (pagination = {}, filters = {}) => {
  try {
    const { page = 1, limit = 10, sortBy = 'created_at', sortOrder = 'desc' } = pagination;
    const { type, role } = filters;
    
    const whereClause = { status: 'pending' };
    if (type) {
      whereClause.type = type;
    }
    
    const includeClause = [{
      model: models.User,
      as: 'user',
      attributes: ['id', 'email', 'first_name', 'last_name', 'role'],
      where: role ? { role } : {},
      include: [{
        model: models.Doctor,
        as: 'doctorProfile',
        required: false,
        attributes: ['id', 'specialty', 'license_number', 'title']
      }]
    }];
    
    const offset = (page - 1) * limit;
    
    const { count, rows } = await models.Verification.findAndCountAll({
      where: whereClause,
      include: includeClause,
      limit: parseInt(limit),
      offset: offset,
      order: [[sortBy, sortOrder.toUpperCase()]],
      distinct: true
    });
    
    const totalPages = Math.ceil(count / limit);
    
    const verifications = rows.map(verification => ({
      id: verification.id,
      type: verification.type,
      status: verification.status,
      documentUrl: verification.document_url,
      documentType: verification.document_type,
      verificationData: verification.verification_data,
      attempts: verification.attempts,
      maxAttempts: verification.max_attempts,
      createdAt: verification.created_at,
      user: {
        id: verification.user.id,
        email: verification.user.email,
        firstName: verification.user.first_name,
        lastName: verification.user.last_name,
        role: verification.user.role,
        doctorProfile: verification.user.doctorProfile
      }
    }));
    
    return {
      verifications,
      pagination: {
        currentPage: parseInt(page),
        totalPages,
        totalCount: count,
        limit: parseInt(limit),
        hasNext: page < totalPages,
        hasPrev: page > 1
      }
    };
  } catch (error) {
    logger.error('Failed to get pending verifications:', error);
    throw error;
  }
};
