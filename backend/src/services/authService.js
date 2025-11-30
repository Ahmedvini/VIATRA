// src/services/authService.js
import crypto from 'crypto';
import { Op } from 'sequelize'; // ✅ for "ne" operator in resetPassword
import {
  sendVerificationEmail,
  sendPasswordResetEmail,
  sendWelcomeEmail
} from '../utils/email.js';
import {
  generateTokens,
  verifyToken,
  validateTokenType,
  decodeToken
} from '../utils/jwt.js';
import {
  createSession,
  getSession,
  deleteSession,
  updateSession
} from './sessionService.js';
import logger from '../config/logger.js';
import config from '../config/index.js';
import models from '../models/index.js'; // ✅ default export with all models

/**
 * Generate 6-digit verification code
 * @returns {string} - 6-digit numeric code
 */
const generateVerificationCode = () => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

/**
 * Generate secure reset token
 * @returns {string} - Secure random token
 */
const generateResetToken = () => {
  return crypto.randomBytes(32).toString('hex');
};

/**
 * Register a new user
 * @param {Object} userData - User registration data
 * @returns {Promise<Object>} - Created user with tokens
 */
export const registerUser = async (userData) => {
  const {
    email,
    password,
    firstName,
    lastName,
    phone,
    role,
    preferredLanguage = 'en',
    ...roleSpecificData
  } = userData;

  try {
    // Check if user already exists
    const existingUser = await models.User.findOne({ where: { email } });
    if (existingUser) {
      throw new Error('User with this email already exists');
    }

    // Start transaction
    const result = await models.sequelize.transaction(async (transaction) => {
      // Create user record
      const user = await models.User.create(
        {
          email,
          password_hash: password, // Will be hashed by the User model hook
          first_name: firstName,
          last_name: lastName,
          phone,
          role,
          is_active: true,
          email_verified: false
        },
        { transaction }
      );

      // Create role-specific profile
      let profile = null;
      if (role === 'patient') {
        profile = await models.Patient.create(
          {
            user_id: user.id,
            date_of_birth: roleSpecificData.dateOfBirth || new Date('1990-01-01'),
            gender: roleSpecificData.gender || 'prefer_not_to_say',
            preferred_language: preferredLanguage
          },
          { transaction }
        );
      } else if (role === 'doctor') {
        profile = await models.Doctor.create(
          {
            user_id: user.id,
            license_number: roleSpecificData.licenseNumber,
            specialty: roleSpecificData.specialty,
            title: roleSpecificData.title,
            npi_number: roleSpecificData.npiNumber,
            education: roleSpecificData.education,
            consultation_fee: roleSpecificData.consultationFee,
            telehealth_enabled: true,
            is_accepting_patients: false // Require verification first
          },
          { transaction }
        );
      }

      // Generate email verification code
      const verificationCode = generateVerificationCode();
      const expiresAt = new Date(Date.now() + config.email.verificationCodeExpiry);

      // Create email verification record
      await models.Verification.create(
        {
          user_id: user.id,
          doctor_id: profile && role === 'doctor' ? profile.id : null,
          type: 'email',
          status: 'pending',
          verification_code: verificationCode,
          expires_at: expiresAt,
          attempts: 0,
          max_attempts: 3
        },
        { transaction }
      );

      return { user, profile, verificationCode };
    });

    // Send verification email
    const emailSent = await sendVerificationEmail(
      result.user.email,
      result.user.first_name,
      result.verificationCode,
      preferredLanguage
    );

    if (!emailSent) {
      logger.warn('Failed to send verification email', { userId: result.user.id });
    }

    // Generate JWT tokens
    const tokens = generateTokens({
      userId: result.user.id,
      email: result.user.email,
      role: result.user.role
    });

    // Prepare session payload
    const sessionPayload = {
      userId: result.user.id,
      email: result.user.email,
      role: result.user.role,
      firstName: result.user.first_name,
      lastName: result.user.last_name,
      isActive: result.user.is_active,
      emailVerified: result.user.email_verified
    };

    // Decode tokens to get expiration dates
    const accessTokenDecoded = decodeToken(tokens.accessToken);
    const refreshTokenDecoded = decodeToken(tokens.refreshToken);

    const accessTokenExpiration = accessTokenDecoded
      ? new Date(accessTokenDecoded.exp * 1000)
      : null;
    const refreshTokenExpiration = refreshTokenDecoded
      ? new Date(refreshTokenDecoded.exp * 1000)
      : null;

    // Create session for access token
    await createSession(
      tokens.accessToken,
      sessionPayload,
      false,
      'access',
      accessTokenExpiration
    );

    // Create session for refresh token
    await createSession(
      tokens.refreshToken,
      sessionPayload,
      true,
      'refresh',
      refreshTokenExpiration
    );

    logger.info('User registered successfully', {
      userId: result.user.id,
      email: result.user.email,
      role: result.user.role
    });

    return {
      user: {
        id: result.user.id,
        email: result.user.email,
        firstName: result.user.first_name,
        lastName: result.user.last_name,
        role: result.user.role,
        isActive: result.user.is_active,
        emailVerified: result.user.email_verified
      },
      profile: result.profile,
      tokens: tokens,
      emailSent: emailSent
    };
  } catch (error) {
    logger.error('User registration failed:', error);
    throw error;
  }
};

