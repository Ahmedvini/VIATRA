import { getSession } from '../services/sessionService.js';
import { verifyToken, decodeToken } from '../utils/jwt.js';
import logger from '../config/logger.js';

/**
 * Extract bearer token from Authorization header
 * @param {string} authHeader - Authorization header value
 * @returns {string|null} - Bearer token or null
 */
const extractBearerToken = (authHeader) => {
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return null;
  }
  
  return authHeader.substring(7); // Remove "Bearer " prefix
};

/**
 * Main authentication middleware
 * Validates JWT token and session, attaches user data to request
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next function
 */
export const authenticate = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    const token = extractBearerToken(authHeader);
    
    if (!token) {
      return res.status(401).json({
        error: 'Authentication required',
        message: 'Bearer token not provided'
      });
    }
    
    // First, verify JWT token
    let decodedToken;
    try {
      const jwtResult = verifyToken(token);
      if (!jwtResult.valid) {
        logger.warn('JWT verification failed', { 
          error: jwtResult.error,
          token: token.substring(0, 8) + '...'
        });
        
        return res.status(401).json({
          error: 'Invalid token',
          message: jwtResult.error || 'Token verification failed'
        });
      }
      
      decodedToken = jwtResult.decoded;
    } catch (jwtError) {
      logger.error('JWT verification error:', jwtError);
      
      if (jwtError.name === 'TokenExpiredError') {
        return res.status(401).json({
          error: 'Token expired',
          message: 'Your session has expired. Please login again.'
        });
      }
      
      if (jwtError.name === 'JsonWebTokenError') {
        return res.status(401).json({
          error: 'Invalid token',
          message: 'Token is malformed or invalid'
        });
      }
      
      return res.status(401).json({
        error: 'Authentication failed',
        message: 'Token verification failed'
      });
    }
    
    // Then check if session exists in Redis
    const sessionData = await getSession(token);
    
    if (!sessionData) {
      return res.status(401).json({
        error: 'Session expired',
        message: 'Session not found. Please log in again.'
      });
    }
    
    // Check if user is active
    if (!sessionData.isActive) {
      return res.status(401).json({
        error: 'Account deactivated',
        message: 'Your account has been deactivated'
      });
    }
    
    // Validate that JWT data matches session data
    if (decodedToken.userId !== sessionData.userId) {
      logger.error('Token/session mismatch', {
        jwtUserId: decodedToken.userId,
        sessionUserId: sessionData.userId
      });
      
      return res.status(401).json({
        error: 'Authentication error',
        message: 'Token and session mismatch'
      });
    }
    
    // Attach user data to request (prioritize JWT data for freshness)
    req.user = {
      id: decodedToken.userId || sessionData.userId,
      email: decodedToken.email || sessionData.email,
      role: decodedToken.role || sessionData.role,
      firstName: sessionData.firstName,
      lastName: sessionData.lastName,
      isActive: sessionData.isActive,
      emailVerified: sessionData.emailVerified,
      sessionToken: token,
      sessionData: sessionData,
      tokenData: decodedToken
    };
    
    // Add user info to request context for logging
    req.context = {
      ...req.context,
      userId: sessionData.userId,
      userRole: sessionData.role,
      tokenType: decodedToken.type
    };
    
    logger.debug('User authenticated successfully', {
      userId: sessionData.userId,
      role: sessionData.role,
      tokenType: decodedToken.type,
      endpoint: `${req.method} ${req.path}`
    });
    
    next();
  } catch (error) {
    logger.error('Authentication middleware error:', error);
    return res.status(500).json({
      error: 'Authentication error',
      message: 'An error occurred during authentication'
    });
  }
};

/**
 * Authorization middleware factory
 * Creates middleware that checks if user has required roles
 * @param {...string} requiredRoles - Required user roles
 * @returns {Function} - Express middleware function
 */
export const authorize = (...requiredRoles) => {
  return (req, res, next) => {
    try {
      // Check if user is authenticated
      if (!req.user) {
        return res.status(401).json({
          error: 'Authentication required',
          message: 'Please authenticate first'
        });
      }
      
      // Check if user has required role
      const userRole = req.user.role;
      
      if (!requiredRoles.includes(userRole)) {
        logger.warn('Authorization failed', {
          userId: req.user.id,
          userRole: userRole,
          requiredRoles: requiredRoles,
          endpoint: `${req.method} ${req.path}`
        });
        
        return res.status(403).json({
          error: 'Insufficient permissions',
          message: `Access denied. Required roles: ${requiredRoles.join(', ')}`
        });
      }
      
      logger.debug('User authorized successfully', {
        userId: req.user.id,
        userRole: userRole,
        requiredRoles: requiredRoles,
        endpoint: `${req.method} ${req.path}`
      });
      
      next();
    } catch (error) {
      logger.error('Authorization middleware error:', error);
      return res.status(500).json({
        error: 'Authorization error',
        message: 'An error occurred during authorization'
      });
    }
  };
};

