import logger from '../config/logger.js';
import config from '../config/index.js';

// Not found handler
export const notFoundHandler = (req, res) => {
  res.status(404).json({
    error: 'Not Found',
    message: `Route ${req.method} ${req.path} not found`,
    timestamp: new Date().toISOString()
  });
};

// Error handler middleware
export const errorHandler = (error, req, res, next) => {
  // Log the error
  logger.error('Request Error', {
    message: error.message,
    stack: config.isDevelopment ? error.stack : undefined,
    method: req.method,
    url: req.url,
    userId: req.user?.id || 'anonymous',
    ip: req.ip
  });

  // Default error response
  let statusCode = 500;
  let message = 'Internal Server Error';
  let details = {};

  // Handle specific error types
  if (error.name === 'ValidationError') {
    statusCode = 400;
    message = 'Validation Error';
    details = error.details || {};
  } else if (error.name === 'UnauthorizedError' || error.message === 'Unauthorized') {
    statusCode = 401;
    message = 'Unauthorized';
  } else if (error.name === 'ForbiddenError' || error.message === 'Forbidden') {
    statusCode = 403;
    message = 'Forbidden';
  } else if (error.name === 'NotFoundError' || error.message === 'Not Found') {
    statusCode = 404;
    message = 'Not Found';
  } else if (error.name === 'ConflictError' || error.message === 'Conflict') {
    statusCode = 409;
    message = 'Conflict';
  } else if (error.statusCode) {
    statusCode = error.statusCode;
    message = error.message;
  }

  // Construct error response
  const errorResponse = {
    error: message,
    timestamp: new Date().toISOString(),
    path: req.path,
    method: req.method
  };

  // Add error details in development mode
  if (config.isDevelopment) {
    errorResponse.details = details;
    if (error.stack) {
      errorResponse.stack = error.stack;
    }
  }

  // Add validation details if present
  if (Object.keys(details).length > 0) {
    errorResponse.validationErrors = details;
  }

  res.status(statusCode).json(errorResponse);
};

// Async error wrapper
export const asyncHandler = (fn) => {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};
