import winston from 'winston';
import config from './index.js';

// Define log format
const logFormat = winston.format.combine(
  winston.format.timestamp({
    format: 'YYYY-MM-DD HH:mm:ss'
  }),
  winston.format.errors({ stack: true }),
  winston.format.json()
);

// Define console format for development
const consoleFormat = winston.format.combine(
  winston.format.colorize(),
  winston.format.timestamp({
    format: 'HH:mm:ss'
  }),
  winston.format.printf(({ timestamp, level, message, ...meta }) => {
    const metaStr = Object.keys(meta).length ? JSON.stringify(meta, null, 2) : '';
    return `${timestamp} [${level}]: ${message} ${metaStr}`;
  })
);

// Create logger
const logger = winston.createLogger({
  level: config.isDevelopment ? 'debug' : 'info',
  format: logFormat,
  defaultMeta: {
    service: 'viatra-backend',
    environment: config.nodeEnv
  },
  transports: []
});

// Console transport for all environments
logger.add(new winston.transports.Console({
  format: config.isDevelopment ? consoleFormat : logFormat,
  level: config.isDevelopment ? 'debug' : 'info'
}));

// File transports for production
if (config.isProduction) {
  // Combined log file
  logger.add(new winston.transports.File({
    filename: 'logs/app.log',
    format: logFormat,
    level: 'info',
    maxsize: 5242880, // 5MB
    maxFiles: 5
  }));
  
  // Error log file
  logger.add(new winston.transports.File({
    filename: 'logs/error.log',
    format: logFormat,
    level: 'error',
    maxsize: 5242880, // 5MB
    maxFiles: 5
  }));
}

// Request logging middleware
export const requestLogger = (req, res, next) => {
  const start = Date.now();
  
  // Skip health check logs in production
  if (config.isProduction && req.path === '/health') {
    return next();
  }
  
  res.on('finish', () => {
    const duration = Date.now() - start;
    const logData = {
      method: req.method,
      url: req.url,
      statusCode: res.statusCode,
      duration: `${duration}ms`,
      userAgent: req.get('User-Agent'),
      ip: req.ip,
      userId: req.user?.id || 'anonymous'
    };
    
    if (res.statusCode >= 400) {
      logger.warn('HTTP Request', logData);
    } else {
      logger.info('HTTP Request', logData);
    }
  });
  
  next();
};

// Error logging helper
export const logError = (error, context = {}) => {
  logger.error('Application Error', {
    message: error.message,
    stack: error.stack,
    ...context
  });
};

// Performance logging helper
export const logPerformance = (operation, duration, metadata = {}) => {
  logger.info('Performance Metric', {
    operation,
    duration: `${duration}ms`,
    ...metadata
  });
};

// Security event logging
export const logSecurityEvent = (event, details = {}) => {
  logger.warn('Security Event', {
    event,
    timestamp: new Date().toISOString(),
    ...details
  });
};

export default logger;
