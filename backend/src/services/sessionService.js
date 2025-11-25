import crypto from 'crypto';
import { get, set, del, exists } from '../config/redis.js';
import logger from '../config/logger.js';

// Session configuration
const SESSION_PREFIX = 'session:';
const DEFAULT_TTL = 24 * 60 * 60; // 24 hours in seconds
const EXTENDED_TTL = 7 * 24 * 60 * 60; // 7 days in seconds

/**
 * Generate a secure random session token (fallback for non-JWT sessions)
 * @returns {string} - Session token
 */
const generateSessionToken = () => {
  return crypto.randomBytes(32).toString('hex');
};

/**
 * Get the Redis key for a session token
 * @param {string} token - Session token (JWT or legacy)
 * @returns {string} - Redis key
 */
const getSessionKey = (token) => {
  return `${SESSION_PREFIX}${token}`;
};

/**
 * Create a new session with JWT token
 * @param {string} jwtToken - JWT token generated externally
 * @param {Object} userData - User data to store in session
 * @param {boolean} remember - Whether to extend session TTL
 * @param {string} tokenType - Type of token ('access' or 'refresh')
 * @param {Date} tokenExpiration - Token expiration time
 * @returns {Promise<string>} - Session token (same as JWT token)
 */
export const createSession = async (jwtToken, userData, remember = false, tokenType = 'access', tokenExpiration = null) => {
  try {
    // If no JWT token provided, generate legacy token (backward compatibility)
    const token = jwtToken || generateSessionToken();
    const sessionKey = getSessionKey(token);
    const ttl = remember ? EXTENDED_TTL : DEFAULT_TTL;
    
    const sessionData = {
      ...userData,
      tokenType,
      tokenExpiration: tokenExpiration ? tokenExpiration.toISOString() : null,
      isJWT: !!jwtToken,
      createdAt: new Date().toISOString(),
      lastAccessed: new Date().toISOString(),
      remember
    };
    
    await set(sessionKey, JSON.stringify(sessionData), { ttl });
    
    logger.info(`Session created for user ${userData.userId}`, {
      token: token.substring(0, 8) + '...',
      tokenType,
      isJWT: !!jwtToken,
      ttl,
      remember
    });
    
    return token;
  } catch (error) {
    logger.error('Error creating session:', error);
    throw new Error('Failed to create session');
  }
};

/**
 * Get session data by token
 * @param {string} token - Session token
 * @returns {Promise<Object|null>} - Session data or null if not found
 */
export const getSession = async (token) => {
  try {
    if (!token) {
      return null;
    }
    
    const sessionKey = getSessionKey(token);
    const sessionData = await get(sessionKey);
    
    if (!sessionData) {
      return null;
    }
    
    const parsed = JSON.parse(sessionData);
    
    // Update last accessed time
    parsed.lastAccessed = new Date().toISOString();
    const ttl = parsed.remember ? EXTENDED_TTL : DEFAULT_TTL;
    await set(sessionKey, JSON.stringify(parsed), { ttl });
    
    logger.debug(`Session accessed for user ${parsed.userId}`, {
      token: token.substring(0, 8) + '...'
    });
    
    return parsed;
  } catch (error) {
    logger.error('Error getting session:', error);
    return null;
  }
};

/**
 * Refresh session TTL
 * @param {string} token - Session token
 * @param {boolean} remember - Whether to extend session TTL
 * @returns {Promise<boolean>} - Success status
 */
export const refreshSession = async (token, remember = false) => {
  try {
    if (!token) {
      return false;
    }
    
    const sessionKey = getSessionKey(token);
    const sessionData = await get(sessionKey);
    
    if (!sessionData) {
      return false;
    }
    
    const parsed = JSON.parse(sessionData);
    parsed.lastAccessed = new Date().toISOString();
    parsed.remember = remember;
    
    const ttl = remember ? EXTENDED_TTL : DEFAULT_TTL;
    await set(sessionKey, JSON.stringify(parsed), { ttl });
    
    logger.debug(`Session refreshed for user ${parsed.userId}`, {
      token: token.substring(0, 8) + '...',
      ttl,
      remember
    });
    
    return true;
  } catch (error) {
    logger.error('Error refreshing session:', error);
    return false;
  }
};

/**
 * Delete a session
 * @param {string} token - Session token
 * @returns {Promise<boolean>} - Success status
 */
