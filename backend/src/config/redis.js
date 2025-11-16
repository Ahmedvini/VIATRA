import { createClient } from 'redis';
import config from './index.js';
import logger from './logger.js';

let client = null;

// Create Redis client
const createRedisClient = () => {
  const clientConfig = {
    socket: {
      host: config.redis.host,
      port: config.redis.port,
      connectTimeout: 10000,
      lazyConnect: true
    },
    password: config.redis.auth || undefined,
    database: config.redis.database
  };
  
  // Retry strategy
  clientConfig.socket.reconnectStrategy = (retries) => {
    if (retries >= 10) {
      logger.error('Redis: Too many retry attempts, giving up');
      return new Error('Too many retry attempts');
    }
    
    const delay = Math.min(retries * 100, 3000);
    logger.warn(`Redis: Retrying connection in ${delay}ms (attempt ${retries + 1})`);
    return delay;
  };
  
  return createClient(clientConfig);
};

// Connect to Redis
export const connectRedis = async () => {
  try {
    client = createRedisClient();
    
    // Event listeners
    client.on('connect', () => {
      logger.info('Redis: Connecting...');
    });
    
    client.on('ready', () => {
      logger.info('Redis: Connected and ready');
    });
    
    client.on('error', (error) => {
      logger.error('Redis error:', error);
    });
    
    client.on('reconnecting', () => {
      logger.info('Redis: Reconnecting...');
    });
    
    client.on('end', () => {
      logger.info('Redis: Connection ended');
    });
    
    // Connect to Redis
    await client.connect();
    
    return client;
  } catch (error) {
    logger.error('Redis connection failed:', error);
    throw error;
  }
};

// Disconnect from Redis
export const disconnectRedis = async () => {
  if (client && client.isOpen) {
    try {
      await client.quit();
      logger.info('Redis disconnected');
    } catch (error) {
      logger.error('Error disconnecting from Redis:', error);
      throw error;
    }
  }
};

// Redis helper functions with error handling
export const get = async (key) => {
  try {
    if (!client || !client.isReady) {
      throw new Error('Redis client not ready');
    }
    
    const value = await client.get(key);
    logger.debug(`Redis GET: ${key}`);
    return value;
  } catch (error) {
    logger.error(`Redis GET error for key ${key}:`, error);
    throw error;
  }
};

export const set = async (key, value, options = {}) => {
  try {
    if (!client || !client.isReady) {
      throw new Error('Redis client not ready');
    }
    
    let result;
    if (options.ttl) {
      result = await client.setEx(key, options.ttl, value);
    } else {
      result = await client.set(key, value);
    }
    
    logger.debug(`Redis SET: ${key} (TTL: ${options.ttl || 'none'})`);
    return result;
  } catch (error) {
    logger.error(`Redis SET error for key ${key}:`, error);
    throw error;
  }
};

export const del = async (key) => {
  try {
    if (!client || !client.isReady) {
      throw new Error('Redis client not ready');
    }
    
    const result = await client.del(key);
    logger.debug(`Redis DEL: ${key}`);
    return result;
  } catch (error) {
    logger.error(`Redis DEL error for key ${key}:`, error);
    throw error;
  }
};

export const exists = async (key) => {
  try {
    if (!client || !client.isReady) {
      throw new Error('Redis client not ready');
    }
    
    const result = await client.exists(key);
    logger.debug(`Redis EXISTS: ${key} = ${result}`);
    return result === 1;
  } catch (error) {
    logger.error(`Redis EXISTS error for key ${key}:`, error);
    throw error;
  }
};

export const hget = async (key, field) => {
  try {
    if (!client || !client.isReady) {
      throw new Error('Redis client not ready');
    }
    
    const value = await client.hGet(key, field);
    logger.debug(`Redis HGET: ${key}.${field}`);
    return value;
  } catch (error) {
    logger.error(`Redis HGET error for ${key}.${field}:`, error);
    throw error;
  }
};

export const hset = async (key, field, value) => {
  try {
    if (!client || !client.isReady) {
      throw new Error('Redis client not ready');
    }
    
    const result = await client.hSet(key, field, value);
    logger.debug(`Redis HSET: ${key}.${field}`);
    return result;
  } catch (error) {
    logger.error(`Redis HSET error for ${key}.${field}:`, error);
    throw error;
  }
};

export const expire = async (key, seconds) => {
  try {
    if (!client || !client.isReady) {
      throw new Error('Redis client not ready');
    }
    
    const result = await client.expire(key, seconds);
    logger.debug(`Redis EXPIRE: ${key} (${seconds}s)`);
    return result;
  } catch (error) {
    logger.error(`Redis EXPIRE error for key ${key}:`, error);
    throw error;
  }
};

// Health check function
export const checkRedisHealth = async () => {
  try {
    if (!client || !client.isReady) {
      return {
        status: 'unhealthy',
        error: 'Client not ready'
      };
    }
    
    const result = await client.ping();
    return {
      status: 'healthy',
      response: result
    };
  } catch (error) {
    return {
      status: 'unhealthy',
      error: error.message
    };
  }
};

export { client };
