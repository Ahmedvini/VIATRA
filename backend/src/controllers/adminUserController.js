import { User, Doctor, Patient, Verification } from '../models/index.js';
import logger from '../config/logger.js';
import { Op } from 'sequelize';

/**
 * Get pending users (not yet authorized)
 * Users with is_active = false and no rejection reason
 */
export const getPendingUsers = async (req, res) => {
  try {
    const { role, page = 1, limit = 20 } = req.query;
    
    // Build where clause
    const whereClause = {
      is_active: false,
      role: role ? role : { [Op.in]: ['doctor', 'patient'] }
    };
    
    const offset = (page - 1) * limit;
    
    const { count, rows: users } = await User.findAndCountAll({
      where: whereClause,
      include: [
        {
          model: Doctor,
          as: 'doctorProfile',
          required: false
        },
        {
          model: Patient,
          as: 'patientProfile',
          required: false
        },
        {
          model: Verification,
          as: 'verifications',
          required: false
        }
      ],
      limit: parseInt(limit),
      offset: offset,
      order: [['created_at', 'DESC']],
      distinct: true
    });
    
    const formattedUsers = users.map(user => formatUserResponse(user));
    
    return res.status(200).json({
      success: true,
      message: 'Pending users retrieved successfully',
      data: {
        users: formattedUsers,
        pagination: {
          currentPage: parseInt(page),
          totalPages: Math.ceil(count / limit),
          totalCount: count,
          limit: parseInt(limit)
        }
      }
    });
  } catch (error) {
    logger.error('Get pending users error:', error);
    return res.status(500).json({
      success: false,
      error: 'Retrieval failed',
      message: error.message || 'Failed to retrieve pending users'
    });
  }
};

/**
 * Get active users
 */
export const getActiveUsers = async (req, res) => {
  try {
    const { role, page = 1, limit = 20 } = req.query;
    
    const whereClause = {
      is_active: true,
      role: role ? role : { [Op.in]: ['doctor', 'patient'] }
    };
    
    const offset = (page - 1) * limit;
    
    const { count, rows: users } = await User.findAndCountAll({
      where: whereClause,
      include: [
        {
          model: Doctor,
          as: 'doctorProfile',
          required: false
        },
        {
          model: Patient,
          as: 'patientProfile',
          required: false
        },
        {
          model: Verification,
          as: 'verifications',
          required: false
        }
      ],
      limit: parseInt(limit),
      offset: offset,
      order: [['created_at', 'DESC']],
      distinct: true
    });
    
    const formattedUsers = users.map(user => formatUserResponse(user));
    
    return res.status(200).json({
      success: true,
      message: 'Active users retrieved successfully',
      data: {
        users: formattedUsers,
        pagination: {
          currentPage: parseInt(page),
          totalPages: Math.ceil(count / limit),
          totalCount: count,
          limit: parseInt(limit)
        }
      }
    });
  } catch (error) {
    logger.error('Get active users error:', error);
    return res.status(500).json({
      success: false,
      error: 'Retrieval failed',
      message: error.message || 'Failed to retrieve active users'
    });
  }
};

/**
 * Get deactivated users
 * Note: We need to add a deactivated_at field to track this
 * For now, we'll use soft delete functionality
 */
export const getDeactivatedUsers = async (req, res) => {
  try {
    const { role, page = 1, limit = 20 } = req.query;
    
    const whereClause = {
      is_active: false,
      role: role ? role : { [Op.in]: ['doctor', 'patient'] },
      // Assuming deactivated users have email_verified = true (were once active)
      email_verified: true
    };
    
    const offset = (page - 1) * limit;
    
    const { count, rows: users } = await User.findAndCountAll({
      where: whereClause,
      include: [
        {
          model: Doctor,
          as: 'doctorProfile',
          required: false
        },
        {
          model: Patient,
          as: 'patientProfile',
          required: false
        },
        {
          model: Verification,
          as: 'verifications',
          required: false
        }
      ],
      limit: parseInt(limit),
      offset: offset,
      order: [['updated_at', 'DESC']],
      distinct: true
    });
    
    const formattedUsers = users.map(user => formatUserResponse(user));
    
    return res.status(200).json({
      success: true,
      message: 'Deactivated users retrieved successfully',
      data: {
        users: formattedUsers,
        pagination: {
          currentPage: parseInt(page),
          totalPages: Math.ceil(count / limit),
          totalCount: count,
          limit: parseInt(limit)
        }
      }
    });
  } catch (error) {
    logger.error('Get deactivated users error:', error);
    return res.status(500).json({
      success: false,
      error: 'Retrieval failed',
      message: error.message || 'Failed to retrieve deactivated users'
    });
  }
};

/**
 * Get detailed user information
 */
