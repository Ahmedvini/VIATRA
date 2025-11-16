import pkg from 'pg';
import config from './index.js';
import logger from './logger.js';

const { Pool } = pkg;

let pool = null;

// Create database connection pool
const createPool = () => {
  const poolConfig = {
    host: config.database.host,
    port: config.database.port,
    database: config.database.name,
    user: config.database.user,
    password: config.database.password,
    
    // Pool settings
    max: 20, // Maximum number of clients in the pool
    idleTimeoutMillis: 30000, // Close idle clients after 30 seconds
    connectionTimeoutMillis: 10000, // Return an error if no connection available within 10 seconds
    
    // SSL configuration for production
    ssl: config.isProduction ? {
      rejectUnauthorized: false
    } : false
  };
  
  // Use DATABASE_URL if provided (common in cloud environments)
  if (config.database.url) {
    return new Pool({
      connectionString: config.database.url,
      max: 20,
      idleTimeoutMillis: 30000,
      connectionTimeoutMillis: 10000,
      ssl: config.isProduction ? {
        rejectUnauthorized: false
      } : false
    });
  }
  
  return new Pool(poolConfig);
};

// Connect to database
export const connectDatabase = async () => {
  try {
    pool = createPool();
    
    // Test connection
    const client = await pool.connect();
    logger.info('Database connected successfully');
    client.release();
    
    // Handle pool errors
    pool.on('error', (error) => {
      logger.error('Database pool error:', error);
    });
    
    return pool;
  } catch (error) {
    logger.error('Database connection failed:', error);
    throw error;
  }
};

// Disconnect from database
export const disconnectDatabase = async () => {
  if (pool) {
    try {
      await pool.end();
      logger.info('Database disconnected');
    } catch (error) {
      logger.error('Error disconnecting from database:', error);
      throw error;
    }
  }
};

// Query wrapper with error handling and logging
export const query = async (text, params = []) => {
  const start = Date.now();
  
  try {
    if (!pool) {
      throw new Error('Database not connected');
    }
    
    const result = await pool.query(text, params);
    const duration = Date.now() - start;
    
    logger.debug('Database query executed', {
      query: text,
      duration: `${duration}ms`,
      rows: result.rowCount
    });
    
    return result;
  } catch (error) {
    const duration = Date.now() - start;
    
    logger.error('Database query error', {
      query: text,
      params: params,
      duration: `${duration}ms`,
      error: error.message
    });
    
    throw error;
  }
};

// Transaction wrapper
export const transaction = async (callback) => {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    const result = await callback(client);
    await client.query('COMMIT');
    return result;
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
};

// Health check function
export const checkDatabaseHealth = async () => {
  try {
    const result = await query('SELECT NOW() as current_time');
    return {
      status: 'healthy',
      timestamp: result.rows[0].current_time
    };
  } catch (error) {
    return {
      status: 'unhealthy',
      error: error.message
    };
  }
};

export { pool };
