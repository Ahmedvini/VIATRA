import { registerUser, loginUser, verifyEmail, requestPasswordReset, resetPassword, refreshAccessToken } from '../services/authService.js';
import { deleteSession } from '../services/sessionService.js';
import logger from '../config/logger.js';
import { User, Doctor, Patient } from '../models/index.js';

/**
 * Register a new user
 */
export const register = async (req, res) => {
  try {
    const userData = req.body;
    
    // For doctor registration, ensure required fields are present
    if (userData.role === 'doctor') {
      const requiredFields = ['licenseNumber', 'specialty', 'title'];
      for (const field of requiredFields) {
        if (!userData[field]) {
          return res.status(400).json({
            error: 'Missing required fields',
            message: `${field} is required for doctor registration`
          });
        }
      }
    }
    
    const result = await registerUser(userData);
    
    logger.info('User registration successful', {
      userId: result.user.id,
      email: result.user.email,
      role: result.user.role,
      ip: req.ip
    });
    
    res.status(201).json({
      message: 'User registered successfully',
      user: result.user,
      profile: result.profile,
      tokens: result.tokens,
      emailSent: result.emailSent
    });
  } catch (error) {
    logger.error('Registration failed:', error, {
      email: req.body?.email,
      role: req.body?.role,
      ip: req.ip
    });
    
    if (error.message.includes('already exists')) {
      return res.status(409).json({
        error: 'Registration failed',
        message: error.message
      });
    }
    
    if (error.message.includes('validation') || error.message.includes('required')) {
      return res.status(400).json({
        error: 'Validation error',
        message: error.message
      });
    }
    
    res.status(500).json({
      error: 'Registration failed',
      message: 'An error occurred during registration. Please try again.'
    });
  }
};

/**
 * User login
 */
export const login = async (req, res) => {
  try {
    const { email, password, rememberMe } = req.body;
    
    const result = await loginUser(email, password, rememberMe);
    
    logger.info('User login successful', {
      userId: result.user.id,
      email: result.user.email,
      role: result.user.role,
      rememberMe: rememberMe,
      ip: req.ip
    });
    
    res.status(200).json({
      message: 'Login successful',
      user: result.user,
      profile: result.profile,
      tokens: result.tokens
    });
  } catch (error) {
    logger.error('Login failed:', error, {
      email: req.body?.email,
      ip: req.ip
    });
    
    if (error.message.includes('Invalid email or password')) {
      return res.status(401).json({
        error: 'Authentication failed',
        message: 'Invalid email or password'
      });
    }
    
    if (error.message.includes('deactivated')) {
      return res.status(401).json({
        error: 'Account deactivated',
        message: error.message
      });
    }
    
    res.status(500).json({
      error: 'Login failed',
      message: 'An error occurred during login. Please try again.'
    });
  }
};

/**
 * User logout
 */
export const logout = async (req, res) => {
  try {
    const token = req.user?.sessionToken;
    
    if (token) {
      await deleteSession(token);
    }
    
    logger.info('User logout successful', {
      userId: req.user?.id,
      ip: req.ip
    });
    
    res.status(200).json({
      message: 'Logout successful'
    });
  } catch (error) {
    logger.error('Logout failed:', error, {
      userId: req.user?.id,
      ip: req.ip
    });
    
    // Even if logout fails, we should return success to avoid user confusion
    res.status(200).json({
      message: 'Logout completed'
    });
  }
};

/**
 * Refresh access token
 */
export const refreshToken = async (req, res) => {
  try {
    const { refreshToken } = req.body;
    
    const newAccessToken = await refreshAccessToken(refreshToken);
    
    logger.info('Token refresh successful', {
      ip: req.ip
    });
    
    res.status(200).json({
      message: 'Token refreshed successfully',
      accessToken: newAccessToken
    });
  } catch (error) {
    logger.error('Token refresh failed:', error, {
      ip: req.ip
    });
    
    if (error.message.includes('expired') || error.message.includes('invalid')) {
      return res.status(401).json({
        error: 'Invalid token',
        message: 'Please log in again'
      });
    }
    
    if (error.message.includes('Session not found')) {
      return res.status(401).json({
        error: 'Session expired',
        message: 'Please log in again'
      });
    }
    
    res.status(500).json({
      error: 'Token refresh failed',
      message: 'An error occurred while refreshing token. Please log in again.'
    });
  }
};

/**
 * Verify email with code
 */
export const verifyEmailHandler = async (req, res) => {
  try {
    const { code } = req.body;
    
    const success = await verifyEmail(code);
    
    if (success) {
      logger.info('Email verification successful', {
        ip: req.ip
      });
      
      res.status(200).json({
        message: 'Email verified successfully'
      });
    } else {
      res.status(400).json({
        error: 'Verification failed',
        message: 'Invalid verification code'
      });
    }
  } catch (error) {
    logger.error('Email verification failed:', error, {
      code: req.body?.code,
      ip: req.ip
    });
    
    if (error.message.includes('Invalid') || error.message.includes('expired')) {
      return res.status(400).json({
        error: 'Verification failed',
        message: error.message
      });
    }
    
    if (error.message.includes('Maximum')) {
      return res.status(429).json({
        error: 'Too many attempts',
        message: error.message
      });
    }
    
    res.status(500).json({
      error: 'Verification failed',
      message: 'An error occurred during email verification. Please try again.'
    });
  }
};

