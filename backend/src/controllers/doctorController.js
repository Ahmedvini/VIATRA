import Joi from 'joi';
import * as doctorService from '../services/doctorService.js';
import logger from '../config/logger.js';

/**
 * Joi schema for search query validation
 */
const searchSchema = Joi.object({
  searchQuery: Joi.string().max(200).optional(),
  specialty: Joi.string().max(100).optional(),
  subSpecialty: Joi.string().max(100).optional(),
  city: Joi.string().max(100).optional(),
  state: Joi.string().max(50).optional(),
  zipCode: Joi.string().max(10).optional(),
  minFee: Joi.number().min(0).optional(),
  maxFee: Joi.number().min(0).optional(),
  languages: Joi.string().optional(), // Comma-separated string
  isAcceptingPatients: Joi.boolean().optional(),
  telehealthEnabled: Joi.boolean().optional(),
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(100).default(20),
  sortBy: Joi.string().valid('created_at', 'consultation_fee', 'years_of_experience').default('created_at'),
  sortOrder: Joi.string().valid('ASC', 'DESC').default('DESC')
});

/**
 * Search doctors with filters
 */
export const searchDoctors = async (req, res) => {
  try {
    // Validate query parameters
    const { error, value } = searchSchema.validate(req.query);
    if (error) {
      return res.status(400).json({
        success: false,
        message: 'Invalid query parameters',
        errors: error.details.map(detail => detail.message)
      });
    }

    // Parse languages from comma-separated string to array
    const filters = {
      searchQuery: value.searchQuery,
      specialty: value.specialty,
      subSpecialty: value.subSpecialty,
      city: value.city,
      state: value.state,
      zipCode: value.zipCode,
      minFee: value.minFee,
      maxFee: value.maxFee,
      languages: value.languages ? value.languages.split(',').map(lang => lang.trim()) : undefined,
      isAcceptingPatients: value.isAcceptingPatients,
      telehealthEnabled: value.telehealthEnabled
    };

    // Remove undefined values
    Object.keys(filters).forEach(key => filters[key] === undefined && delete filters[key]);

    // Search doctors
    const result = await doctorService.searchDoctors(
      filters,
      value.page,
      value.limit,
      value.sortBy,
      value.sortOrder
    );

    logger.info(`Doctor search completed: ${result.pagination.total} results`);

    return res.status(200).json({
      success: true,
      message: 'Doctors retrieved successfully',
      data: result
    });
  } catch (error) {
    logger.error('Error in searchDoctors controller:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to search doctors',
      error: error.message
    });
  }
};

/**
 * Get doctor by ID
 */
export const getDoctorById = async (req, res) => {
  try {
    const { id } = req.params;

    // Validate UUID
    const uuidSchema = Joi.string().uuid().required();
    const { error } = uuidSchema.validate(id);
    if (error) {
      return res.status(400).json({
        success: false,
        message: 'Invalid doctor ID format'
      });
    }

    const doctor = await doctorService.getDoctorById(id);

    if (!doctor) {
      return res.status(404).json({
        success: false,
        message: 'Doctor not found'
      });
    }

    logger.info(`Doctor ${id} retrieved successfully`);

    return res.status(200).json({
      success: true,
      message: 'Doctor retrieved successfully',
      data: doctor
    });
  } catch (error) {
    logger.error('Error in getDoctorById controller:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to retrieve doctor',
      error: error.message
    });
  }
};

/**
 * Get doctor availability
 */
export const getDoctorAvailability = async (req, res) => {
  try {
    const { id } = req.params;

    // Validate UUID
    const uuidSchema = Joi.string().uuid().required();
    const { error } = uuidSchema.validate(id);
    if (error) {
      return res.status(400).json({
        success: false,
        message: 'Invalid doctor ID format'
      });
    }

    const availability = await doctorService.getDoctorAvailability(id);

    if (!availability) {
      return res.status(404).json({
        success: false,
        message: 'Doctor not found'
      });
    }

    logger.info(`Doctor ${id} availability retrieved successfully`);

    return res.status(200).json({
      success: true,
      message: 'Doctor availability retrieved successfully',
      data: availability
    });
  } catch (error) {
    logger.error('Error in getDoctorAvailability controller:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to retrieve doctor availability',
      error: error.message
    });
  }
};