/**
 * Authenticate user login
 * @param {string} email - User email
 * @param {string} password - User password
 * @param {boolean} rememberMe - Extended session flag
 * @returns {Promise<Object>} - User data with tokens
 */
export const loginUser = async (email, password, rememberMe = false) => {
  try {
    // Find user by email
    const user = await models.User.findOne({
      where: { email },
      include: [
        {
          model: models.Patient,
          as: 'patientProfile',
          required: false
        },
        {
          model: models.Doctor,
          as: 'doctorProfile',
          required: false
        }
      ]
    });

    if (!user) {
      throw new Error('Invalid email or password');
    }

    // Check if account is active
    if (!user.is_active) {
      throw new Error('Account has been deactivated. Please contact support.');
    }

    // Verify password
    const isPasswordValid = await user.checkPassword(password);
    if (!isPasswordValid) {
      throw new Error('Invalid email or password');
    }

    // Generate JWT tokens
    const tokens = generateTokens({
      userId: user.id,
      email: user.email,
      role: user.role
    });

    // Prepare session payload
    const sessionPayload = {
      userId: user.id,
      email: user.email,
      role: user.role,
      firstName: user.first_name,
      lastName: user.last_name,
      isActive: user.is_active,
      emailVerified: user.email_verified
    };

    // Decode tokens to get expiration dates
    const accessTokenDecoded = decodeToken(tokens.accessToken);
    const refreshTokenDecoded = decodeToken(tokens.refreshToken);

    const accessTokenExpiration = accessTokenDecoded
      ? new Date(accessTokenDecoded.exp * 1000)
      : null;
    const refreshTokenExpiration = refreshTokenDecoded
      ? new Date(refreshTokenDecoded.exp * 1000)
      : null;

    // Create session for access token
    await createSession(
      tokens.accessToken,
      sessionPayload,
      rememberMe,
      'access',
      accessTokenExpiration
    );

    // Create session for refresh token
    await createSession(
      tokens.refreshToken,
      sessionPayload,
      true,
      'refresh',
      refreshTokenExpiration
    );

    // Update last login time
    await user.update({
      last_login: new Date()
    });

    logger.info('User logged in successfully', {
      userId: user.id,
      email: user.email,
      rememberMe: rememberMe
    });

    return {
      user: {
        id: user.id,
        email: user.email,
        firstName: user.first_name,
        lastName: user.last_name,
        role: user.role,
        isActive: user.is_active,
        emailVerified: user.email_verified,
        lastLogin: user.last_login
      },
      profile: user.patientProfile || user.doctorProfile || null,
      tokens: tokens
    };
  } catch (error) {
    logger.error('User login failed:', error);
    throw error;
  }
};

/**
 * Verify email with verification code
 * @param {string} code - 6-digit verification code
 * @param {string} email - User email (optional for additional verification)
 * @returns {Promise<boolean>} - Success status
 */
export const verifyEmail = async (code, email = null) => {
  try {
    // Find verification record
    const verification = await models.Verification.findOne({
      where: {
        verification_code: code,
        type: 'email',
        status: 'pending'
      },
      include: [
        {
          model: models.User,
          as: 'user',
          where: email ? { email } : {},
          required: true
        }
      ]
    });

    if (!verification) {
      throw new Error('Invalid or expired verification code');
    }

    // Check if code is expired
    if (verification.expires_at && new Date() > verification.expires_at) {
      throw new Error('Verification code has expired');
    }

    // Check attempts limit
    if (verification.attempts >= verification.max_attempts) {
      throw new Error('Maximum verification attempts exceeded');
    }

    // Start transaction
    await models.sequelize.transaction(async (transaction) => {
      // Mark verification as verified
      await verification.update(
        {
          status: 'verified',
          verified_at: new Date(),
          attempts: verification.attempts + 1
        },
        { transaction }
      );

      // Update user email_verified status
      await verification.user.update(
        {
          email_verified: true
        },
        { transaction }
      );
    });

    // Send welcome email
    await sendWelcomeEmail(
      verification.user.email,
      verification.user.first_name,
      verification.user.role
    );

    logger.info('Email verified successfully', {
      userId: verification.user.id,
      email: verification.user.email
    });

    return true;
  } catch (error) {
    logger.error('Email verification failed:', error);
    throw error;
  }
};