export const getUserDetails = async (req, res) => {
  try {
    const { userId } = req.params;
    
    const user = await User.findByPk(userId, {
      include: [
        {
          model: Doctor,
          as: 'doctorProfile',
          required: false
        },
        {
          model: Patient,
          as: 'patientProfile',
          required: false
        },
        {
          model: Verification,
          as: 'verifications',
          required: false
        }
      ]
    });
    
    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found',
        message: 'User not found'
      });
    }
    
    return res.status(200).json({
      success: true,
      message: 'User details retrieved successfully',
      data: formatUserResponse(user)
    });
  } catch (error) {
    logger.error('Get user details error:', error);
    return res.status(500).json({
      success: false,
      error: 'Retrieval failed',
      message: error.message || 'Failed to retrieve user details'
    });
  }
};

/**
 * Authorize a pending user (approve registration)
 */
export const authorizeUser = async (req, res) => {
  try {
    const { userId } = req.params;
    const { notes = '' } = req.body;
    const adminId = req.user.id;
    
    const user = await User.findByPk(userId);
    
    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found',
        message: 'User not found'
      });
    }
    
    if (user.is_active) {
      return res.status(400).json({
        success: false,
        error: 'User already active',
        message: 'User is already authorized'
      });
    }
    
    // Activate user
    await user.update({
      is_active: true,
      email_verified: true,
      activated_at: new Date(),
      updated_at: new Date()
    });
    
    // Approve all pending verifications
    await Verification.update(
      {
        status: 'verified',
        verified_at: new Date(),
        verified_by: adminId,
        notes: notes || 'Approved by admin during user authorization'
      },
      {
        where: {
          user_id: userId,
          status: 'pending'
        }
      }
    );
    
    logger.info('User authorized by admin', {
      userId: userId,
      adminId: adminId,
      email: user.email
    });
    
    // TODO: Send authorization email to user
    
    return res.status(200).json({
      success: true,
      message: 'User authorized successfully',
      data: {
        userId: user.id,
        email: user.email,
        isActive: user.is_active
      }
    });
  } catch (error) {
    logger.error('Authorize user error:', error);
    return res.status(500).json({
      success: false,
      error: 'Authorization failed',
      message: error.message || 'Failed to authorize user'
    });
  }
};

/**
 * Reject a pending user
 */
export const rejectUser = async (req, res) => {
  try {
    const { userId } = req.params;
    const { reason, notes = '' } = req.body;
    const adminId = req.user.id;
    
    if (!reason) {
      return res.status(400).json({
        success: false,
        error: 'Reason required',
        message: 'Please provide a reason for rejection'
      });
    }
    
    const user = await User.findByPk(userId);
    
    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found',
        message: 'User not found'
      });
    }
    
    // Reject all pending verifications
    await Verification.update(
      {
        status: 'rejected',
        rejection_reason: reason,
        verified_by: adminId,
        notes: notes,
        updated_at: new Date()
      },
      {
        where: {
          user_id: userId,
          status: 'pending'
        }
      }
    );
    
    // Keep user inactive and mark as rejected
    await user.update({
      is_active: false,
      updated_at: new Date()
    });
    
    logger.info('User rejected by admin', {
      userId: userId,
      adminId: adminId,
      reason: reason
    });
    
    // TODO: Send rejection email to user
    
    return res.status(200).json({
      success: true,
      message: 'User rejected successfully',
      data: {
        userId: user.id,
        email: user.email,
        rejectionReason: reason
      }
    });
  } catch (error) {
    logger.error('Reject user error:', error);
    return res.status(500).json({
      success: false,
      error: 'Rejection failed',
      message: error.message || 'Failed to reject user'
    });
  }
};

/**
 * Activate a deactivated user
 */
export const activateUser = async (req, res) => {
  try {
    const { userId } = req.params;
    const { notes = '' } = req.body;
    const adminId = req.user.id;
    
    const user = await User.findByPk(userId);
    
    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found',
        message: 'User not found'
      });
    }
    
    if (user.is_active) {
      return res.status(400).json({
        success: false,
        error: 'User already active',
        message: 'User is already active'
      });
    }
    
    await user.update({
      is_active: true,
      activated_at: new Date(),
      updated_at: new Date()
    });
    
    logger.info('User activated by admin', {
      userId: userId,
      adminId: adminId,
      notes: notes
    });
    
    // TODO: Send activation email to user
    
    return res.status(200).json({
      success: true,
      message: 'User activated successfully',
      data: {
        userId: user.id,
        email: user.email,
        isActive: user.is_active
      }
    });
  } catch (error) {
    logger.error('Activate user error:', error);
    return res.status(500).json({
      success: false,
      error: 'Activation failed',
      message: error.message || 'Failed to activate user'
    });
  }
};

/**
 * Deactivate an active user
 */
