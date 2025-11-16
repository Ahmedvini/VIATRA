import dotenv from 'dotenv';

// Load environment variables from .env file
dotenv.config();

const nodeEnv = process.env.NODE_ENV || 'development';
const isProduction = nodeEnv === 'production';
const isDevelopment = nodeEnv === 'development';

// Database configuration
const database = {
  url: process.env.DATABASE_URL,
  host: process.env.DATABASE_HOST || 'localhost',
  port: parseInt(process.env.DATABASE_PORT, 10) || 5432,
  name: process.env.DATABASE_NAME || 'viatra_dev',
  user: process.env.DATABASE_USER || 'postgres',
  password: process.env.DATABASE_PASSWORD
};

// Redis configuration
const redis = {
  host: process.env.REDIS_HOST || 'localhost',
  port: parseInt(process.env.REDIS_PORT, 10) || 6379,
  auth: process.env.REDIS_AUTH,
  database: parseInt(process.env.REDIS_DATABASE, 10) || 0
};

// GCP configuration
const gcp = {
  projectId: process.env.GCP_PROJECT_ID,
  bucketName: process.env.GCS_BUCKET_NAME
};

// JWT configuration
const jwt = {
  secret: process.env.JWT_SECRET,
  expiresIn: process.env.JWT_EXPIRES_IN || '7d'
};

// CORS configuration
const cors = {
  origin: process.env.CORS_ORIGIN ? 
    process.env.CORS_ORIGIN.split(',').map(origin => origin.trim()) : 
    ['http://localhost:3000']
};

// Rate limiting configuration
const rateLimit = {
  max: parseInt(process.env.RATE_LIMIT_MAX, 10) || 100,
  window: parseInt(process.env.RATE_LIMIT_WINDOW, 10) || 900000 // 15 minutes
};

// File upload configuration
const fileUpload = {
  maxSize: parseInt(process.env.FILE_UPLOAD_MAX_SIZE, 10) || 10485760, // 10MB
  allowedTypes: process.env.ALLOWED_FILE_TYPES ? 
    process.env.ALLOWED_FILE_TYPES.split(',').map(type => type.trim()) :
    ['image/jpeg', 'image/png', 'image/gif', 'application/pdf']
};

// Validation function
const validateConfig = () => {
  const required = [
    'GCP_PROJECT_ID'
  ];
  
  const missing = required.filter(key => !process.env[key]);
  
  if (missing.length > 0) {
    throw new Error(`Missing required environment variables: ${missing.join(', ')}`);
  }
  
  // Validate JWT secret from resolved config object
  if (!config.jwt.secret) {
    throw new Error('JWT secret is required but not configured');
  }
  
  if (config.jwt.secret.length < 32) {
    throw new Error('JWT_SECRET must be at least 32 characters long');
  }
};

const config = {
  nodeEnv,
  port: parseInt(process.env.PORT, 10) || 8080,
  isProduction,
  isDevelopment,
  database,
  redis,
  gcp,
  jwt,
  cors,
  rateLimit,
  fileUpload
};

// Load secrets from Secret Manager in production
export const loadProductionSecrets = async () => {
  if (!isProduction) return;
  
  // Import getSecret only when needed to avoid circular dependency
  const { getSecret } = await import('./secrets.js');
  
  try {
    // Load database password
    if (!config.database.password) {
      config.database.password = await getSecret(`db-password-${process.env.ENVIRONMENT}`, config.gcp.projectId);
    }
    
    // Load Redis auth
    if (!config.redis.auth) {
      config.redis.auth = await getSecret(`redis-auth-${process.env.ENVIRONMENT}`, config.gcp.projectId);
    }
    
    // Load JWT secret
    if (!config.jwt.secret) {
      config.jwt.secret = await getSecret(`jwt-secret-${process.env.ENVIRONMENT}`, config.gcp.projectId);
    }
  } catch (error) {
    console.error('Failed to load secrets from Secret Manager:', error);
    throw error;
  }
};

// Initialize configuration
export const initConfig = async () => {
  try {
    await loadProductionSecrets();
    validateConfig();
  } catch (error) {
    console.error('Configuration initialization failed:', error);
    throw error;
  }
};

// Only run validation in development (secrets loading happens via initConfig in production)
if (!isProduction) {
  validateConfig();
}

export default config;
