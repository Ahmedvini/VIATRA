// src/config/index.js
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
  origin: process.env.CORS_ORIGIN
    ? process.env.CORS_ORIGIN.split(',').map(origin => origin.trim())
    : ['http://localhost:3000']
};

// Rate limiting configuration
const rateLimit = {
  max: parseInt(process.env.RATE_LIMIT_MAX, 10) || 100,
  window: parseInt(process.env.RATE_LIMIT_WINDOW, 10) || 900000 // 15 minutes
};

// File upload configuration
const fileUpload = {
  maxSize: parseInt(process.env.FILE_UPLOAD_MAX_SIZE, 10) || 10485760, // 10MB
  allowedTypes: process.env.ALLOWED_FILE_TYPES
    ? process.env.ALLOWED_FILE_TYPES.split(',').map(type => type.trim())
    : ['image/jpeg', 'image/png', 'image/gif', 'application/pdf']
};

// Email configuration
const email = {
  from: process.env.EMAIL_FROM || process.env.SMTP_USER || 'noreply@viatra.health',
  fromName: process.env.EMAIL_FROM_NAME || 'Viatra Health',
  replyTo: process.env.EMAIL_REPLY_TO || 'support@viatra.health',
  verificationCodeExpiry: parseInt(process.env.VERIFICATION_CODE_EXPIRY, 10) || 86400000, // 24 hours
  resetTokenExpiry: parseInt(process.env.RESET_TOKEN_EXPIRY, 10) || 3600000 // 1 hour
};

// Frontend configuration
const frontend = {
  url: process.env.FRONTEND_URL || 'http://localhost:3000'
};

// Third-party integrations configuration
const integrations = {
  stripe: {
    apiKey: process.env.STRIPE_API_KEY
  },
  twilio: {
    authToken: process.env.TWILIO_AUTH_TOKEN
  },
  sendgrid: {
    apiKey: process.env.SENDGRID_API_KEY
  },
  firebase: {
    key: process.env.FIREBASE_API_KEY
  },
  oauth: {
    google: {
      clientId: process.env.GOOGLE_CLIENT_ID,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET
    },
    apple: {
      clientId: process.env.APPLE_CLIENT_ID,
      clientSecret: process.env.APPLE_CLIENT_SECRET
    },
    facebook: {
      appId: process.env.FACEBOOK_APP_ID,
      appSecret: process.env.FACEBOOK_APP_SECRET
    }
  }
};

// MAIN CONFIG OBJECT
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
  fileUpload,
  email,
  frontend,
  integrations
};

// Validation function
const validateConfig = () => {
  const required = [];

  if (isProduction || process.env.USE_GCP_SECRETS === 'true') {
    required.push('GCP_PROJECT_ID');
  }

  const missing = required.filter(key => !process.env[key]);

  if (missing.length > 0) {
    throw new Error(`Missing required environment variables: ${missing.join(', ')}`);
  }

  // Validate JWT secret
  if (!config.jwt.secret) {
    throw new Error('JWT secret is required but not configured');
  }

  if (config.jwt.secret.length < 32) {
    throw new Error('JWT_SECRET must be at least 32 characters long');
  }

  if (isProduction) {
    // Prefer DATABASE_URL
    if (!config.database.url) {
      console.warn(
        'WARNING: DATABASE_URL not provided. Using discrete database configuration as fallback.'
      );

      if (!config.database.host) {
        throw new Error('DATABASE_HOST is required in production when DATABASE_URL is not provided');
      }
      if (!config.database.name) {
        throw new Error('DATABASE_NAME is required in production when DATABASE_URL is not provided');
      }
      if (!config.database.user) {
        throw new Error('DATABASE_USER is required in production when DATABASE_URL is not provided');
      }
      if (!config.database.password) {
        throw new Error('DATABASE_PASSWORD is required in production when DATABASE_URL is not provided');
      }
    }

    // Redis validation
    if (!config.redis.host) {
      throw new Error('REDIS_HOST is required in production environment');
    }
    if (!config.redis.port) {
      throw new Error('REDIS_PORT is required in production environment');
    }
    if (!config.redis.auth) {
      console.warn(
        'WARNING: REDIS_AUTH is not set. Consider enabling Redis authentication for production.'
      );
    }
  }
};

// Load secrets from Secret Manager in production
export const loadProductionSecrets = async () => {
  if (!isProduction) return;

  if (!config.gcp.projectId) {
    throw new Error('GCP_PROJECT_ID is required in production for Secret Manager integration');
  }

  const { getSecret, getJsonSecret } = await import('./secrets.js');

  try {
    if (!config.database.password) {
      config.database.password = await getSecret(
        `db-password-${process.env.ENVIRONMENT}`,
        config.gcp.projectId
      );
    }

    if (!config.redis.auth) {
      config.redis.auth = await getSecret(
        `redis-auth-${process.env.ENVIRONMENT}`,
        config.gcp.projectId
      );
    }

    if (!config.jwt.secret) {
      config.jwt.secret = await getSecret(
        `jwt-secret-${process.env.ENVIRONMENT}`,
        config.gcp.projectId
      );
    }

    const appConfigSecrets = await getJsonSecret(`app-config-${process.env.ENVIRONMENT}`);

    config.fileUpload.maxSize =
      parseInt(appConfigSecrets.file_upload_max_size, 10) || config.fileUpload.maxSize;
    config.rateLimit.max =
      parseInt(appConfigSecrets.rate_limit_max, 10) || config.rateLimit.max;
    config.rateLimit.window =
      parseInt(appConfigSecrets.rate_limit_window, 10) || config.rateLimit.window;

    const apiKeysSecrets = await getJsonSecret(`api-keys-${process.env.ENVIRONMENT}`);

    config.integrations.stripe.apiKey =
      apiKeysSecrets.stripe_api_key || config.integrations.stripe.apiKey;
    config.integrations.twilio.authToken =
      apiKeysSecrets.twilio_auth_token || config.integrations.twilio.authToken;
    config.integrations.sendgrid.apiKey =
      apiKeysSecrets.sendgrid_api_key || config.integrations.sendgrid.apiKey;
    config.integrations.firebase.key =
      apiKeysSecrets.firebase_key || config.integrations.firebase.key;

    const oauthSecrets = await getJsonSecret(`oauth-config-${process.env.ENVIRONMENT}`);

    config.integrations.oauth.google.clientId =
      oauthSecrets.google_client_id || config.integrations.oauth.google.clientId;
    config.integrations.oauth.google.clientSecret =
      oauthSecrets.google_client_secret || config.integrations.oauth.google.clientSecret;
    config.integrations.oauth.apple.clientId =
      oauthSecrets.apple_client_id || config.integrations.oauth.apple.clientId;
    config.integrations.oauth.apple.clientSecret =
      oauthSecrets.apple_client_secret || config.integrations.oauth.apple.clientSecret;
    config.integrations.oauth.facebook.appId =
      oauthSecrets.facebook_app_id || config.integrations.oauth.facebook.appId;
    config.integrations.oauth.facebook.appSecret =
      oauthSecrets.facebook_app_secret || config.integrations.oauth.facebook.appSecret;
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

// In non-production, validate immediately
if (!isProduction) {
  validateConfig();
}

export default config;
