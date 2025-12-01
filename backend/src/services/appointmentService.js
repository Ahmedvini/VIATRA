import { Op } from 'sequelize';
import { Appointment, Doctor, Patient, User } from '../models/index.js';
import redisClient from '../config/redis.js';
import logger from '../config/logger.js';
import { getSequelize } from '../config/database.js';

/**
 * Generate Redis cache key for appointments
 */
const generateAppointmentCacheKey = (appointmentId) => {
  return `appointment:${appointmentId}`;
};

const generatePatientAppointmentsCacheKey = (patientId, filters) => {
  const filterString = JSON.stringify(filters);
  return `patient_appointments:${patientId}:${filterString}`;
};

/**
 * Invalidate appointment-related cache
 */
export const invalidateAppointmentCache = async (appointmentId, patientId, doctorId) => {
  try {
    const keys = [];
    
    // Appointment detail cache
    if (appointmentId) {
      keys.push(generateAppointmentCacheKey(appointmentId));
    }
    
    // Patient appointments list cache (clear all variations)
    if (patientId) {
      const patternKey = `patient_appointments:${patientId}:*`;
      const patientKeys = await redisClient.keys(patternKey);
      keys.push(...patientKeys);
    }
    
    // Doctor appointments list cache (for future Phase 2)
    if (doctorId) {
      const patternKey = `doctor_appointments:${doctorId}:*`;
      const doctorKeys = await redisClient.keys(patternKey);
      keys.push(...doctorKeys);
    }
    
    // Delete all keys
    if (keys.length > 0) {
      await Promise.all(keys.map(key => redisClient.del(key)));
      logger.info(`Invalidated ${keys.length} appointment cache keys`);
    }
  } catch (error) {
    logger.error('Error invalidating appointment cache:', error);
  }
};

/**
 * Check if doctor is available at given time
 */
export const checkDoctorAvailability = async (doctorId, startTime, endTime, excludeAppointmentId = null) => {
  try {
    // Fetch doctor with working hours
    const doctor = await Doctor.findByPk(doctorId);
    if (!doctor) {
      return { available: false, reason: 'Doctor not found' };
    }

    // Check working hours
    const startDateTime = new Date(startTime);
    const endDateTime = new Date(endTime);
    const dayOfWeek = startDateTime.toLocaleDateString('en-US', { weekday: 'long' }).toLowerCase();
    const requestedStartTime = startDateTime.toTimeString().slice(0, 5); // HH:mm format
    const requestedEndTime = endDateTime.toTimeString().slice(0, 5); // HH:mm format

    // Check if working hours exist for this day
    if (!doctor.working_hours || !doctor.working_hours[dayOfWeek]) {
      return { available: false, reason: 'Doctor does not have working hours set for this day' };
    }

    const daySchedule = doctor.working_hours[dayOfWeek];
    
    // Check if doctor is available on this day (single object with start, end, available)
    if (!daySchedule.available || !daySchedule.start || !daySchedule.end) {
      return { available: false, reason: 'Doctor not available on this day' };
    }

    // Check if requested time falls within working hours
    if (requestedStartTime < daySchedule.start || requestedEndTime > daySchedule.end) {
      return { 
        available: false, 
        reason: `Requested time outside working hours (${daySchedule.start} - ${daySchedule.end})` 
      };
    }

    // Check for conflicting appointments
    const whereClause = {
      doctor_id: doctorId,
      status: {
        [Op.notIn]: ['cancelled', 'no_show']
      },
      [Op.or]: [
        // New appointment starts during existing appointment
        {
          scheduled_start: { [Op.lte]: startTime },
          scheduled_end: { [Op.gt]: startTime }
        },
        // New appointment ends during existing appointment
        {
          scheduled_start: { [Op.lt]: endTime },
          scheduled_end: { [Op.gte]: endTime }
        },
        // New appointment contains existing appointment
        {
          scheduled_start: { [Op.gte]: startTime },
          scheduled_end: { [Op.lte]: endTime }
        }
      ]
    };

    if (excludeAppointmentId) {
      whereClause.id = { [Op.ne]: excludeAppointmentId };
    }

    const conflicts = await Appointment.findAll({
      where: whereClause,
      attributes: ['id', 'scheduled_start', 'scheduled_end', 'status']
    });

    if (conflicts.length > 0) {
      return { 
        available: false, 
        reason: 'Time slot has scheduling conflicts',
        conflicts 
      };
    }

    return { available: true };
  } catch (error) {
    logger.error('Error checking doctor availability:', error);
    throw error;
  }
};

