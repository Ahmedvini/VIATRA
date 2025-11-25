import Joi from 'joi';

/**
 * Strong password validation
 */
const passwordSchema = Joi.string()
  .min(8)
  .max(128)
  .pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/)
  .messages({
    'string.min': 'Password must be at least 8 characters long',
    'string.max': 'Password cannot exceed 128 characters',
    'string.pattern.base': 'Password must contain at least one lowercase letter, one uppercase letter, one number, and one special character'
  });

/**
 * Phone number validation (international format)
 */
const phoneSchema = Joi.string()
  .pattern(/^\+?[\d\s\-\(\)]+$/)
  .min(10)
  .max(20)
  .messages({
    'string.pattern.base': 'Phone number must contain only digits, spaces, hyphens, and parentheses',
    'string.min': 'Phone number must be at least 10 characters',
    'string.max': 'Phone number cannot exceed 20 characters'
  });

/**
 * User registration schema
 */
export const registerSchema = Joi.object({
  email: Joi.string()
    .email({ tlds: { allow: false } })
    .lowercase()
    .required()
    .messages({
      'string.email': 'Please provide a valid email address',
      'any.required': 'Email is required'
    }),
  
  password: passwordSchema.required(),
  
  firstName: Joi.string()
    .trim()
    .min(1)
    .max(50)
    .pattern(/^[a-zA-Z\u0600-\u06FF\s]+$/)
    .required()
    .messages({
      'string.min': 'First name is required',
      'string.max': 'First name cannot exceed 50 characters',
      'string.pattern.base': 'First name can only contain letters and spaces',
      'any.required': 'First name is required'
    }),
  
  lastName: Joi.string()
    .trim()
    .min(1)
    .max(50)
    .pattern(/^[a-zA-Z\u0600-\u06FF\s]+$/)
    .required()
    .messages({
      'string.min': 'Last name is required',
      'string.max': 'Last name cannot exceed 50 characters',
      'string.pattern.base': 'Last name can only contain letters and spaces',
      'any.required': 'Last name is required'
    }),
  
  phone: phoneSchema.optional(),
  
  role: Joi.string()
    .valid('patient', 'doctor', 'hospital', 'pharmacy', 'admin')
    .required()
    .messages({
      'any.only': 'Role must be one of: patient, doctor, hospital, pharmacy, admin',
      'any.required': 'Role is required'
    }),
  
  preferredLanguage: Joi.string()
    .valid('en', 'ar')
    .default('en')
    .messages({
      'any.only': 'Preferred language must be either en or ar'
    })
});

/**
 * Doctor registration schema (extends base registration)
 */
export const doctorRegisterSchema = registerSchema.keys({
  licenseNumber: Joi.string()
    .trim()
    .min(5)
    .max(50)
    .required()
    .messages({
      'string.min': 'License number must be at least 5 characters',
      'string.max': 'License number cannot exceed 50 characters',
      'any.required': 'License number is required for doctors'
    }),
  
  specialty: Joi.string()
    .trim()
    .min(2)
    .max(100)
    .required()
    .messages({
      'string.min': 'Specialty must be at least 2 characters',
      'string.max': 'Specialty cannot exceed 100 characters',
      'any.required': 'Medical specialty is required'
    }),
  
  title: Joi.string()
    .valid('Dr.', 'PA', 'NP', 'MD', 'DO', 'RN')
    .required()
    .messages({
      'any.only': 'Title must be one of: Dr., PA, NP, MD, DO, RN',
      'any.required': 'Professional title is required'
    }),
  
  npiNumber: Joi.string()
    .pattern(/^\d{10}$/)
    .optional()
    .messages({
      'string.pattern.base': 'NPI number must be exactly 10 digits'
    }),
  
  education: Joi.string()
    .trim()
    .max(1000)
    .optional()
    .messages({
      'string.max': 'Education details cannot exceed 1000 characters'
    }),
  
  consultationFee: Joi.number()
    .positive()
    .precision(2)
    .max(10000)
    .optional()
    .messages({
      'number.positive': 'Consultation fee must be a positive number',
      'number.max': 'Consultation fee cannot exceed $10,000'
    })
});

/**
 * Login schema
 */
export const loginSchema = Joi.object({
  email: Joi.string()
    .email({ tlds: { allow: false } })
    .lowercase()
    .required()
    .messages({
      'string.email': 'Please provide a valid email address',
      'any.required': 'Email is required'
    }),
  
  password: Joi.string()
    .required()
    .messages({
      'any.required': 'Password is required'
    }),
  
  rememberMe: Joi.boolean()
    .default(false)
});