/**
 * Request password reset
 */
export const requestPasswordResetHandler = async (req, res) => {
  try {
    const { email } = req.body;
    
    await requestPasswordReset(email);
    
    logger.info('Password reset requested', {
      email: email,
      ip: req.ip
    });
    
    // Always return success to prevent email enumeration
    res.status(200).json({
      message: 'If an account with that email exists, a password reset link has been sent'
    });
  } catch (error) {
    logger.error('Password reset request failed:', error, {
      email: req.body?.email,
      ip: req.ip
    });
    
    // Always return success to prevent email enumeration
    res.status(200).json({
      message: 'If an account with that email exists, a password reset link has been sent'
    });
  }
};

/**
 * Reset password with token
 */
export const resetPasswordHandler = async (req, res) => {
  try {
    const { token, newPassword } = req.body;
    
    const success = await resetPassword(token, newPassword);
    
    if (success) {
      logger.info('Password reset successful', {
        ip: req.ip
      });
      
      res.status(200).json({
        message: 'Password reset successfully'
      });
    } else {
      res.status(400).json({
        error: 'Password reset failed',
        message: 'Invalid or expired reset token'
      });
    }
  } catch (error) {
    logger.error('Password reset failed:', error, {
      ip: req.ip
    });
    
    if (error.message.includes('Invalid') || error.message.includes('expired')) {
      return res.status(400).json({
        error: 'Password reset failed',
        message: error.message
      });
    }
    
    if (error.message.includes('Maximum')) {
      return res.status(429).json({
        error: 'Too many attempts',
        message: error.message
      });
    }
    
    res.status(500).json({
      error: 'Password reset failed',
      message: 'An error occurred during password reset. Please try again.'
    });
  }
};

/**
 * Get current user profile
 */
export const getCurrentUser = async (req, res) => {
  try {
    // User data is already attached by authenticate middleware
    const user = req.user;
    
    if (!user) {
      return res.status(401).json({
        error: 'Authentication required',
        message: 'Please log in to access this resource'
      });
    }

    // Fetch user with associated profiles
    const userWithProfiles = await User.findByPk(user.id, {
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
        }
      ]
    });

    if (!userWithProfiles) {
      return res.status(404).json({
        error: 'User not found',
        message: 'User data could not be retrieved'
      });
    }
    
    logger.info('Current user fetched', {
      userId: user.id,
      hasDocktorProfile: !!userWithProfiles.doctorProfile,
      hasPatientProfile: !!userWithProfiles.patientProfile,
      ip: req.ip
    });

    // Build response with profile data
    const responseData = {
      id: userWithProfiles.id,
      email: userWithProfiles.email,
      firstName: userWithProfiles.firstName,
      lastName: userWithProfiles.lastName,
      role: userWithProfiles.role,
      isActive: userWithProfiles.isActive,
      emailVerified: userWithProfiles.emailVerified
    };

    // Include doctor profile if exists
    if (userWithProfiles.doctorProfile) {
      responseData.doctorProfile = {
        id: userWithProfiles.doctorProfile.id,
        licenseNumber: userWithProfiles.doctorProfile.licenseNumber,
        specialty: userWithProfiles.doctorProfile.specialty,
        title: userWithProfiles.doctorProfile.title,
        bio: userWithProfiles.doctorProfile.bio,
        yearsOfExperience: userWithProfiles.doctorProfile.yearsOfExperience,
        consultationFee: userWithProfiles.doctorProfile.consultationFee,
        verified: userWithProfiles.doctorProfile.verified
      };
    }

    // Include patient profile if exists
    if (userWithProfiles.patientProfile) {
      responseData.patientProfile = {
        id: userWithProfiles.patientProfile.id,
        dateOfBirth: userWithProfiles.patientProfile.dateOfBirth,
        gender: userWithProfiles.patientProfile.gender,
        bloodType: userWithProfiles.patientProfile.bloodType,
        allergies: userWithProfiles.patientProfile.allergies,
        chronicConditions: userWithProfiles.patientProfile.chronicConditions,
        emergencyContactName: userWithProfiles.patientProfile.emergencyContactName,
        emergencyContactPhone: userWithProfiles.patientProfile.emergencyContactPhone
      };
    }
    
    res.status(200).json(responseData);
  } catch (error) {
    logger.error('Get current user failed:', error, {
      userId: req.user?.id,
      ip: req.ip
    });
    
    res.status(500).json({
      error: 'Failed to fetch user data',
      message: 'An error occurred while fetching user information'
    });
  }
};

/**
 * Update user's FCM token for push notifications
 */
export const updateFcmToken = async (req, res) => {
  try {
    const { token } = req.body;
    const userId = req.user.id;
    
    if (!token || typeof token !== 'string') {
      return res.status(400).json({
        success: false,
        message: 'Invalid FCM token'
      });
    }
    
    // Import User model
    const { User } = await import('../models/index.js');
    
    // Update user's FCM token
    await User.update(
      { fcm_token: token },
      { where: { id: userId } }
    );
    
    logger.info(`FCM token updated for user ${userId}`);
    
    res.status(200).json({
      success: true,
      message: 'FCM token registered successfully'
    });
  } catch (error) {
    logger.error('Update FCM token failed:', error, {
      userId: req.user?.id
    });
    
    res.status(500).json({
      success: false,
      message: 'Failed to register FCM token',
      error: error.message
    });
  }
};