/**
 * Generate available time slots for a specific date
 */
export const getAvailableTimeSlots = async (doctorId, date, duration = 30) => {
  try {
    const doctor = await Doctor.findByPk(doctorId);
    if (!doctor) {
      throw new Error('Doctor not found');
    }

    const requestedDate = new Date(date);
    const dayOfWeek = requestedDate.toLocaleDateString('en-US', { weekday: 'long' }).toLowerCase();
    
    // Check if working hours exist for this day
    if (!doctor.working_hours || !doctor.working_hours[dayOfWeek]) {
      return [];
    }

    const shift = doctor.working_hours[dayOfWeek];
    
    // Check if doctor is available on this day (single object with start, end, available)
    if (!shift.available || !shift.start || !shift.end) {
      return [];
    }

    const slots = [];
    
    // Parse start and end times from the single shift object
    const [startHour, startMin] = shift.start.split(':').map(Number);
    const [endHour, endMin] = shift.end.split(':').map(Number);
    
    let currentTime = new Date(requestedDate);
    currentTime.setHours(startHour, startMin, 0, 0);
    
    const shiftEnd = new Date(requestedDate);
    shiftEnd.setHours(endHour, endMin, 0, 0);
    
    // Generate slots from shift start to end at the requested duration
    while (currentTime < shiftEnd) {
      const slotEnd = new Date(currentTime.getTime() + duration * 60000);
      
      if (slotEnd <= shiftEnd) {
        // Check availability for this slot
        const availabilityCheck = await checkDoctorAvailability(
          doctorId,
          currentTime.toISOString(),
          slotEnd.toISOString()
        );
        
        slots.push({
          start: currentTime.toISOString(),
          end: slotEnd.toISOString(),
          available: availabilityCheck.available
        });
      }
      
      currentTime = new Date(currentTime.getTime() + duration * 60000);
    }

    return slots;
  } catch (error) {
    logger.error('Error generating time slots:', error);
    throw error;
  }
};

/**
 * Create new appointment
 */
export const createAppointment = async (patientId, doctorId, appointmentData) => {
  const transaction = await getSequelize().transaction();
  
  try {
    // Validate doctor exists
    const doctor = await Doctor.findByPk(doctorId);
    if (!doctor) {
      throw new Error('Doctor not found');
    }

    // Check availability and conflicts
    const availabilityCheck = await checkDoctorAvailability(
      doctorId,
      appointmentData.scheduled_start,
      appointmentData.scheduled_end
    );

    if (!availabilityCheck.available) {
      throw new Error(availabilityCheck.reason || 'Time slot not available');
    }

    // Create appointment
    const appointment = await Appointment.create({
      patient_id: patientId,
      doctor_id: doctorId,
      appointment_type: appointmentData.appointment_type,
      scheduled_start: appointmentData.scheduled_start,
      scheduled_end: appointmentData.scheduled_end,
      reason_for_visit: appointmentData.reason_for_visit,
      chief_complaint: appointmentData.chief_complaint,
      urgent: appointmentData.urgent || false,
      status: 'scheduled'
    }, { transaction });

    await transaction.commit();

    // Invalidate caches
    await invalidateAppointmentCache(appointment.id, patientId, doctorId);

    // Fetch with associations
    const createdAppointment = await Appointment.findByPk(appointment.id, {
      include: [
        {
          model: Doctor,
          as: 'doctor',
          include: [{
            model: User,
            as: 'user',
            attributes: ['id', 'first_name', 'last_name', 'email', 'phone', 'profile_image']
          }]
        },
        {
          model: Patient,
          as: 'patient',
          include: [{
            model: User,
            as: 'user',
            attributes: ['id', 'first_name', 'last_name', 'email', 'phone']
          }]
        }
      ]
    });

    // Return plain object with associations for consistent serialization
    const plainAppointment = createdAppointment.toJSON();

    logger.info(`Appointment created: ${appointment.id} for patient ${patientId}`);
    return plainAppointment;
  } catch (error) {
    await transaction.rollback();
    logger.error('Error creating appointment:', error);
    throw error;
  }
};

