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
  status: Joi.string()
    .valid('approved', 'rejected')
    .required()
    .messages({
      'any.only': 'Status must be either approved or rejected',
      'any.required': 'Status is required'
    }),
  
  reason: Joi.string()
    .trim()
    .max(1000)
    .when('status', {
      is: 'rejected',
      then: Joi.optional(), // Optional but recommended for rejected
      otherwise: Joi.optional()
    })
    .messages({
      'string.max': 'Reason cannot exceed 1000 characters'
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
 * Health Profile validation schemas
 */
export const healthProfileCreateSchema = Joi.object({
  bloodType: Joi.string()
    .valid('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')
    .messages({
      'any.only': 'Blood type must be one of: A+, A-, B+, B-, AB+, AB-, O+, O-'
    }),
  
  height: Joi.number()
    .min(30)
    .max(300)
    .messages({
      'number.min': 'Height must be at least 30 cm',
      'number.max': 'Height cannot exceed 300 cm'
    }),
  
  weight: Joi.number()
    .min(1)
    .max(1000)
    .messages({
      'number.min': 'Weight must be at least 1 kg',
      'number.max': 'Weight cannot exceed 1000 kg'
    }),
  
  allergies: Joi.array().items(
    Joi.object({
      allergen: Joi.string().required(),
      severity: Joi.string().valid('mild', 'moderate', 'severe', 'life-threatening'),
      notes: Joi.string().allow('', null)
    })
  ),
  
  chronicConditions: Joi.array().items(
    Joi.object({
      name: Joi.string().required(),
      diagnosedDate: Joi.date(),
      severity: Joi.string().valid('mild', 'moderate', 'severe'),
      medications: Joi.array().items(Joi.string()),
      notes: Joi.string().allow('', null)
    })
  ),
  
  currentMedications: Joi.array().items(
    Joi.object({
      name: Joi.string().required(),
      dosage: Joi.string(),
      frequency: Joi.string(),
      startDate: Joi.date(),
      endDate: Joi.date(),
      prescribedBy: Joi.string()
    })
  ),
  
  lifestyle: Joi.object({
    smoking: Joi.string().valid('never', 'former', 'current', 'occasional'),
    alcohol: Joi.string().valid('never', 'occasional', 'moderate', 'heavy'),
    exerciseFrequency: Joi.string().valid('sedentary', 'light', 'moderate', 'active', 'very-active'),
    diet: Joi.string().valid('omnivore', 'vegetarian', 'vegan', 'pescatarian', 'other')
  }),
  
  emergencyContactName: Joi.string().trim().max(100),
  
  emergencyContactPhone: phoneSchema,
  
  emergencyContactRelationship: Joi.string().trim().max(50),
  
  preferredPharmacy: Joi.string().trim().max(200),
  
  insuranceProvider: Joi.string().trim().max(100),
  
  insuranceId: Joi.string().trim().max(100),
  
  notes: Joi.string().allow('', null).max(2000)
});

export const healthProfileUpdateSchema = Joi.object({
  bloodType: Joi.string()
    .valid('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')
    .messages({
      'any.only': 'Blood type must be one of: A+, A-, B+, B-, AB+, AB-, O+, O-'
    }),
  
  height: Joi.number()
    .min(30)
    .max(300)
    .messages({
      'number.min': 'Height must be at least 30 cm',
      'number.max': 'Height cannot exceed 300 cm'
    }),
  
  weight: Joi.number()
    .min(1)
    .max(1000)
    .messages({
      'number.min': 'Weight must be at least 1 kg',
      'number.max': 'Weight cannot exceed 1000 kg'
    }),
  
  allergies: Joi.array().items(
    Joi.object({
      allergen: Joi.string().required(),
      severity: Joi.string().valid('mild', 'moderate', 'severe', 'life-threatening'),
      notes: Joi.string().allow('', null)
    })
  ),
  
  chronicConditions: Joi.array().items(
    Joi.object({
      name: Joi.string().required(),
      diagnosedDate: Joi.date(),
      severity: Joi.string().valid('mild', 'moderate', 'severe'),
      medications: Joi.array().items(Joi.string()),
      notes: Joi.string().allow('', null)
    })
  ),
  
  currentMedications: Joi.array().items(
    Joi.object({
      name: Joi.string().required(),
      dosage: Joi.string(),
      frequency: Joi.string(),
      startDate: Joi.date(),
      endDate: Joi.date(),
      prescribedBy: Joi.string()
    })
  ),
  
  lifestyle: Joi.object({
    smoking: Joi.string().valid('never', 'former', 'current', 'occasional'),
    alcohol: Joi.string().valid('never', 'occasional', 'moderate', 'heavy'),
    exerciseFrequency: Joi.string().valid('sedentary', 'light', 'moderate', 'active', 'very-active'),
    diet: Joi.string().valid('omnivore', 'vegetarian', 'vegan', 'pescatarian', 'other')
  }),
  
  emergencyContactName: Joi.string().trim().max(100),
  
  emergencyContactPhone: phoneSchema,
  
  emergencyContactRelationship: Joi.string().trim().max(50),
  
  preferredPharmacy: Joi.string().trim().max(200),
  
  insuranceProvider: Joi.string().trim().max(100),
  
  insuranceId: Joi.string().trim().max(100),
  
  notes: Joi.string().allow('', null).max(2000)
});

export const chronicConditionSchema = Joi.object({
  name: Joi.string().required().trim().min(2).max(200)
    .messages({
      'any.required': 'Condition name is required',
      'string.min': 'Condition name must be at least 2 characters',
      'string.max': 'Condition name cannot exceed 200 characters'
    }),
  
  diagnosedDate: Joi.date()
    .max('now')
    .messages({
      'date.max': 'Diagnosed date cannot be in the future'
    }),
  
  severity: Joi.string()
    .valid('mild', 'moderate', 'severe')
    .required()
    .messages({
      'any.required': 'Severity is required',
      'any.only': 'Severity must be mild, moderate, or severe'
    }),
  
  medications: Joi.array().items(Joi.string()),
  
  notes: Joi.string().allow('', null).max(1000)
});

export const allergySchema = Joi.object({
  allergen: Joi.string().required().trim().min(2).max(200)
    .messages({
      'any.required': 'Allergen name is required',
      'string.min': 'Allergen name must be at least 2 characters',
      'string.max': 'Allergen name cannot exceed 200 characters'
    }),
  
  severity: Joi.string()
    .valid('mild', 'moderate', 'severe', 'life-threatening')
    .required()
    .messages({
      'any.required': 'Severity is required',
      'any.only': 'Severity must be mild, moderate, severe, or life-threatening'
    }),
  
  notes: Joi.string().allow('', null).max(500)
});

export const vitalsSchema = Joi.object({
  height: Joi.number()
    .min(30)
    .max(300)
    .messages({
      'number.min': 'Height must be at least 30 cm',
      'number.max': 'Height cannot exceed 300 cm'
    }),
  
  weight: Joi.number()
    .min(1)
    .max(1000)
    .messages({
      'number.min': 'Weight must be at least 1 kg',
      'number.max': 'Weight cannot exceed 1000 kg'
    }),
  
  bloodType: Joi.string()
    .valid('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')
    .messages({
      'any.only': 'Blood type must be one of: A+, A-, B+, B-, AB+, AB-, O+, O-'
    })
}).min(1).messages({
  'object.min': 'At least one vital field must be provided'
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
      allowUnknown: true, // Allow unknown fields (will be passed to service layer)
      stripUnknown: false // Keep unknown fields for service layer processing
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
