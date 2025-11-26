import healthProfileService from '../services/healthProfileService.js';
import Patient from '../models/Patient.js';
import logger from '../config/logger.js';
import {
  healthProfileCreateSchema,
  healthProfileUpdateSchema,
  chronicConditionSchema,
  allergySchema,
  vitalsSchema,
  validate,
} from '../utils/validators.js';

/**
 * Get authenticated patient's health profile
 */
export const getMyHealthProfile = async (req, res) => {
  try {
    // Find patient by user ID
    const patient = await Patient.findOne({
      where: { user_id: req.user.id },
    });

    if (!patient) {
      return res.status(404).json({
        success: false,
        message: 'Patient profile not found',
      });
    }

    // Fetch health profile
    const healthProfile = await healthProfileService.getHealthProfileByPatientId(
      patient.id
    );

    if (!healthProfile) {
      return res.status(404).json({
        success: false,
        message: 'Health profile not found. Please create one first.',
      });
    }

    logger.info(`Retrieved health profile for patient ${patient.id}`);

    return res.status(200).json({
      success: true,
      message: 'Health profile retrieved successfully',
      data: healthProfile,
    });
  } catch (error) {
    logger.error('Error fetching health profile:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to retrieve health profile',
      error: error.message,
    });
  }
};

/**
 * Create health profile for authenticated patient
 */
export const createHealthProfile = async (req, res) => {
  try {
    // Validate request body
    const { error, value } = healthProfileCreateSchema.validate(req.body, {
      abortEarly: false,
      stripUnknown: true,
    });

    if (error) {
      const errors = error.details.map((detail) => ({
        field: detail.path.join('.'),
        message: detail.message,
      }));

      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors,
      });
    }

    // Find patient by user ID
    const patient = await Patient.findOne({
      where: { user_id: req.user.id },
    });

    if (!patient) {
      return res.status(404).json({
        success: false,
        message: 'Patient profile not found',
      });
    }

    // Create health profile
    const healthProfile = await healthProfileService.createHealthProfile(
      patient.id,
      value
    );

    logger.info(`Created health profile for patient ${patient.id}`);

    return res.status(201).json({
      success: true,
      message: 'Health profile created successfully',
      data: healthProfile,
    });
  } catch (error) {
    logger.error('Error creating health profile:', error);

    if (error.message === 'Health profile already exists for this patient') {
      return res.status(409).json({
        success: false,
        message: error.message,
      });
    }

    return res.status(500).json({
      success: false,
      message: 'Failed to create health profile',
      error: error.message,
    });
  }
};

/**
 * Update health profile for authenticated patient
 */
export const updateHealthProfile = async (req, res) => {
  try {
    // Validate request body
    const { error, value } = healthProfileUpdateSchema.validate(req.body, {
      abortEarly: false,
      stripUnknown: true,
    });

    if (error) {
      const errors = error.details.map((detail) => ({
        field: detail.path.join('.'),
        message: detail.message,
      }));

      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors,
      });
    }

    // Find patient by user ID
    const patient = await Patient.findOne({
      where: { user_id: req.user.id },
    });

    if (!patient) {
      return res.status(404).json({
        success: false,
        message: 'Patient profile not found',
      });
    }

    // Update health profile
    const healthProfile = await healthProfileService.updateHealthProfile(
      patient.id,
      value
    );

    logger.info(`Updated health profile for patient ${patient.id}`);

    return res.status(200).json({
      success: true,
      message: 'Health profile updated successfully',
      data: healthProfile,
    });
  } catch (error) {
    logger.error('Error updating health profile:', error);

    if (error.message === 'Health profile not found') {
      return res.status(404).json({
        success: false,
        message: error.message,
      });
    }

    return res.status(500).json({
      success: false,
      message: 'Failed to update health profile',
      error: error.message,
    });
  }
};

/**
 * Add chronic condition to health profile
 */
export const addChronicCondition = async (req, res) => {
  try {
    // Validate request body
    const { error, value } = chronicConditionSchema.validate(req.body, {
      abortEarly: false,
      stripUnknown: true,
    });

    if (error) {
      const errors = error.details.map((detail) => ({
        field: detail.path.join('.'),
        message: detail.message,
      }));

      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors,
      });
    }

    // Find patient by user ID
    const patient = await Patient.findOne({
      where: { user_id: req.user.id },
    });

    if (!patient) {
      return res.status(404).json({
        success: false,
        message: 'Patient profile not found',
      });
    }

    // Add chronic condition
    const healthProfile = await healthProfileService.addChronicCondition(
      patient.id,
      value
    );

    logger.info(`Added chronic condition for patient ${patient.id}`);

    return res.status(200).json({
      success: true,
      message: 'Chronic condition added successfully',
      data: healthProfile,
    });
  } catch (error) {
    logger.error('Error adding chronic condition:', error);

    if (error.message === 'Health profile not found') {
      return res.status(404).json({
        success: false,
        message: error.message,
      });
    }

    return res.status(500).json({
      success: false,
      message: 'Failed to add chronic condition',
      error: error.message,
    });
  }
};