/**
 * Get appointment by ID
 */
export const getAppointmentById = async (appointmentId, userId, userRole) => {
  try {
    // Check cache
    const cacheKey = generateAppointmentCacheKey(appointmentId);
    const cachedData = await redisClient.get(cacheKey);
    
    if (cachedData) {
      const appointment = JSON.parse(cachedData);
      
      // Verify access
      if (userRole === 'patient' && appointment.patient_id !== userId) {
        return null;
      }
      if (userRole === 'doctor' && appointment.doctor_id !== userId) {
        return null;
      }
      
      logger.info('Appointment retrieved from cache');
      return appointment;
    }

    // Fetch from database
    const appointment = await Appointment.findByPk(appointmentId, {
      include: [
        {
          model: Doctor,
          as: 'doctor',
          include: [{
            model: User,
            as: 'user',
            attributes: ['id', 'first_name', 'last_name', 'email', 'phone', 'profile_image']
          }]
        },
        {
          model: Patient,
          as: 'patient',
          include: [{
            model: User,
            as: 'user',
            attributes: ['id', 'first_name', 'last_name', 'email', 'phone']
          }]
        }
      ]
    });

    if (!appointment) {
      return null;
    }

    // Verify access
    if (userRole === 'patient' && appointment.patient_id !== userId) {
      return null;
    }
    if (userRole === 'doctor' && appointment.doctor_id !== userId) {
      return null;
    }

    // Convert to plain object for consistent serialization
    const plainAppointment = appointment.toJSON();

    // Cache result as plain object
    await redisClient.setEx(cacheKey, 300, JSON.stringify(plainAppointment)); // 5 min TTL

    return plainAppointment;
  } catch (error) {
    logger.error('Error fetching appointment:', error);
    throw error;
  }
};

/**
 * Get patient's appointments
 */
export const getPatientAppointments = async (patientId, filters = {}) => {
  try {
    // Check cache
    const cacheKey = generatePatientAppointmentsCacheKey(patientId, filters);
    const cachedData = await redisClient.get(cacheKey);
    
    if (cachedData) {
      logger.info('Patient appointments retrieved from cache');
      return JSON.parse(cachedData);
    }

    // Build query
    const whereClause = { patient_id: patientId };

    if (filters.status) {
      whereClause.status = filters.status;
    }

    if (filters.startDate || filters.endDate) {
      whereClause.scheduled_start = {};
      if (filters.startDate) {
        whereClause.scheduled_start[Op.gte] = filters.startDate;
      }
      if (filters.endDate) {
        whereClause.scheduled_start[Op.lte] = filters.endDate;
      }
    }

    const page = filters.page || 1;
    const limit = filters.limit || 20;
    const offset = (page - 1) * limit;
    const sortBy = filters.sortBy || 'scheduled_start';
    const sortOrder = filters.sortOrder || 'DESC';

    const { count, rows: appointments } = await Appointment.findAndCountAll({
      where: whereClause,
      include: [
        {
          model: Doctor,
          as: 'doctor',
          include: [{
            model: User,
            as: 'user',
            attributes: ['id', 'first_name', 'last_name', 'email', 'phone', 'profile_image']
          }]
        }
      ],
      order: [[sortBy, sortOrder]],
      limit: parseInt(limit),
      offset: offset,
      distinct: true
    });

    // Convert appointments to plain objects for consistent serialization
    const plainAppointments = appointments.map(apt => apt.toJSON());

    const result = {
      appointments: plainAppointments,
      pagination: {
        total: count,
        page: parseInt(page),
        limit: parseInt(limit),
        totalPages: Math.ceil(count / limit)
      }
    };

    // Cache result
    await redisClient.setEx(cacheKey, 300, JSON.stringify(result)); // 5 min TTL

    return result;
  } catch (error) {
    logger.error('Error fetching patient appointments:', error);
    throw error;
  }
};

