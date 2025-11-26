import Joi from 'joi';
import * as appointmentService from '../services/appointmentService.js';
import logger from '../config/logger.js';

/**
 * Joi validation schemas
 */
const createAppointmentSchema = Joi.object({
  doctorId: Joi.string().uuid().required(),
  appointmentType: Joi.string().valid('telehealth', 'in_person', 'phone').required(),
  scheduledStart: Joi.date().iso().greater('now').required(),
  scheduledEnd: Joi.date().iso().greater(Joi.ref('scheduledStart')).required(),
  reasonForVisit: Joi.string().max(500).required(),
  chiefComplaint: Joi.string().max(500).optional().allow('', null),
  urgent: Joi.boolean().default(false)
});

const updateAppointmentSchema = Joi.object({
  scheduledStart: Joi.date().iso().optional(),
  scheduledEnd: Joi.date().iso().optional(),
  status: Joi.string().valid('scheduled', 'confirmed', 'in_progress', 'completed', 'cancelled', 'no_show').optional(),
  notes: Joi.string().max(1000).optional().allow('', null),
  actualStart: Joi.date().iso().optional(),
  actualEnd: Joi.date().iso().optional()
}).min(1);

const cancelAppointmentSchema = Joi.object({
  cancellationReason: Joi.string().max(500).required()
});

const getAppointmentsQuerySchema = Joi.object({
  status: Joi.string().valid('scheduled', 'confirmed', 'in_progress', 'completed', 'cancelled', 'no_show').optional(),
  startDate: Joi.date().iso().optional(),
  endDate: Joi.date().iso().optional(),
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(100).default(20),
  sortBy: Joi.string().valid('scheduled_start', 'created_at', 'status').default('scheduled_start'),
  sortOrder: Joi.string().valid('ASC', 'DESC').default('DESC')
});

const availabilityQuerySchema = Joi.object({
  date: Joi.date().iso().required(),
  duration: Joi.number().integer().min(15).max(120).default(30)
});

/**
 * Create new appointment
 */
export const createAppointment = async (req, res) => {
  try {
    // Validate request body
    const { error, value } = createAppointmentSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        success: false,
        message: 'Invalid appointment data',
        errors: error.details.map(detail => detail.message)
      });
    }

    // Extract patient ID from authenticated user
    const patientId = req.user.patientId;
    
    if (!patientId) {
      return res.status(400).json({
        success: false,
        message: 'Patient profile not found for this user'
      });
    }
    
    // Create appointment
    const appointment = await appointmentService.createAppointment(
      patientId,
      value.doctorId,
      {
        appointment_type: value.appointmentType,
        scheduled_start: value.scheduledStart,
        scheduled_end: value.scheduledEnd,
        reason_for_visit: value.reasonForVisit,
        chief_complaint: value.chiefComplaint,
        urgent: value.urgent
      }
    );

    logger.info(`Appointment created successfully: ${appointment.id}`);

    return res.status(201).json({
      success: true,
      message: 'Appointment created successfully',
      data: appointment
    });
  } catch (error) {
    logger.error('Error in createAppointment controller:', error);
    
    if (error.message.includes('not available') || error.message.includes('conflict')) {
      return res.status(409).json({
        success: false,
        message: error.message
      });
    }
    
    return res.status(500).json({
      success: false,
      message: 'Failed to create appointment',
      error: error.message
    });
  }
};

/**
 * Get appointment by ID
 */
export const getAppointmentById = async (req, res) => {
  try {
    const { id } = req.params;

    // Validate UUID
    const uuidSchema = Joi.string().uuid().required();
    const { error } = uuidSchema.validate(id);
    if (error) {
      return res.status(400).json({
        success: false,
        message: 'Invalid appointment ID format'
      });
    }

    const appointment = await appointmentService.getAppointmentById(
      id,
      req.user.id,
      req.user.role
    );

    if (!appointment) {
      return res.status(404).json({
        success: false,
        message: 'Appointment not found or access denied'
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Appointment retrieved successfully',
      data: appointment
    });
  } catch (error) {
    logger.error('Error in getAppointmentById controller:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to retrieve appointment',
      error: error.message
    });
  }
};

/**
 * Get all appointments for authenticated patient
 */
export const getMyAppointments = async (req, res) => {
  try {
    // Validate query parameters
    const { error, value } = getAppointmentsQuerySchema.validate(req.query);
    if (error) {
      return res.status(400).json({
        success: false,
        message: 'Invalid query parameters',
        errors: error.details.map(detail => detail.message)
      });
    }

    const patientId = req.user.patientId;
    
    if (!patientId) {
      return res.status(400).json({
        success: false,
        message: 'Patient profile not found for this user'
      });
    }
    
    const filters = {
      status: value.status,
      startDate: value.startDate,
      endDate: value.endDate,
      page: value.page,
      limit: value.limit,
      sortBy: value.sortBy,
      sortOrder: value.sortOrder
    };

    const result = await appointmentService.getPatientAppointments(patientId, filters);

    logger.info(`Retrieved ${result.appointments.length} appointments for patient ${patientId}`);

    return res.status(200).json({
      success: true,
      message: 'Appointments retrieved successfully',
      data: result
    });
  } catch (error) {
    logger.error('Error in getMyAppointments controller:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to retrieve appointments',
      error: error.message
    });
  }
};

