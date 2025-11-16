import logger from '../config/logger.js';

export const requestLogger = (req, res, next) => {
  const start = Date.now();
  
  // Skip health check logs in production to reduce noise
  if (process.env.NODE_ENV === 'production' && req.path === '/health') {
    return next();
  }
  
  // Log the incoming request
  logger.debug('Incoming Request', {
    method: req.method,
    url: req.url,
    userAgent: req.get('User-Agent'),
    ip: req.ip,
    contentType: req.get('Content-Type')
  });
  
  // Override res.json to capture response data
  const originalJson = res.json;
  res.json = function (data) {
    res.responseData = data;
    return originalJson.call(this, data);
  };
  
  // Log when the response finishes
  res.on('finish', () => {
    const duration = Date.now() - start;
    const logData = {
      method: req.method,
      url: req.url,
      statusCode: res.statusCode,
      duration: `${duration}ms`,
      userAgent: req.get('User-Agent'),
      ip: req.ip,
      userId: req.user?.id || 'anonymous',
      contentLength: res.get('Content-Length') || 0
    };
    
    // Log level based on status code
    if (res.statusCode >= 500) {
      logger.error('HTTP Request - Server Error', logData);
    } else if (res.statusCode >= 400) {
      logger.warn('HTTP Request - Client Error', logData);
    } else if (res.statusCode >= 300) {
      logger.info('HTTP Request - Redirect', logData);
    } else {
      logger.info('HTTP Request - Success', logData);
    }
    
    // Log slow requests
    if (duration > 1000) {
      logger.warn('Slow Request Detected', {
        ...logData,
        warning: 'Request took longer than 1 second'
      });
    }
  });
  
  // Log when the response closes (client disconnects)
  res.on('close', () => {
    if (!res.finished) {
      logger.warn('Request Aborted', {
        method: req.method,
        url: req.url,
        duration: `${Date.now() - start}ms`,
        ip: req.ip
      });
    }
  });
  
  next();
};
