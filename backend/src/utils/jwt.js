import jwt from 'jsonwebtoken';
import config from '../config/index.js';
import logger from '../config/logger.js';

/**
 * Generate JWT access token (short-lived, 15 minutes)
 * @param {Object} payload - User data to encode
 * @returns {string} - JWT access token
 */
export const generateAccessToken = (payload) => {
  try {
    const tokenPayload = {
      userId: payload.userId,
      email: payload.email,
      role: payload.role,
      type: 'access'
    };
    
    return jwt.sign(tokenPayload, config.jwt.secret, { 
      expiresIn: '15m',
      issuer: 'viatra-health',
      audience: 'viatra-client'
    });
  } catch (error) {
    logger.error('Error generating access token:', error);
    throw new Error('Token generation failed');
  }
};

/**
 * Generate JWT refresh token (long-lived, 7 days)
 * @param {Object} payload - User data to encode
 * @returns {string} - JWT refresh token
 */
export const generateRefreshToken = (payload) => {
  try {
    const tokenPayload = {
      userId: payload.userId,
      email: payload.email,
      role: payload.role,
      type: 'refresh'
    };
    
    return jwt.sign(tokenPayload, config.jwt.secret, { 
      expiresIn: '7d',
      issuer: 'viatra-health',
      audience: 'viatra-client'
    });
  } catch (error) {
    logger.error('Error generating refresh token:', error);
    throw new Error('Token generation failed');
  }
};

/**
 * Generate both access and refresh tokens
 * @param {Object} payload - User data to encode
 * @returns {Object} - Object containing both tokens
 */
export const generateTokens = (payload) => {
  return {
    accessToken: generateAccessToken(payload),
    refreshToken: generateRefreshToken(payload)
  };
};

/**
 * Verify JWT token
 * @param {string} token - JWT token to verify
 * @returns {Object} - Decoded token payload
 */
export const verifyToken = (token) => {
  try {
    const decoded = jwt.verify(token, config.jwt.secret, {
      issuer: 'viatra-health',
      audience: 'viatra-client'
    });
    
    return decoded;
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      throw new Error('Token has expired');
    } else if (error.name === 'JsonWebTokenError') {
      throw new Error('Invalid token');
    } else if (error.name === 'NotBeforeError') {
      throw new Error('Token not active yet');
    }
    
    logger.error('Token verification error:', error);
    throw new Error('Token verification failed');
  }
};

/**
 * Decode JWT token without verification (for expired tokens)
 * @param {string} token - JWT token to decode
 * @returns {Object} - Decoded token payload or null
 */
export const decodeToken = (token) => {
  try {
    return jwt.decode(token);
  } catch (error) {
    logger.error('Token decoding error:', error);
    return null;
  }
};

/**
 * Extract user data from token
 * @param {string} token - JWT token
 * @returns {Object} - User data from token
 */
export const extractUserFromToken = (token) => {
  try {
    const decoded = verifyToken(token);
    
    return {
      userId: decoded.userId,
      email: decoded.email,
      role: decoded.role,
      type: decoded.type,
      iat: decoded.iat,
      exp: decoded.exp
    };
  } catch (error) {
    throw error; // Re-throw the specific error from verifyToken
  }
};

/**
 * Check if token is expired
 * @param {string} token - JWT token
 * @returns {boolean} - True if token is expired
 */
export const isTokenExpired = (token) => {
  try {
    const decoded = decodeToken(token);
    if (!decoded || !decoded.exp) return true;
    
    const currentTime = Math.floor(Date.now() / 1000);
    return decoded.exp < currentTime;
  } catch (error) {
    return true;
  }
};

/**
 * Get token expiration time
 * @param {string} token - JWT token
 * @returns {Date|null} - Expiration date or null
 */
export const getTokenExpiration = (token) => {
  try {
    const decoded = decodeToken(token);
    if (!decoded || !decoded.exp) return null;
    
    return new Date(decoded.exp * 1000);
  } catch (error) {
    return null;
  }
};

/**
 * Validate token type (access or refresh)
 * @param {string} token - JWT token
 * @param {string} expectedType - Expected token type
 * @returns {boolean} - True if token type matches
 */
export const validateTokenType = (token, expectedType) => {
  try {
    const decoded = verifyToken(token);
    return decoded.type === expectedType;
  } catch (error) {
    return false;
  }
};