/**
 * Optional authentication middleware
 * Attempts to authenticate but doesn't reject if no token provided
 * Useful for endpoints that have both authenticated and unauthenticated access
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next function
 */
export const optionalAuthenticate = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    const token = extractBearerToken(authHeader);
    
    // If no token provided, continue without authentication
    if (!token) {
      return next();
    }
    
    // Try to verify JWT token
    let decodedToken;
    try {
      const jwtResult = verifyToken(token);
      if (jwtResult.valid) {
        decodedToken = jwtResult.decoded;
      }
    } catch (jwtError) {
      // JWT verification failed, continue without authentication
      logger.debug('Optional authentication: JWT verification failed', { error: jwtError.message });
      return next();
    }
    
    // Get session data
    const sessionData = await getSession(token);
    
    // If session is valid and user is active, attach user data
    if (sessionData && sessionData.isActive && decodedToken) {
      req.user = {
        id: decodedToken.userId || sessionData.userId,
        email: decodedToken.email || sessionData.email,
        role: decodedToken.role || sessionData.role,
        firstName: sessionData.firstName,
        lastName: sessionData.lastName,
        isActive: sessionData.isActive,
        emailVerified: sessionData.emailVerified,
        sessionToken: token,
        sessionData: sessionData,
        tokenData: decodedToken
      };
      
      req.context = {
        ...req.context,
        userId: sessionData.userId,
        userRole: sessionData.role,
        tokenType: decodedToken.type
      };
      
      logger.debug('Optional authentication successful', {
        userId: sessionData.userId,
        role: sessionData.role,
        tokenType: decodedToken.type
      });
    }
    
    next();
  } catch (error) {
    logger.error('Optional authentication middleware error:', error);
    // Continue without authentication on error
    next();
  }
};

/**
 * Middleware to check if user email is verified
 * Should be used after authenticate middleware
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next function
 */
export const requireEmailVerified = (req, res, next) => {
  try {
    if (!req.user) {
      return res.status(401).json({
        error: 'Authentication required',
        message: 'Please authenticate first'
      });
    }
    
    if (!req.user.emailVerified) {
      return res.status(403).json({
        error: 'Email verification required',
        message: 'Please verify your email address to access this resource'
      });
    }
    
    next();
  } catch (error) {
    logger.error('Email verification middleware error:', error);
    return res.status(500).json({
      error: 'Verification check error',
      message: 'An error occurred during email verification check'
    });
  }
};

/**
 * Middleware to check if user owns a resource
 * Compares user ID with a resource owner ID from request params or body
 * @param {string} ownerField - Field name containing owner ID (default: 'userId')
 * @param {string} source - Where to find owner ID: 'params', 'body', or 'query' (default: 'params')
 * @returns {Function} - Express middleware function
 */
export const requireOwnership = (ownerField = 'userId', source = 'params') => {
  return (req, res, next) => {
    try {
      if (!req.user) {
        return res.status(401).json({
          error: 'Authentication required',
          message: 'Please authenticate first'
        });
      }
      
      // Admin users can access any resource
      if (req.user.role === 'admin') {
        return next();
      }
      
      let resourceOwnerId;
      
      switch (source) {
        case 'params':
          resourceOwnerId = req.params[ownerField];
          break;
        case 'body':
          resourceOwnerId = req.body[ownerField];
          break;
        case 'query':
          resourceOwnerId = req.query[ownerField];
          break;
        default:
          resourceOwnerId = req.params[ownerField];
      }
      
      if (!resourceOwnerId) {
        return res.status(400).json({
          error: 'Missing owner information',
          message: `Owner field '${ownerField}' not found in ${source}`
        });
      }
      
      if (req.user.id !== resourceOwnerId) {
        logger.warn('Ownership check failed', {
          userId: req.user.id,
          resourceOwnerId: resourceOwnerId,
          ownerField: ownerField,
          endpoint: `${req.method} ${req.path}`
        });
        
        return res.status(403).json({
          error: 'Access denied',
          message: 'You can only access your own resources'
        });
      }
      
      next();
    } catch (error) {
      logger.error('Ownership middleware error:', error);
      return res.status(500).json({
        error: 'Ownership check error',
        message: 'An error occurred during ownership verification'
      });
    }
  };
};