export const deleteSession = async (token) => {
  try {
    if (!token) {
      return false;
    }
    
    const sessionKey = getSessionKey(token);
    
    // Get session data for logging before deletion
    const sessionData = await get(sessionKey);
    let userId = 'unknown';
    if (sessionData) {
      try {
        const parsed = JSON.parse(sessionData);
        userId = parsed.userId;
      } catch (parseError) {
        logger.warn('Could not parse session data for logging');
      }
    }
    
    const result = await del(sessionKey);
    
    logger.info(`Session deleted for user ${userId}`, {
      token: token.substring(0, 8) + '...',
      deleted: result > 0
    });
    
    return result > 0;
  } catch (error) {
    logger.error('Error deleting session:', error);
    return false;
  }
};

/**
 * Check if a session exists
 * @param {string} token - Session token
 * @returns {Promise<boolean>} - Whether session exists
 */
export const sessionExists = async (token) => {
  try {
    if (!token) {
      return false;
    }
    
    const sessionKey = getSessionKey(token);
    return await exists(sessionKey);
  } catch (error) {
    logger.error('Error checking session existence:', error);
    return false;
  }
};

/**
 * Validate session and automatically refresh if needed
 * @param {string} token - Session token (JWT or legacy)
 * @param {number} refreshThreshold - Seconds before expiration to trigger refresh (default: 300 = 5 minutes)
 * @returns {Promise<Object|null>} - { valid, needsRefresh, sessionData, newToken? }
 */
export const validateAndRefreshSession = async (token, refreshThreshold = 300) => {
  try {
    if (!token) {
      return { valid: false, needsRefresh: false, sessionData: null };
    }
    
    const sessionData = await getSession(token);
    if (!sessionData) {
      return { valid: false, needsRefresh: false, sessionData: null };
    }
    
    const result = { valid: true, needsRefresh: false, sessionData };
    
    // Check if JWT token is about to expire
    if (sessionData.isJWT && sessionData.tokenExpiration) {
      const expirationTime = new Date(sessionData.tokenExpiration);
      const now = new Date();
      const timeUntilExpiration = (expirationTime - now) / 1000; // seconds
      
      if (timeUntilExpiration <= 0) {
        // Token has expired
        await deleteSession(token);
        return { valid: false, needsRefresh: true, sessionData: null };
      }
      
      if (timeUntilExpiration <= refreshThreshold) {
        // Token is about to expire, suggest refresh
        result.needsRefresh = true;
      }
    }
    
    return result;
  } catch (error) {
    logger.error('Error validating session:', error);
    return { valid: false, needsRefresh: false, sessionData: null };
  }
};

/**
 * Update session data
 * @param {string} token - Session token
 * @param {Object} updates - Data to update
 * @returns {Promise<boolean>} - Success status
 */
export const updateSession = async (token, updates) => {
  try {
    if (!token) {
      return false;
    }
    
    const sessionKey = getSessionKey(token);
    const sessionData = await get(sessionKey);
    
    if (!sessionData) {
      return false;
    }
    
    const parsed = JSON.parse(sessionData);
    const updatedData = {
      ...parsed,
      ...updates,
      lastAccessed: new Date().toISOString()
    };
    
    const ttl = parsed.remember ? EXTENDED_TTL : DEFAULT_TTL;
    await set(sessionKey, JSON.stringify(updatedData), { ttl });
    
    logger.debug(`Session updated for user ${parsed.userId}`, {
      token: token.substring(0, 8) + '...',
      updates: Object.keys(updates)
    });
    
    return true;
  } catch (error) {
    logger.error('Error updating session:', error);
    return false;
  }
};

/**
 * Get session statistics
 * @param {string} token - Session token
 * @returns {Promise<Object|null>} - Session statistics
 */
export const getSessionStats = async (token) => {
  try {
    if (!token) {
      return null;
    }
    
    const sessionData = await getSession(token);
    if (!sessionData) {
      return null;
    }
    
    const createdAt = new Date(sessionData.createdAt);
    const lastAccessed = new Date(sessionData.lastAccessed);
    const now = new Date();
    
    return {
      age: Math.floor((now - createdAt) / 1000), // Age in seconds
      lastAccessedAgo: Math.floor((now - lastAccessed) / 1000), // Seconds since last access
      remember: sessionData.remember,
      createdAt: sessionData.createdAt,
      lastAccessed: sessionData.lastAccessed
    };
  } catch (error) {
    logger.error('Error getting session stats:', error);
    return null;
  }
};

/**
 * Clean up expired sessions (utility function for background jobs)
 * Note: Redis automatically handles TTL expiration, but this can be used for manual cleanup
 * @returns {Promise<number>} - Number of sessions cleaned up
 */
export const cleanupExpiredSessions = async () => {
  try {
    // This is a placeholder for manual cleanup logic if needed
    // Redis automatically handles TTL expiration, so this might not be necessary
    logger.info('Session cleanup requested - Redis handles TTL automatically');
    return 0;
  } catch (error) {
    logger.error('Error during session cleanup:', error);
    return 0;
  }
};
