import HealthProfile from '../models/HealthProfile.js';
import Patient from '../models/Patient.js';
import logger from '../config/logger.js';
import redisClient from '../config/redis.js';
import { sequelize } from '../config/database.js';

const CACHE_TTL = 300; // 5 minutes
const CACHE_KEY_PREFIX = 'health_profile:';

class HealthProfileService {
  /**
   * Get health profile by patient ID with Redis caching
   * @param {string} patientId - Patient ID
   * @returns {Promise<HealthProfile|null>}
   */
  async getHealthProfileByPatientId(patientId) {
    try {
      const cacheKey = `${CACHE_KEY_PREFIX}${patientId}`;

      // Try to get from Redis cache
      const cachedData = await redisClient.get(cacheKey);
      if (cachedData) {
        logger.info(`Health profile cache hit for patient ${patientId}`);
        return JSON.parse(cachedData);
      }

      // Fetch from database
      logger.info(`Health profile cache miss for patient ${patientId}`);
      const profile = await HealthProfile.findOne({
        where: { patient_id: patientId },
        include: [
          {
            model: Patient,
            as: 'patient',
            attributes: ['id', 'user_id'],
          },
        ],
      });

      if (profile) {
        // Cache the result
        await redisClient.setex(cacheKey, CACHE_TTL, JSON.stringify(profile));
        logger.info(`Cached health profile for patient ${patientId}`);
      }

      return profile;
    } catch (error) {
      logger.error(`Error fetching health profile for patient ${patientId}:`, error);
      throw error;
    }
  }

  /**
   * Create health profile for a patient
   * @param {string} patientId - Patient ID
   * @param {Object} profileData - Profile data
   * @returns {Promise<HealthProfile>}
   */
  async createHealthProfile(patientId, profileData) {
    const transaction = await sequelize.transaction();

    try {
      // Check if profile already exists
      const existingProfile = await HealthProfile.findOne({
        where: { patient_id: patientId },
      });

      if (existingProfile) {
        await transaction.rollback();
        throw new Error('Health profile already exists for this patient');
      }

      // Create new profile
      const profile = await HealthProfile.create(
        {
          patient_id: patientId,
          blood_type: profileData.bloodType,
          height: profileData.height,
          weight: profileData.weight,
          allergies: profileData.allergies || [],
          chronic_conditions: profileData.chronicConditions || [],
          current_medications: profileData.currentMedications || [],
          family_history: profileData.familyHistory || [],
          lifestyle: profileData.lifestyle || {},
          emergency_contact_name: profileData.emergencyContactName,
          emergency_contact_phone: profileData.emergencyContactPhone,
          emergency_contact_relationship: profileData.emergencyContactRelationship,
          preferred_pharmacy: profileData.preferredPharmacy,
          insurance_provider: profileData.insuranceProvider,
          insurance_id: profileData.insuranceId,
          notes: profileData.notes,
        },
        { transaction }
      );

      await transaction.commit();
      logger.info(`Created health profile for patient ${patientId}`);

      return profile;
    } catch (error) {
      await transaction.rollback();
      logger.error(`Error creating health profile for patient ${patientId}:`, error);
      throw error;
    }
  }

  /**
   * Update health profile
   * @param {string} patientId - Patient ID
   * @param {Object} updates - Partial update data
   * @returns {Promise<HealthProfile>}
   */
  async updateHealthProfile(patientId, updates) {
    const transaction = await sequelize.transaction();

    try {
      const profile = await HealthProfile.findOne({
        where: { patient_id: patientId },
      });

      if (!profile) {
        await transaction.rollback();
        throw new Error('Health profile not found');
      }

      // Update fields
      const updateData = {};
      if (updates.bloodType !== undefined) updateData.blood_type = updates.bloodType;
      if (updates.height !== undefined) updateData.height = updates.height;
      if (updates.weight !== undefined) updateData.weight = updates.weight;
      if (updates.allergies !== undefined) updateData.allergies = updates.allergies;
      if (updates.chronicConditions !== undefined) updateData.chronic_conditions = updates.chronicConditions;
      if (updates.currentMedications !== undefined) updateData.current_medications = updates.currentMedications;
      if (updates.familyHistory !== undefined) updateData.family_history = updates.familyHistory;
      if (updates.lifestyle !== undefined) updateData.lifestyle = updates.lifestyle;
      if (updates.emergencyContactName !== undefined) updateData.emergency_contact_name = updates.emergencyContactName;
      if (updates.emergencyContactPhone !== undefined) updateData.emergency_contact_phone = updates.emergencyContactPhone;
      if (updates.emergencyContactRelationship !== undefined) updateData.emergency_contact_relationship = updates.emergencyContactRelationship;
      if (updates.preferredPharmacy !== undefined) updateData.preferred_pharmacy = updates.preferredPharmacy;
      if (updates.insuranceProvider !== undefined) updateData.insurance_provider = updates.insuranceProvider;
      if (updates.insuranceId !== undefined) updateData.insurance_id = updates.insuranceId;
      if (updates.notes !== undefined) updateData.notes = updates.notes;

      await profile.update(updateData, { transaction });

      await transaction.commit();

      // Invalidate cache
      const cacheKey = `${CACHE_KEY_PREFIX}${patientId}`;
      await redisClient.del(cacheKey);
      logger.info(`Updated health profile for patient ${patientId} and invalidated cache`);

      return profile;
    } catch (error) {
      await transaction.rollback();
      logger.error(`Error updating health profile for patient ${patientId}:`, error);
      throw error;
    }
  }