/**
 * Update appointment
 */
export const updateAppointment = async (appointmentId, userId, userRole, updateData) => {
  const transaction = await getSequelize().transaction();
  
  try {
    // Fetch appointment
    const appointment = await Appointment.findByPk(appointmentId);
    if (!appointment) {
      throw new Error('Appointment not found');
    }

    // Verify access
    if (userRole === 'patient' && appointment.patient_id !== userId) {
      throw new Error('Access denied');
    }
    if (userRole === 'doctor' && appointment.doctor_id !== userId) {
      throw new Error('Access denied');
    }

    // Validate status transitions
    if (appointment.status === 'completed' || appointment.status === 'cancelled') {
      throw new Error('Cannot update completed or cancelled appointments');
    }

    // If rescheduling, check availability
    if (updateData.scheduled_start || updateData.scheduled_end) {
      const newStart = updateData.scheduled_start || appointment.scheduled_start;
      const newEnd = updateData.scheduled_end || appointment.scheduled_end;
      
      const availabilityCheck = await checkDoctorAvailability(
        appointment.doctor_id,
        newStart,
        newEnd,
        appointmentId
      );

      if (!availabilityCheck.available) {
        throw new Error(availabilityCheck.reason || 'New time slot not available');
      }
    }

    // Update appointment
    await appointment.update(updateData, { transaction });
    await transaction.commit();

    // Invalidate caches
    await invalidateAppointmentCache(appointmentId, appointment.patient_id, appointment.doctor_id);

    // Fetch updated with associations
    const updatedAppointment = await Appointment.findByPk(appointmentId, {
      include: [
        {
          model: Doctor,
          as: 'doctor',
          include: [{
            model: User,
            as: 'user',
            attributes: ['id', 'first_name', 'last_name', 'email', 'phone', 'profile_image']
          }]
        },
        {
          model: Patient,
          as: 'patient',
          include: [{
            model: User,
            as: 'user',
            attributes: ['id', 'first_name', 'last_name', 'email', 'phone']
          }]
        }
      ]
    });

    // Return plain object for consistent serialization
    const plainAppointment = updatedAppointment.toJSON();

    logger.info(`Appointment updated: ${appointmentId}`);
    return plainAppointment;
  } catch (error) {
    await transaction.rollback();
    logger.error('Error updating appointment:', error);
    throw error;
  }
};

/**
 * Cancel appointment
 */
export const cancelAppointment = async (appointmentId, userId, userRole, reason) => {
  const transaction = await getSequelize().transaction();
  
  try {
    // Fetch appointment
    const appointment = await Appointment.findByPk(appointmentId);
    if (!appointment) {
      throw new Error('Appointment not found');
    }

    // Verify access
    if (userRole === 'patient' && appointment.patient_id !== userId) {
      throw new Error('Access denied');
    }
    if (userRole === 'doctor' && appointment.doctor_id !== userId) {
      throw new Error('Access denied');
    }

    // Check if can be cancelled
    if (!appointment.canBeCancelled()) {
      throw new Error('Appointment cannot be cancelled (less than 2 hours before scheduled time or already completed/cancelled)');
    }

    // Cancel appointment
    await appointment.update({
      status: 'cancelled',
      cancelled_by: userRole,
      cancelled_at: new Date(),
      cancellation_reason: reason
    }, { transaction });

    await transaction.commit();

    // Invalidate caches
    await invalidateAppointmentCache(appointmentId, appointment.patient_id, appointment.doctor_id);

    logger.info(`Appointment cancelled: ${appointmentId} by ${userRole}`);
    return appointment;
  } catch (error) {
    await transaction.rollback();
    logger.error('Error cancelling appointment:', error);
    throw error;
  }
};

