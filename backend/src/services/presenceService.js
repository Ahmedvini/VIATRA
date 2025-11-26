import redisClient from '../config/redis.js';
import logger from '../config/logger.js';

/**
 * Set user as online with their socket ID
 * @param {string} userId - User UUID
 * @param {string} socketId - Socket.io socket ID
 * @returns {Promise<boolean>}
 */
export const setUserOnline = async (userId, socketId) => {
  try {
    const key = `presence:user:${userId}`;
    // Store socket ID with 5-minute expiry (will be renewed on activity)
    await redisClient.setEx(key, 300, socketId);
    logger.debug(`User ${userId} set as online with socket ${socketId}`);
    return true;
  } catch (error) {
    logger.error('Error setting user online:', error);
    return false;
  }
};

/**
 * Set user as offline
 * @param {string} userId - User UUID
 * @returns {Promise<boolean>}
 */
export const setUserOffline = async (userId) => {
  try {
    const key = `presence:user:${userId}`;
    await redisClient.del(key);
    
    // Update last seen timestamp
    await updateLastSeen(userId);
    
    logger.debug(`User ${userId} set as offline`);
    return true;
  } catch (error) {
    logger.error('Error setting user offline:', error);
    return false;
  }
};

/**
 * Check if a user is currently online
 * @param {string} userId - User UUID
 * @returns {Promise<boolean>}
 */
export const getUserPresence = async (userId) => {
  try {
    const key = `presence:user:${userId}`;
    const socketId = await redisClient.get(key);
    return socketId !== null;
  } catch (error) {
    logger.error('Error checking user presence:', error);
    return false;
  }
};

/**
 * Get presence status for multiple users
 * @param {string[]} userIds - Array of user UUIDs
 * @returns {Promise<Object>} Object mapping userId to boolean online status
 */
export const getUsersPresence = async (userIds) => {
  try {
    const results = {};
    
    // Batch check all users
    const promises = userIds.map(async (userId) => {
      const isOnline = await getUserPresence(userId);
      results[userId] = isOnline;
    });
    
    await Promise.all(promises);
    
    return results;
  } catch (error) {
    logger.error('Error checking multiple users presence:', error);
    return {};
  }
};

/**
 * Update user's last seen timestamp
 * @param {string} userId - User UUID
 * @returns {Promise<boolean>}
 */
export const updateLastSeen = async (userId) => {
  try {
    const key = `presence:lastseen:${userId}`;
    const timestamp = new Date().toISOString();
    
    // Store last seen timestamp (no expiry)
    await redisClient.hSet('presence:lastseen', userId, timestamp);
    
    logger.debug(`Updated last seen for user ${userId}`);
    return true;
  } catch (error) {
    logger.error('Error updating last seen:', error);
    return false;
  }
};

/**
 * Get user's last seen timestamp
 * @param {string} userId - User UUID
 * @returns {Promise<string|null>} ISO timestamp or null
 */
export const getLastSeen = async (userId) => {
  try {
    const timestamp = await redisClient.hGet('presence:lastseen', userId);
    return timestamp;
  } catch (error) {
    logger.error('Error getting last seen:', error);
    return null;
  }
};

/**
 * Get socket ID for an online user
 * @param {string} userId - User UUID
 * @returns {Promise<string|null>} Socket ID or null if offline
 */
export const getUserSocketId = async (userId) => {
  try {
    const key = `presence:user:${userId}`;
    return await redisClient.get(key);
  } catch (error) {
    logger.error('Error getting user socket ID:', error);
    return null;
  }
};

/**
 * Renew user's online presence (extend TTL)
 * @param {string} userId - User UUID
 * @returns {Promise<boolean>}
 */
export const renewUserPresence = async (userId) => {
  try {
    const key = `presence:user:${userId}`;
    const socketId = await redisClient.get(key);
    
    if (socketId) {
      await redisClient.expire(key, 300); // Extend for another 5 minutes
      return true;
    }
    
    return false;
  } catch (error) {
    logger.error('Error renewing user presence:', error);
    return false;
  }
};