/**
 * Email verification schema
 */
export const emailVerificationSchema = Joi.object({
  code: Joi.string()
    .pattern(/^\d{6}$/)
    .required()
    .messages({
      'string.pattern.base': 'Verification code must be exactly 6 digits',
      'any.required': 'Verification code is required'
    })
});

/**
 * Password reset request schema
 */
export const passwordResetRequestSchema = Joi.object({
  email: Joi.string()
    .email({ tlds: { allow: false } })
    .lowercase()
    .required()
    .messages({
      'string.email': 'Please provide a valid email address',
      'any.required': 'Email is required'
    })
});

/**
 * Password reset confirmation schema
 */
export const passwordResetSchema = Joi.object({
  token: Joi.string()
    .required()
    .messages({
      'any.required': 'Reset token is required'
    }),
  
  newPassword: passwordSchema.required()
});

/**
 * Refresh token schema
 */
export const refreshTokenSchema = Joi.object({
  refreshToken: Joi.string()
    .required()
    .messages({
      'any.required': 'Refresh token is required'
    })
});

/**
 * Document upload validation schema
 */
export const documentUploadSchema = Joi.object({
  type: Joi.string()
    .valid('medical_license', 'education', 'certification', 'insurance', 'identity')
    .required()
    .messages({
      'any.only': 'Document type must be one of: medical_license, education, certification, insurance, identity',
      'any.required': 'Document type is required'
    }),
  
  description: Joi.string()
    .trim()
    .max(500)
    .optional()
    .messages({
      'string.max': 'Description cannot exceed 500 characters'
    })
});

/**
 * Verification approval/rejection schema
 */
export const verificationActionSchema = Joi.object({
  reason: Joi.string()
    .trim()
    .max(1000)
    .when('action', {
      is: 'reject',
      then: Joi.required(),
      otherwise: Joi.optional()
    })
    .messages({
      'string.max': 'Reason cannot exceed 1000 characters',
      'any.required': 'Reason is required when rejecting verification'
    }),
  
  notes: Joi.string()
    .trim()
    .max(1000)
    .optional()
    .messages({
      'string.max': 'Notes cannot exceed 1000 characters'
    })
});

/**
 * Pagination schema
 */
export const paginationSchema = Joi.object({
  page: Joi.number()
    .integer()
    .min(1)
    .default(1)
    .messages({
      'number.min': 'Page must be at least 1'
    }),
  
  limit: Joi.number()
    .integer()
    .min(1)
    .max(100)
    .default(10)
    .messages({
      'number.min': 'Limit must be at least 1',
      'number.max': 'Limit cannot exceed 100'
    }),
  
  sortBy: Joi.string()
    .optional(),
  
  sortOrder: Joi.string()
    .valid('asc', 'desc')
    .default('desc')
    .messages({
      'any.only': 'Sort order must be either asc or desc'
    })
});

/**
 * Validation middleware factory
 * @param {Object} schema - Joi schema to validate against
 * @param {string} property - Request property to validate (body, query, params)
 * @returns {Function} - Express middleware function
 */
export const validate = (schema, property = 'body') => {
  return (req, res, next) => {
    const { error, value } = schema.validate(req[property], {
      abortEarly: false, // Collect all errors
      allowUnknown: false, // Don't allow unknown fields
      stripUnknown: true // Remove unknown fields
    });
    
    if (error) {
      const errors = error.details.map(detail => ({
        field: detail.path.join('.'),
        message: detail.message,
        value: detail.context?.value
      }));
      
      return res.status(400).json({
        error: 'Validation failed',
        message: 'Please check the provided data',
        details: errors
      });
    }
    
    // Replace original data with validated (and sanitized) data
    req[property] = value;
    next();
  };
};

/**
 * Custom validators
 */
export const customValidators = {
  /**
   * Validate phone number format
   */
  isValidPhone: (phone) => {
    return phoneSchema.validate(phone).error === undefined;
  },
  
  /**
   * Validate strong password
   */
  isStrongPassword: (password) => {
    return passwordSchema.validate(password).error === undefined;
  },
  
  /**
   * Validate email format
   */
  isValidEmail: (email) => {
    const emailSchema = Joi.string().email({ tlds: { allow: false } });
    return emailSchema.validate(email).error === undefined;
  }
};
