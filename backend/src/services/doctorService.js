import { Op } from 'sequelize';
import Doctor from '../models/Doctor.js';
import User from '../models/User.js';
import redisClient from '../config/redis.js';
import logger from '../config/logger.js';

/**
 * Generate Redis cache key for doctor search
 */
const generateCacheKey = (filters, page, limit, sortBy, sortOrder) => {
  const filterString = JSON.stringify(filters);
  return `doctor_search:${filterString}:${page}:${limit}:${sortBy}:${sortOrder}`;
};

/**
 * Search doctors with filters and pagination
 */
export const searchDoctors = async (filters, page = 1, limit = 20, sortBy = 'created_at', sortOrder = 'DESC') => {
  try {
    const cacheKey = generateCacheKey(filters, page, limit, sortBy, sortOrder);
    
    // Check Redis cache
    const cachedResults = await redisClient.get(cacheKey);
    if (cachedResults) {
      logger.info('Doctor search results retrieved from cache');
      return JSON.parse(cachedResults);
    }

    // Build where clause
    const whereClause = {};

    // Free-text search across multiple fields
    if (filters.searchQuery) {
      whereClause[Op.or] = [
        { specialty: { [Op.iLike]: `%${filters.searchQuery}%` } },
        { sub_specialty: { [Op.iLike]: `%${filters.searchQuery}%` } },
        { office_city: { [Op.iLike]: `%${filters.searchQuery}%` } },
        { office_state: { [Op.iLike]: `%${filters.searchQuery}%` } },
        { bio: { [Op.iLike]: `%${filters.searchQuery}%` } }
      ];
    }

    if (filters.specialty) {
      whereClause.specialty = { [Op.iLike]: `%${filters.specialty}%` };
    }

    if (filters.subSpecialty) {
      whereClause.sub_specialty = { [Op.iLike]: `%${filters.subSpecialty}%` };
    }

    if (filters.city) {
      whereClause.office_city = { [Op.iLike]: `%${filters.city}%` };
    }

    if (filters.state) {
      whereClause.office_state = { [Op.iLike]: `%${filters.state}%` };
    }

    if (filters.zipCode) {
      whereClause.office_zip_code = filters.zipCode;
    }

    if (filters.minFee !== undefined || filters.maxFee !== undefined) {
      whereClause.consultation_fee = {
        [Op.between]: [
          filters.minFee || 0,
          filters.maxFee || 999999
        ]
      };
    }

    if (filters.languages && filters.languages.length > 0) {
      whereClause.languages_spoken = {
        [Op.contains]: filters.languages
      };
    }

    if (filters.isAcceptingPatients !== undefined) {
      whereClause.is_accepting_patients = filters.isAcceptingPatients;
    }

    if (filters.telehealthEnabled !== undefined) {
      whereClause.telehealth_enabled = filters.telehealthEnabled;
    }

    // Calculate offset
    const offset = (page - 1) * limit;

    // Query doctors with pagination
    const { count, rows: doctors } = await Doctor.findAndCountAll({
      where: whereClause,
      include: [
        {
          model: User,
          as: 'user',
          attributes: ['id', 'first_name', 'last_name', 'email', 'phone', 'profile_image']
        }
      ],
      order: [[sortBy, sortOrder]],
      limit: parseInt(limit),
      offset: offset,
      distinct: true
    });

    // Calculate pagination metadata
    const totalPages = Math.ceil(count / limit);
    const result = {
      doctors,
      pagination: {
        total: count,
        page: parseInt(page),
        limit: parseInt(limit),
        totalPages
      }
    };

    // Cache results for 5 minutes
    await redisClient.setEx(cacheKey, 300, JSON.stringify(result));
    logger.info(`Doctor search executed, ${count} results found`);

    return result;
  } catch (error) {
    logger.error('Error searching doctors:', error);
    throw error;
  }
};

/**
 * Get doctor by ID with associations
 */
export const getDoctorById = async (doctorId) => {
  try {
    const cacheKey = `doctor:${doctorId}`;
    
    // Check Redis cache
    const cachedDoctor = await redisClient.get(cacheKey);
    if (cachedDoctor) {
      logger.info(`Doctor ${doctorId} retrieved from cache`);
      return JSON.parse(cachedDoctor);
    }

    const doctor = await Doctor.findByPk(doctorId, {
      include: [
        {
          model: User,
          as: 'user',
          attributes: ['id', 'first_name', 'last_name', 'email', 'phone', 'profile_image', 'email_verified']
        }
      ]
    });

    if (!doctor) {
      return null;
    }

    // Cache for 5 minutes
    await redisClient.setEx(cacheKey, 300, JSON.stringify(doctor));
    logger.info(`Doctor ${doctorId} retrieved from database`);

    return doctor;
  } catch (error) {
    logger.error(`Error getting doctor ${doctorId}:`, error);
    throw error;
  }
};

/**
 * Get doctor availability
 */
export const getDoctorAvailability = async (doctorId) => {
  try {
    const doctor = await Doctor.findByPk(doctorId, {
      attributes: ['id', 'working_hours', 'is_accepting_patients', 'telehealth_enabled']
    });

    if (!doctor) {
      return null;
    }

    return {
      workingHours: doctor.working_hours,
      isAcceptingPatients: doctor.is_accepting_patients,
      telehealthEnabled: doctor.telehealth_enabled
    };
  } catch (error) {
    logger.error(`Error getting doctor availability for ${doctorId}:`, error);
    throw error;
  }
};

/**
 * Invalidate doctor cache
 */
export const invalidateDoctorCache = async (doctorId) => {
  try {
    const cacheKey = `doctor:${doctorId}`;
    await redisClient.del(cacheKey);
    
    // Also invalidate search caches (this is simplified; in production, might use cache tags)
    const searchKeys = await redisClient.keys('doctor_search:*');
    if (searchKeys.length > 0) {
      await redisClient.del(searchKeys);
    }
    
    logger.info(`Cache invalidated for doctor ${doctorId}`);
  } catch (error) {
    logger.error(`Error invalidating cache for doctor ${doctorId}:`, error);
  }
};