/**
 * Update appointment
 */
export const updateAppointment = async (req, res) => {
  try {
    const { id } = req.params;

    // Validate UUID
    const uuidSchema = Joi.string().uuid().required();
    const { error: idError } = uuidSchema.validate(id);
    if (idError) {
      return res.status(400).json({
        success: false,
        message: 'Invalid appointment ID format'
      });
    }

    // Validate request body
    const { error, value } = updateAppointmentSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        success: false,
        message: 'Invalid update data',
        errors: error.details.map(detail => detail.message)
      });
    }

    // Convert camelCase to snake_case for database
    const updateData = {};
    if (value.scheduledStart) updateData.scheduled_start = value.scheduledStart;
    if (value.scheduledEnd) updateData.scheduled_end = value.scheduledEnd;
    if (value.status) updateData.status = value.status;
    if (value.notes) updateData.notes = value.notes;
    if (value.actualStart) updateData.actual_start = value.actualStart;
    if (value.actualEnd) updateData.actual_end = value.actualEnd;

    const appointment = await appointmentService.updateAppointment(
      id,
      req.user.id,
      req.user.role,
      updateData
    );

    logger.info(`Appointment updated successfully: ${id}`);

    return res.status(200).json({
      success: true,
      message: 'Appointment updated successfully',
      data: appointment
    });
  } catch (error) {
    logger.error('Error in updateAppointment controller:', error);
    
    if (error.message === 'Access denied') {
      return res.status(403).json({
        success: false,
        message: 'You do not have permission to update this appointment'
      });
    }
    
    if (error.message.includes('not available') || error.message.includes('Cannot update')) {
      return res.status(409).json({
        success: false,
        message: error.message
      });
    }
    
    return res.status(500).json({
      success: false,
      message: 'Failed to update appointment',
      error: error.message
    });
  }
};

/**
 * Cancel appointment
 */
export const cancelAppointment = async (req, res) => {
  try {
    const { id } = req.params;

    // Validate UUID
    const uuidSchema = Joi.string().uuid().required();
    const { error: idError } = uuidSchema.validate(id);
    if (idError) {
      return res.status(400).json({
        success: false,
        message: 'Invalid appointment ID format'
      });
    }

    // Validate request body
    const { error, value } = cancelAppointmentSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        success: false,
        message: 'Cancellation reason is required',
        errors: error.details.map(detail => detail.message)
      });
    }

    await appointmentService.cancelAppointment(
      id,
      req.user.id,
      req.user.role,
      value.cancellationReason
    );

    logger.info(`Appointment cancelled successfully: ${id}`);

    return res.status(200).json({
      success: true,
      message: 'Appointment cancelled successfully'
    });
  } catch (error) {
    logger.error('Error in cancelAppointment controller:', error);
    
    if (error.message === 'Access denied') {
      return res.status(403).json({
        success: false,
        message: 'You do not have permission to cancel this appointment'
      });
    }
    
    if (error.message === 'Appointment not found') {
      return res.status(404).json({
        success: false,
        message: 'Appointment not found'
      });
    }
    
    if (error.message.includes('cannot be cancelled')) {
      return res.status(400).json({
        success: false,
        message: error.message
      });
    }
    
    return res.status(500).json({
      success: false,
      message: 'Failed to cancel appointment',
      error: error.message
    });
  }
};

/**
 * Get doctor availability
 */
export const getDoctorAvailability = async (req, res) => {
  try {
    const { doctorId } = req.params;

    // Validate doctor ID
    const uuidSchema = Joi.string().uuid().required();
    const { error: idError } = uuidSchema.validate(doctorId);
    if (idError) {
      return res.status(400).json({
        success: false,
        message: 'Invalid doctor ID format'
      });
    }

    // Validate query parameters
    const { error, value } = availabilityQuerySchema.validate(req.query);
    if (error) {
      return res.status(400).json({
        success: false,
        message: 'Invalid query parameters',
        errors: error.details.map(detail => detail.message)
      });
    }

    const timeSlots = await appointmentService.getAvailableTimeSlots(
      doctorId,
      value.date,
      value.duration
    );

    logger.info(`Retrieved ${timeSlots.length} time slots for doctor ${doctorId}`);

    return res.status(200).json({
      success: true,
      message: 'Time slots retrieved successfully',
      data: timeSlots
    });
  } catch (error) {
    logger.error('Error in getDoctorAvailability controller:', error);
    
    if (error.message === 'Doctor not found') {
      return res.status(404).json({
        success: false,
        message: 'Doctor not found'
      });
    }
    
    return res.status(500).json({
      success: false,
      message: 'Failed to retrieve availability',
      error: error.message
    });
  }
};
