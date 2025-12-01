import { createClient } from 'redis';
import logger from './logger.js';
import config from './index.js';

let client = null;

/**
 * Create a Redis client
 * Supports:
 *  - REDIS_URL (Upstash, Redis cloud, Railway, Render)
 *  - Manual config (local docker/localhost redis)
 */
const createRedisClient = () => {
  // If a full Redis URL exists → use URL mode (recommended for production)
  if (process.env.REDIS_URL) {
    logger.info('Redis: Using URL connection mode');

    return createClient({
      url: process.env.REDIS_URL,
      socket: {
        tls: process.env.REDIS_URL.startsWith('rediss://') ? true : false,
        reconnectStrategy: (retries) => {
          if (retries > 10) return new Error('Too many Redis reconnect attempts');
          const delay = Math.min(retries * 200, 3000);
          logger.warn(`Redis reconnect attempt #${retries} in ${delay}ms`);
          return delay;
        }
      }
    });
  }

  // Otherwise fallback to manual config (local development)
  logger.info('Redis: Using manual host/port mode');

  return createClient({
    socket: {
      host: config.redis.host || '127.0.0.1',
      port: config.redis.port || 6379,
      connectTimeout: 10000
    },
    password: config.redis.auth || undefined,
    database: config.redis.database || 0
  });
};

/**
 * Connect to Redis
 */
export const connectRedis = async () => {
  try {
    if (client && client.isReady) return client;

    client = createRedisClient();

    client.on('connect', () => logger.info('Redis: Connecting...'));
    client.on('ready', () => logger.info('Redis: Connected ✔'));
    client.on('reconnecting', () => logger.warn('Redis: Reconnecting...'));
    client.on('error', (err) => logger.error('Redis error ❌', err.message));
    client.on('end', () => logger.warn('Redis: Connection closed'));

    await client.connect();
    return client;

  } catch (error) {
    logger.error('Redis connection failed ❌', error.message);
    throw error;
  }
};

/**
 * Disconnect cleanly
 */
export const disconnectRedis = async () => {
  if (client && client.isOpen) {
    await client.quit();
    logger.info('Redis: Disconnected');
  }
};

/**
 * Helper Operations
 */
export const get = async (key) => {
  if (!client?.isReady) throw new Error('Redis client not ready');
  return client.get(key);
};

export const set = async (key, value, options = {}) => {
  if (!client?.isReady) throw new Error('Redis client not ready');
  return options.ttl ? client.setEx(key, options.ttl, value) : client.set(key, value);
};

export const del = async (key) => {
  if (!client?.isReady) throw new Error('Redis client not ready');
  return client.del(key);
};

export const exists = async (key) => {
  if (!client?.isReady) throw new Error('Redis client not ready');
  return (await client.exists(key)) === 1;
};

export const hget = async (key, field) => {
  if (!client?.isReady) throw new Error('Redis client not ready');
  return client.hGet(key, field);
};

export const hset = async (key, field, value) => {
  if (!client?.isReady) throw new Error('Redis client not ready');
  return client.hSet(key, field, value);
};

export const expire = async (key, seconds) => {
  if (!client?.isReady) throw new Error('Redis client not ready');
  return client.expire(key, seconds);
};

/**
 * Health check for monitoring endpoints
 */
export const checkRedisHealth = async () => {
  try {
    if (!client?.isReady) return { status: 'unhealthy', error: 'Not connected' };
    const ping = await client.ping();
    return { status: 'healthy', response: ping };
  } catch (error) {
    return { status: 'unhealthy', error: error.message };
  }
};

export { client };
export default client;