/**
 * Request password reset
 * @param {string} email - User email
 * @returns {Promise<boolean>} - Success status
 */
export const requestPasswordReset = async (email) => {
  try {
    // Find user by email
    const user = await models.User.findOne({ where: { email } });
    if (!user) {
      // Don't reveal if user exists or not
      logger.info('Password reset requested for non-existent email', { email });
      return true;
    }

    // Generate secure reset token
    const resetToken = generateResetToken();
    const expiresAt = new Date(Date.now() + config.email.resetTokenExpiry);

    // Create or update reset verification record
    const [verification] = await models.Verification.findOrCreate({
      where: {
        user_id: user.id,
        type: 'password_reset',
        status: 'pending'
      },
      defaults: {
        verification_code: resetToken,
        expires_at: expiresAt,
        attempts: 0,
        max_attempts: 3
      }
    });

    // If record already exists, update it
    if (!verification.isNewRecord) {
      await verification.update({
        verification_code: resetToken,
        expires_at: expiresAt,
        attempts: 0,
        status: 'pending'
      });
    }

    // Send password reset email
    const emailSent = await sendPasswordResetEmail(
      user.email,
      user.first_name,
      resetToken
    );

    if (!emailSent) {
      logger.warn('Failed to send password reset email', { userId: user.id });
    }

    logger.info('Password reset requested', {
      userId: user.id,
      email: user.email
    });

    return true;
  } catch (error) {
    logger.error('Password reset request failed:', error);
    throw error;
  }
};

/**
 * Reset password with token
 * @param {string} token - Reset token
 * @param {string} newPassword - New password
 * @returns {Promise<boolean>} - Success status
 */
export const resetPassword = async (token, newPassword) => {
  try {
    // Find verification record
    const verification = await models.Verification.findOne({
      where: {
        verification_code: token,
        type: 'password_reset',
        status: 'pending'
      },
      include: [
        {
          model: models.User,
          as: 'user',
          required: true
        }
      ]
    });

    if (!verification) {
      throw new Error('Invalid or expired reset token');
    }

    // Check if token is expired
    if (verification.expires_at && new Date() > verification.expires_at) {
      throw new Error('Reset token has expired');
    }

    // Check attempts limit
    if (verification.attempts >= verification.max_attempts) {
      throw new Error('Maximum reset attempts exceeded');
    }

    // Start transaction
    await models.sequelize.transaction(async (transaction) => {
      // Update user password
      await verification.user.update(
        {
          password_hash: newPassword // Will be hashed by the User model hook
        },
        { transaction }
      );

      // Mark verification as verified (consumed)
      await verification.update(
        {
          status: 'verified',
          verified_at: new Date(),
          attempts: verification.attempts + 1
        },
        { transaction }
      );

      // Invalidate all other reset tokens for this user
      await models.Verification.update(
        {
          status: 'expired'
        },
        {
          where: {
            user_id: verification.user.id,
            type: 'password_reset',
            status: 'pending',
            id: { [Op.ne]: verification.id } // ✅ use Sequelize.Op correctly
          },
          transaction
        }
      );
    });

    logger.info('Password reset successfully', {
      userId: verification.user.id,
      email: verification.user.email
    });

    return true;
  } catch (error) {
    logger.error('Password reset failed:', error);
    throw error;
  }
};

/**
 * Refresh access token using refresh token
 * @param {string} refreshToken - JWT refresh token
 * @returns {Promise<string>} - New access token
 */
export const refreshAccessToken = async (refreshToken) => {
  try {
    // Verify refresh token
    const decoded = verifyToken(refreshToken);

    // Validate token type
    if (!validateTokenType(refreshToken, 'refresh')) {
      throw new Error('Invalid token type');
    }

    // Check if session exists
    const sessionExists = await getSession(refreshToken);
    if (!sessionExists) {
      throw new Error('Session not found or expired');
    }

    // Find user to get latest data
    const user = await models.User.findByPk(decoded.userId);
    if (!user || !user.is_active) {
      throw new Error('User not found or inactive');
    }

    // Generate new access token
    const tokens = generateTokens({
      userId: user.id,
      email: user.email,
      role: user.role
    });

    // Update session with new access token
    await createSession(tokens.accessToken, {
      userId: user.id,
      email: user.email,
      role: user.role,
      firstName: user.first_name,
      lastName: user.last_name,
      isActive: user.is_active,
      emailVerified: user.email_verified
    });

    logger.info('Access token refreshed successfully', {
      userId: user.id
    });

    return tokens.accessToken;
  } catch (error) {
    logger.error('Token refresh failed:', error);
    throw error;
  }
};