  /**
   * Add chronic condition
   * @param {string} patientId - Patient ID
   * @param {Object} condition - Condition data
   * @returns {Promise<HealthProfile>}
   */
  async addChronicCondition(patientId, condition) {
    try {
      const profile = await HealthProfile.findOne({
        where: { patient_id: patientId },
      });

      if (!profile) {
        throw new Error('Health profile not found');
      }

      const conditions = profile.chronic_conditions || [];
      const newCondition = {
        id: Date.now().toString(),
        name: condition.name,
        diagnosedDate: condition.diagnosedDate,
        severity: condition.severity,
        medications: condition.medications || [],
        notes: condition.notes,
      };

      conditions.push(newCondition);
      await profile.update({ chronic_conditions: conditions });

      // Invalidate cache
      const cacheKey = `${CACHE_KEY_PREFIX}${patientId}`;
      await redisClient.del(cacheKey);
      logger.info(`Added chronic condition for patient ${patientId}`);

      return profile;
    } catch (error) {
      logger.error(`Error adding chronic condition for patient ${patientId}:`, error);
      throw error;
    }
  }

  /**
   * Remove chronic condition
   * @param {string} patientId - Patient ID
   * @param {string} conditionId - Condition ID
   * @returns {Promise<HealthProfile>}
   */
  async removeChronicCondition(patientId, conditionId) {
    try {
      const profile = await HealthProfile.findOne({
        where: { patient_id: patientId },
      });

      if (!profile) {
        throw new Error('Health profile not found');
      }

      const conditions = profile.chronic_conditions || [];
      const filteredConditions = conditions.filter((c) => c.id !== conditionId);

      await profile.update({ chronic_conditions: filteredConditions });

      // Invalidate cache
      const cacheKey = `${CACHE_KEY_PREFIX}${patientId}`;
      await redisClient.del(cacheKey);
      logger.info(`Removed chronic condition ${conditionId} for patient ${patientId}`);

      return profile;
    } catch (error) {
      logger.error(`Error removing chronic condition for patient ${patientId}:`, error);
      throw error;
    }
  }

  /**
   * Add allergy
   * @param {string} patientId - Patient ID
   * @param {Object} allergyData - Allergy data
   * @returns {Promise<HealthProfile>}
   */
  async addAllergy(patientId, allergyData) {
    try {
      const profile = await HealthProfile.findOne({
        where: { patient_id: patientId },
      });

      if (!profile) {
        throw new Error('Health profile not found');
      }

      // Use model's addAllergy method
      await profile.addAllergy(
        allergyData.allergen,
        allergyData.severity,
        allergyData.notes
      );

      // Invalidate cache
      const cacheKey = `${CACHE_KEY_PREFIX}${patientId}`;
      await redisClient.del(cacheKey);
      logger.info(`Added allergy for patient ${patientId}`);

      return profile;
    } catch (error) {
      logger.error(`Error adding allergy for patient ${patientId}:`, error);
      throw error;
    }
  }

  /**
   * Remove allergy
   * @param {string} patientId - Patient ID
   * @param {string} allergen - Allergen name
   * @returns {Promise<HealthProfile>}
   */
  async removeAllergy(patientId, allergen) {
    try {
      const profile = await HealthProfile.findOne({
        where: { patient_id: patientId },
      });

      if (!profile) {
        throw new Error('Health profile not found');
      }

      // Use model's removeAllergy method
      await profile.removeAllergy(allergen);

      // Invalidate cache
      const cacheKey = `${CACHE_KEY_PREFIX}${patientId}`;
      await redisClient.del(cacheKey);
      logger.info(`Removed allergy ${allergen} for patient ${patientId}`);

      return profile;
    } catch (error) {
      logger.error(`Error removing allergy for patient ${patientId}:`, error);
      throw error;
    }
  }

  /**
   * Update vitals
   * @param {string} patientId - Patient ID
   * @param {Object} vitals - Vitals data (height, weight, bloodType)
   * @returns {Promise<HealthProfile>}
   */
  async updateVitals(patientId, vitals) {
    try {
      const profile = await HealthProfile.findOne({
        where: { patient_id: patientId },
      });

      if (!profile) {
        throw new Error('Health profile not found');
      }

      const updateData = {};
      if (vitals.height !== undefined) updateData.height = vitals.height;
      if (vitals.weight !== undefined) updateData.weight = vitals.weight;
      if (vitals.bloodType !== undefined) updateData.blood_type = vitals.bloodType;

      await profile.update(updateData);

      // Invalidate cache
      const cacheKey = `${CACHE_KEY_PREFIX}${patientId}`;
      await redisClient.del(cacheKey);
      logger.info(`Updated vitals for patient ${patientId}`);

      return profile;
    } catch (error) {
      logger.error(`Error updating vitals for patient ${patientId}:`, error);
      throw error;
    }
  }
}

export default new HealthProfileService();
