// src/config/redis.js
import { createClient } from 'redis';
import config from './index.js';
import logger from './logger.js';

let client;

// Function to initialize Redis client
const initRedis = async () => {
  if (client?.isOpen) return client;

  client = createClient({
    socket: {
      host: config.redis.host,
      port: config.redis.port
    },
    password: config.redis.auth || undefined,
    database: config.redis.database
  });

  client.on('error', (err) => {
    logger.error('Redis connection error:', { error: err.message });
  });

  client.on('connect', () => {
    logger.info(`Redis connected → ${config.redis.host}:${config.redis.port}`);
  });

  client.on('reconnecting', () => {
    logger.warn('Redis reconnecting...');
  });

  await client.connect();
  return client;
};

// Reusable Ensure Connection
const ensureConnected = async () => {
  if (!client?.isOpen) {
    await initRedis();
  }
};

/* ---------- EXPORTED METHODS ---------- */

export const get = async (key) => {
  await ensureConnected();
  return client.get(key);
};

export const set = async (key, value, options = {}) => {
  await ensureConnected();

  if (options.ttl) {
    return client.set(key, value, { EX: options.ttl });
  }

  return client.set(key, value);
};

export const del = async (key) => {
  await ensureConnected();
  return client.del(key);
};

export const exists = async (key) => {
  await ensureConnected();
  return client.exists(key);
};

/* -------- Export full Redis client if needed -------- */
export default client;