/**
 * Remove chronic condition from health profile
 */
export const removeChronicCondition = async (req, res) => {
  try {
    const { conditionId } = req.params;

    if (!conditionId) {
      return res.status(400).json({
        success: false,
        message: 'Condition ID is required',
      });
    }

    // Find patient by user ID
    const patient = await Patient.findOne({
      where: { user_id: req.user.id },
    });

    if (!patient) {
      return res.status(404).json({
        success: false,
        message: 'Patient profile not found',
      });
    }

    // Remove chronic condition
    const healthProfile = await healthProfileService.removeChronicCondition(
      patient.id,
      conditionId
    );

    logger.info(`Removed chronic condition ${conditionId} for patient ${patient.id}`);

    return res.status(200).json({
      success: true,
      message: 'Chronic condition removed successfully',
      data: healthProfile,
    });
  } catch (error) {
    logger.error('Error removing chronic condition:', error);

    if (error.message === 'Health profile not found') {
      return res.status(404).json({
        success: false,
        message: error.message,
      });
    }

    return res.status(500).json({
      success: false,
      message: 'Failed to remove chronic condition',
      error: error.message,
    });
  }
};

/**
 * Add allergy to health profile
 */
export const addAllergy = async (req, res) => {
  try {
    // Validate request body
    const { error, value } = allergySchema.validate(req.body, {
      abortEarly: false,
      stripUnknown: true,
    });

    if (error) {
      const errors = error.details.map((detail) => ({
        field: detail.path.join('.'),
        message: detail.message,
      }));

      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors,
      });
    }

    // Find patient by user ID
    const patient = await Patient.findOne({
      where: { user_id: req.user.id },
    });

    if (!patient) {
      return res.status(404).json({
        success: false,
        message: 'Patient profile not found',
      });
    }

    // Add allergy
    const healthProfile = await healthProfileService.addAllergy(patient.id, value);

    logger.info(`Added allergy for patient ${patient.id}`);

    return res.status(200).json({
      success: true,
      message: 'Allergy added successfully',
      data: healthProfile,
    });
  } catch (error) {
    logger.error('Error adding allergy:', error);

    if (error.message === 'Health profile not found') {
      return res.status(404).json({
        success: false,
        message: error.message,
      });
    }

    return res.status(500).json({
      success: false,
      message: 'Failed to add allergy',
      error: error.message,
    });
  }
};

/**
 * Remove allergy from health profile
 */
export const removeAllergy = async (req, res) => {
  try {
    const { allergen } = req.params;

    if (!allergen) {
      return res.status(400).json({
        success: false,
        message: 'Allergen name is required',
      });
    }

    // Find patient by user ID
    const patient = await Patient.findOne({
      where: { user_id: req.user.id },
    });

    if (!patient) {
      return res.status(404).json({
        success: false,
        message: 'Patient profile not found',
      });
    }

    // Remove allergy
    const healthProfile = await healthProfileService.removeAllergy(
      patient.id,
      decodeURIComponent(allergen)
    );

    logger.info(`Removed allergy ${allergen} for patient ${patient.id}`);

    return res.status(200).json({
      success: true,
      message: 'Allergy removed successfully',
      data: healthProfile,
    });
  } catch (error) {
    logger.error('Error removing allergy:', error);

    if (error.message === 'Health profile not found') {
      return res.status(404).json({
        success: false,
        message: error.message,
      });
    }

    return res.status(500).json({
      success: false,
      message: 'Failed to remove allergy',
      error: error.message,
    });
  }
};

/**
 * Update vitals in health profile
 */
export const updateVitals = async (req, res) => {
  try {
    // Validate request body
    const { error, value } = vitalsSchema.validate(req.body, {
      abortEarly: false,
      stripUnknown: true,
    });

    if (error) {
      const errors = error.details.map((detail) => ({
        field: detail.path.join('.'),
        message: detail.message,
      }));

      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors,
      });
    }

    // Find patient by user ID
    const patient = await Patient.findOne({
      where: { user_id: req.user.id },
    });

    if (!patient) {
      return res.status(404).json({
        success: false,
        message: 'Patient profile not found',
      });
    }

    // Update vitals
    const healthProfile = await healthProfileService.updateVitals(patient.id, value);

    logger.info(`Updated vitals for patient ${patient.id}`);

    return res.status(200).json({
      success: true,
      message: 'Vitals updated successfully',
      data: healthProfile,
    });
  } catch (error) {
    logger.error('Error updating vitals:', error);

    if (error.message === 'Health profile not found') {
      return res.status(404).json({
        success: false,
        message: error.message,
      });
    }

    return res.status(500).json({
      success: false,
      message: 'Failed to update vitals',
      error: error.message,
    });
  }
};