export const deactivateUser = async (req, res) => {
  try {
    const { userId } = req.params;
    const { reason, notes = '' } = req.body;
    const adminId = req.user.id;
    
    if (!reason) {
      return res.status(400).json({
        success: false,
        error: 'Reason required',
        message: 'Please provide a reason for deactivation'
      });
    }
    
    const user = await User.findByPk(userId);
    
    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found',
        message: 'User not found'
      });
    }
    
    if (!user.is_active) {
      return res.status(400).json({
        success: false,
        error: 'User already inactive',
        message: 'User is already deactivated'
      });
    }
    
    // Prevent admin from deactivating themselves
    if (user.id === adminId) {
      return res.status(403).json({
        success: false,
        error: 'Cannot deactivate yourself',
        message: 'You cannot deactivate your own account'
      });
    }
    
    await user.update({
      is_active: false,
      updated_at: new Date()
    });
    
    logger.info('User deactivated by admin', {
      userId: userId,
      adminId: adminId,
      reason: reason
    });
    
    // TODO: Send deactivation email to user
    
    return res.status(200).json({
      success: true,
      message: 'User deactivated successfully',
      data: {
        userId: user.id,
        email: user.email,
        isActive: user.is_active,
        reason: reason
      }
    });
  } catch (error) {
    logger.error('Deactivate user error:', error);
    return res.status(500).json({
      success: false,
      error: 'Deactivation failed',
      message: error.message || 'Failed to deactivate user'
    });
  }
};

/**
 * Delete a user permanently
 */
export const deleteUser = async (req, res) => {
  try {
    const { userId } = req.params;
    const { reason, confirmation } = req.body;
    const adminId = req.user.id;
    
    if (!reason) {
      return res.status(400).json({
        success: false,
        error: 'Reason required',
        message: 'Please provide a reason for deletion'
      });
    }
    
    if (!confirmation) {
      return res.status(400).json({
        success: false,
        error: 'Confirmation required',
        message: 'Please confirm deletion by setting confirmation to true'
      });
    }
    
    const user = await User.findByPk(userId);
    
    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found',
        message: 'User not found'
      });
    }
    
    // Prevent admin from deleting themselves
    if (user.id === adminId) {
      return res.status(403).json({
        success: false,
        error: 'Cannot delete yourself',
        message: 'You cannot delete your own account'
      });
    }
    
    // Prevent deleting other admins
    if (user.role === 'admin') {
      return res.status(403).json({
        success: false,
        error: 'Cannot delete admin',
        message: 'You cannot delete another admin account'
      });
    }
    
    const userEmail = user.email;
    const userRole = user.role;
    
    // Delete user (will cascade delete related records based on foreign key constraints)
    await user.destroy();
    
    logger.warn('User deleted by admin', {
      userId: userId,
      adminId: adminId,
      email: userEmail,
      role: userRole,
      reason: reason
    });
    
    // TODO: Send deletion notification email to user
    
    return res.status(200).json({
      success: true,
      message: 'User deleted successfully',
      data: {
        userId: userId,
        email: userEmail,
        deletedAt: new Date()
      }
    });
  } catch (error) {
    logger.error('Delete user error:', error);
    return res.status(500).json({
      success: false,
      error: 'Deletion failed',
      message: error.message || 'Failed to delete user'
    });
  }
};

/**
 * Helper function to format user response
 */
function formatUserResponse(user) {
  const baseData = {
    id: user.id,
    email: user.email,
    firstName: user.first_name,
    lastName: user.last_name,
    phone: user.phone,
    role: user.role,
    isActive: user.is_active,
    emailVerified: user.email_verified,
    createdAt: user.created_at,
    updatedAt: user.updated_at,
    lastLogin: user.last_login
  };
  
  // Add role-specific data
  if (user.role === 'doctor' && user.doctorProfile) {
    baseData.doctorProfile = {
      id: user.doctorProfile.id,
      specialty: user.doctorProfile.specialty,
      licenseNumber: user.doctorProfile.license_number,
      title: user.doctorProfile.title,
      bio: user.doctorProfile.bio,
      education: user.doctorProfile.education,
      experience: user.doctorProfile.experience,
      consultationFee: user.doctorProfile.consultation_fee,
      rating: user.doctorProfile.rating,
      totalReviews: user.doctorProfile.total_reviews,
      availabilityStatus: user.doctorProfile.availability_status
    };
  } else if (user.role === 'patient' && user.patientProfile) {
    baseData.patientProfile = {
      id: user.patientProfile.id,
      dateOfBirth: user.patientProfile.date_of_birth,
      gender: user.patientProfile.gender,
      bloodType: user.patientProfile.blood_type,
      address: user.patientProfile.address,
      city: user.patientProfile.city,
      state: user.patientProfile.state,
      postalCode: user.patientProfile.postal_code,
      country: user.patientProfile.country,
      emergencyContact: user.patientProfile.emergency_contact
    };
  }
  
  // Add verifications (documents)
  if (user.verifications && user.verifications.length > 0) {
    baseData.verifications = user.verifications.map(verification => ({
      id: verification.id,
      type: verification.type,
      status: verification.status,
      documentUrl: verification.document_url,
      documentType: verification.document_type,
      verificationData: verification.verification_data,
      verifiedAt: verification.verified_at,
      rejectionReason: verification.rejection_reason,
      attempts: verification.attempts,
      createdAt: verification.created_at,
      updatedAt: verification.updated_at
    }));
  } else {
    baseData.verifications = [];
  }
  
  return baseData;
}