/**
 * Get doctor's appointments with filters
 */
export const getDoctorAppointments = async (doctorId, filters = {}) => {
  try {
    // Check cache
    const cacheKey = `doctor_appointments:${doctorId}:${JSON.stringify(filters)}`;
    const cachedData = await redisClient.get(cacheKey);
    
    if (cachedData) {
      logger.info('Doctor appointments retrieved from cache');
      return JSON.parse(cachedData);
    }

    // Build query
    const whereClause = { doctor_id: doctorId };

    if (filters.status) {
      whereClause.status = filters.status;
    }

    if (filters.startDate || filters.endDate) {
      whereClause.scheduled_start = {};
      if (filters.startDate) {
        whereClause.scheduled_start[Op.gte] = filters.startDate;
      }
      if (filters.endDate) {
        whereClause.scheduled_start[Op.lte] = filters.endDate;
      }
    }

    const page = filters.page || 1;
    const limit = filters.limit || 20;
    const offset = (page - 1) * limit;
    const sortBy = filters.sortBy || 'scheduled_start';
    const sortOrder = filters.sortOrder || 'DESC';

    const { count, rows: appointments } = await Appointment.findAndCountAll({
      where: whereClause,
      include: [
        {
          model: Patient,
          as: 'patient',
          include: [{
            model: User,
            as: 'user',
            attributes: ['id', 'first_name', 'last_name', 'email', 'phone', 'profile_image']
          }]
        }
      ],
      order: [[sortBy, sortOrder]],
      limit: parseInt(limit),
      offset: offset,
      distinct: true
    });

    // Convert appointments to plain objects for consistent serialization
    const plainAppointments = appointments.map(apt => apt.toJSON());

    const result = {
      appointments: plainAppointments,
      pagination: {
        total: count,
        page: parseInt(page),
        limit: parseInt(limit),
        totalPages: Math.ceil(count / limit)
      }
    };

    // Cache result
    await redisClient.setEx(cacheKey, 300, JSON.stringify(result)); // 5 min TTL

    return result;
  } catch (error) {
    logger.error('Error fetching doctor appointments:', error);
    throw error;
  }
};

/**
 * Get doctor dashboard statistics
 */
export const getDoctorStatistics = async (doctorId) => {
  try {
    // Check cache
    const cacheKey = `doctor_stats:${doctorId}`;
    const cachedData = await redisClient.get(cacheKey);
    
    if (cachedData) {
      logger.info('Doctor statistics retrieved from cache');
      return JSON.parse(cachedData);
    }

    // Get today's date range
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    // Today's appointments count
    const todayCount = await Appointment.count({
      where: {
        doctor_id: doctorId,
        scheduled_start: {
          [Op.gte]: today,
          [Op.lt]: tomorrow
        },
        status: {
          [Op.notIn]: ['cancelled', 'no_show']
        }
      }
    });

    // Upcoming appointments count
    const now = new Date();
    const upcomingCount = await Appointment.count({
      where: {
        doctor_id: doctorId,
        scheduled_start: {
          [Op.gt]: now
        },
        status: {
          [Op.in]: ['scheduled', 'confirmed']
        }
      }
    });

    // Total unique patients count
    const totalPatients = await Appointment.count({
      where: {
        doctor_id: doctorId,
        status: 'completed'
      },
      distinct: true,
      col: 'patient_id'
    });

    // Pending requests count (scheduled but not yet confirmed)
    const pendingCount = await Appointment.count({
      where: {
        doctor_id: doctorId,
        status: 'scheduled'
      }
    });

    const stats = {
      todayCount,
      upcomingCount,
      totalPatients,
      pendingCount
    };

    // Cache result
    await redisClient.setEx(cacheKey, 300, JSON.stringify(stats)); // 5 min TTL

    logger.info(`Doctor statistics retrieved for doctor ${doctorId}`);
    return stats;
  } catch (error) {
    logger.error('Error fetching doctor statistics:', error);
    throw error;
  }
};

