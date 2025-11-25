import 'express-async-errors';
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import rateLimit from 'express-rate-limit';

import config, { initConfig } from './config/index.js';
import { connectDatabase, disconnectDatabase, initializeSequelize, closeSequelize } from './config/database.js';
import { connectRedis, disconnectRedis } from './config/redis.js';
import logger, { requestLogger } from './config/logger.js';
import { errorHandler, notFoundHandler } from './middleware/errorHandler.js';
import { authenticate, authorize } from './middleware/auth.js';

const app = express();

// Trust proxy for Cloud Run
app.set('trust proxy', true);

// Security middleware
app.use(helmet());
app.use(compression());

// CORS configuration
app.use(cors({
  origin: config.cors.origin,
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: config.rateLimit.window,
  max: config.rateLimit.max,
  message: 'Too many requests from this IP, please try again later',
  standardHeaders: true,
  legacyHeaders: false
});
app.use(limiter);

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Request logging
app.use(requestLogger);

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    environment: config.nodeEnv,
    version: process.env.npm_package_version || '1.0.0'
  });
});

// Debug endpoint for environment variable validation (non-production only)
app.get('/debug/env-check', (req, res) => {
  // Only enable in development or when explicitly enabled
  if (config.nodeEnv === 'production' && !process.env.ENABLE_DEBUG_ENDPOINTS) {
    return res.status(404).json({ error: 'Not found' });
  }

  const envCheck = {
    timestamp: new Date().toISOString(),
    environment: config.nodeEnv,
    secrets_loaded: {
      DATABASE_PASSWORD: !!process.env.DATABASE_PASSWORD,
      REDIS_AUTH: !!process.env.REDIS_AUTH,
      JWT_SECRET: !!process.env.JWT_SECRET,
    },
    database_config: {
      host_set: !!process.env.DATABASE_HOST,
      name_set: !!process.env.DATABASE_NAME,
      user_set: !!process.env.DATABASE_USER,
    },
    redis_config: {
      host_set: !!process.env.REDIS_HOST,
      port_set: !!process.env.REDIS_PORT,
    },
    project_config: {
      gcp_project_set: !!process.env.GCP_PROJECT_ID,
      bucket_name_set: !!process.env.GCS_BUCKET_NAME,
    }
  };

  res.status(200).json(envCheck);
});

// Import and mount API routes
import apiRoutes from './routes/index.js';
app.use('/api/v1', apiRoutes);

// 404 handler
app.use(notFoundHandler);

// Error handling middleware
app.use(errorHandler);

// Graceful shutdown handler
const gracefulShutdown = async (signal) => {
  logger.info(`Received ${signal}. Starting graceful shutdown...`);
  
  try {
    await closeSequelize();
    await disconnectDatabase();
    await disconnectRedis();
    logger.info('Graceful shutdown completed');
    process.exit(0);
  } catch (error) {
    logger.error('Error during graceful shutdown:', error);
    process.exit(1);
  }
};

// Handle shutdown signals
process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));

// Handle uncaught exceptions
process.on('uncaughtException', (error) => {
  logger.error('Uncaught Exception:', error);
  process.exit(1);
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (reason, promise) => {
  logger.error('Unhandled Rejection at:', promise, 'reason:', reason);
  process.exit(1);
});

// Start server
const startServer = async () => {
  try {
    // Initialize configuration (load production secrets if needed)
    await initConfig();
    
    // Connect to database and Redis
    await connectDatabase();
    await connectRedis();
    
    // Initialize Sequelize ORM
    await initializeSequelize();
    
    // Start HTTP server
    const server = app.listen(config.port, '0.0.0.0', () => {
      logger.info(`Server running on port ${config.port} in ${config.nodeEnv} mode`);
    });
    
    // Handle server errors
    server.on('error', (error) => {
      logger.error('Server error:', error);
      process.exit(1);
    });
    
    return server;
  } catch (error) {
    logger.error('Failed to start server:', error);
    process.exit(1);
  }
};

// Start the server if this file is run directly
if (process.env.NODE_ENV !== 'test') {
  startServer();
}

export default app;
