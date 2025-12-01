import 'express-async-errors';
import express from 'express';
import { createServer } from 'http';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import config, { initConfig } from './config/index.js';
import { connectDatabase, disconnectDatabase, initializeSequelize, closeSequelize } from './config/database.js';
import { connectRedis, disconnectRedis } from './config/redis.js';
import logger, { requestLogger } from './config/logger.js';
import { errorHandler, notFoundHandler } from './middleware/errorHandler.js';

const app = express();
const httpServer = createServer(app);

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

// Routes will be mounted after initialization
let apiRoutes = null;

// Function to initialize and mount routes
const initializeRoutes = async () => {
  // Dynamically import routes after Sequelize is initialized
  const { default: routes } = await import('./routes/index.js');
  apiRoutes = routes;
  app.use('/api/v1', apiRoutes);
};

// 404 handler
app.use(notFoundHandler);

// Error handling middleware
app.use(errorHandler);

// Graceful shutdown handler
let io = null;

const gracefulShutdown = async (signal) => {
  logger.info(`Received ${signal}. Starting graceful shutdown...`);
  
  try {
    // Close Socket.io connections
    if (io) {
      io.close(() => {
        logger.info('Socket.io server closed');
      });
    }
    
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
    
    // Initialize and mount routes after Sequelize is ready
    await initializeRoutes();
    
    // Initialize Socket.io server (dynamic import to avoid loading models too early)
    const { initializeSocketServer } = await import('./socket/index.js');
    io = initializeSocketServer(httpServer);
    
    // Make io instance available to routes
    app.set('io', io);
    
    // Start HTTP server
    httpServer.listen(config.port, '0.0.0.0', () => {
      logger.info(`Server running on port ${config.port} in ${config.nodeEnv} mode`);
      logger.info(`WebSocket server ready for connections`);
    });
    
    // Handle server errors
    httpServer.on('error', (error) => {
      logger.error('Server error:', error);
      process.exit(1);
    });
    
    return httpServer;
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