/**
 * Accept and confirm appointment
 */
export const acceptAppointment = async (appointmentId, doctorId) => {
  const transaction = await getSequelize().transaction();
  
  try {
    // Fetch appointment
    const appointment = await Appointment.findByPk(appointmentId);
    if (!appointment) {
      throw new Error('Appointment not found');
    }

    // Verify doctor ownership
    if (appointment.doctor_id !== doctorId) {
      throw new Error('Access denied');
    }

    // Check status is 'scheduled'
    if (appointment.status !== 'scheduled') {
      throw new Error(`Cannot accept appointment with status: ${appointment.status}. Only 'scheduled' appointments can be accepted.`);
    }

    // Update status to 'confirmed'
    await appointment.update({
      status: 'confirmed'
    }, { transaction });

    await transaction.commit();

    // Invalidate caches
    await invalidateAppointmentCache(appointmentId, appointment.patient_id, appointment.doctor_id);

    // Fetch updated appointment with associations
    const updatedAppointment = await Appointment.findByPk(appointmentId, {
      include: [
        {
          model: Doctor,
          as: 'doctor',
          include: [{
            model: User,
            as: 'user',
            attributes: ['id', 'first_name', 'last_name', 'email', 'phone', 'profile_image']
          }]
        },
        {
          model: Patient,
          as: 'patient',
          include: [{
            model: User,
            as: 'user',
            attributes: ['id', 'first_name', 'last_name', 'email', 'phone']
          }]
        }
      ]
    });

    logger.info(`Appointment accepted: ${appointmentId} by doctor ${doctorId}`);
    return updatedAppointment.toJSON();
  } catch (error) {
    await transaction.rollback();
    logger.error('Error accepting appointment:', error);
    throw error;
  }
};

/**
 * Reschedule appointment to new time
 */
export const rescheduleAppointment = async (appointmentId, doctorId, updateData) => {
  const transaction = await getSequelize().transaction();
  
  try {
    // Fetch appointment
    const appointment = await Appointment.findByPk(appointmentId);
    if (!appointment) {
      throw new Error('Appointment not found');
    }

    // Verify doctor ownership
    if (appointment.doctor_id !== doctorId) {
      throw new Error('Access denied');
    }

    // Check status allows rescheduling
    if (['cancelled', 'completed', 'no_show'].includes(appointment.status)) {
      throw new Error(`Cannot reschedule appointment with status: ${appointment.status}`);
    }

    // Check doctor availability at new time
    const availability = await checkDoctorAvailability(
      doctorId,
      updateData.scheduled_start,
      updateData.scheduled_end,
      appointmentId
    );

    if (!availability.available) {
      throw new Error(`Time slot not available: ${availability.reason}`);
    }

    // Update appointment times
    await appointment.update({
      scheduled_start: updateData.scheduled_start,
      scheduled_end: updateData.scheduled_end
    }, { transaction });

    await transaction.commit();

    // Invalidate caches
    await invalidateAppointmentCache(appointmentId, appointment.patient_id, appointment.doctor_id);

    // Fetch updated appointment with associations
    const updatedAppointment = await Appointment.findByPk(appointmentId, {
      include: [
        {
          model: Doctor,
          as: 'doctor',
          include: [{
            model: User,
            as: 'user',
            attributes: ['id', 'first_name', 'last_name', 'email', 'phone', 'profile_image']
          }]
        },
        {
          model: Patient,
          as: 'patient',
          include: [{
            model: User,
            as: 'user',
            attributes: ['id', 'first_name', 'last_name', 'email', 'phone']
          }]
        }
      ]
    });

    logger.info(`Appointment rescheduled: ${appointmentId} by doctor ${doctorId}`);
    return updatedAppointment.toJSON();
  } catch (error) {
    await transaction.rollback();
    logger.error('Error rescheduling appointment:', error);
    throw error;
  }
};
