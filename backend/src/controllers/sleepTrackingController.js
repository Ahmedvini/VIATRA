import { SleepSession, SleepInterruption } from '../models/index.js';
import logger from '../config/logger.js';
import { Op } from 'sequelize';

/**
 * Start a new sleep session
 */
export const startSleepSession = async (req, res) => {
  try {
    const patientId = req.user.id;
    const { start_time, notes, environment_factors } = req.body;

    // Check if there's already an active or paused session
    const existingSession = await SleepSession.findOne({
      where: {
        patient_id: patientId,
        status: {
          [Op.in]: ['active', 'paused']
        }
      }
    });

    if (existingSession) {
      return res.status(400).json({
        success: false,
        message: 'You already have an active sleep session. Please complete it first.',
        data: existingSession
      });
    }

    // Create new sleep session
    const sleepSession = await SleepSession.create({
      patient_id: patientId,
      start_time: start_time || new Date(),
      notes,
      environment_factors,
      status: 'active'
    });

    logger.info(`Sleep session started: ${sleepSession.id} for patient ${patientId}`);

    res.status(201).json({
      success: true,
      message: 'Sleep session started successfully',
      data: sleepSession
    });
  } catch (error) {
    logger.error('Error starting sleep session:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to start sleep session',
      error: error.message
    });
  }
};

/**
 * Pause sleep session (wake up interruption)
 */
export const pauseSleepSession = async (req, res) => {
  try {
    const { sessionId } = req.params;
    const { reason, notes } = req.body;
    const patientId = req.user.id;

    const session = await SleepSession.findOne({
      where: {
        id: sessionId,
        patient_id: patientId
      }
    });

    if (!session) {
      return res.status(404).json({
        success: false,
        message: 'Sleep session not found'
      });
    }

    if (session.status !== 'active') {
      return res.status(400).json({
        success: false,
        message: 'Can only pause an active sleep session'
      });
    }

    // Create interruption record
    const interruption = await SleepInterruption.create({
      sleep_session_id: sessionId,
      pause_time: new Date(),
      reason,
      notes
    });

    // Update session status
    session.status = 'paused';
    session.wake_up_count = (session.wake_up_count || 0) + 1;
    await session.save();

    logger.info(`Sleep session paused: ${sessionId}`);

    res.json({
      success: true,
      message: 'Sleep session paused',
      data: {
        session,
        interruption
      }
    });
  } catch (error) {
    logger.error('Error pausing sleep session:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to pause sleep session',
      error: error.message
    });
  }
};

/**
 * Resume sleep session (after wake up)
 */
export const resumeSleepSession = async (req, res) => {
  try {
    const { sessionId } = req.params;
    const patientId = req.user.id;

    const session = await SleepSession.findOne({
      where: {
        id: sessionId,
        patient_id: patientId
      }
    });

    if (!session) {
      return res.status(404).json({
        success: false,
        message: 'Sleep session not found'
      });
    }

    if (session.status !== 'paused') {
      return res.status(400).json({
        success: false,
        message: 'Can only resume a paused sleep session'
      });
    }

    // Find the most recent interruption without resume_time
    const interruption = await SleepInterruption.findOne({
      where: {
        sleep_session_id: sessionId,
        resume_time: null
      },
      order: [['pause_time', 'DESC']]
    });

    if (interruption) {
      const resumeTime = new Date();
      interruption.resume_time = resumeTime;
      interruption.duration_minutes = Math.floor(
        (resumeTime - new Date(interruption.pause_time)) / (1000 * 60)
      );
      await interruption.save();
    }

    // Update session status
    session.status = 'active';
    await session.save();

    logger.info(`Sleep session resumed: ${sessionId}`);

    res.json({
      success: true,
      message: 'Sleep session resumed',
      data: {
        session,
        interruption
      }
    });
  } catch (error) {
    logger.error('Error resuming sleep session:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to resume sleep session',
      error: error.message
    });
  }
};

/**
 * End sleep session
 */
export const endSleepSession = async (req, res) => {
  try {
    const { sessionId } = req.params;
    const { quality_rating, notes } = req.body;
    const patientId = req.user.id;

    const session = await SleepSession.findOne({
      where: {
        id: sessionId,
        patient_id: patientId
      },
      include: [{
        model: SleepInterruption,
        as: 'interruptions'
      }]
    });

    if (!session) {
      return res.status(404).json({
        success: false,
        message: 'Sleep session not found'
      });
    }

    if (session.status === 'completed') {
      return res.status(400).json({
        success: false,
        message: 'Sleep session already completed'
      });
    }

    // If session is paused, resume the last interruption first
    if (session.status === 'paused') {
      const interruption = await SleepInterruption.findOne({
        where: {
          sleep_session_id: sessionId,
          resume_time: null
        },
        order: [['pause_time', 'DESC']]
      });

      if (interruption) {
        const resumeTime = new Date();
        interruption.resume_time = resumeTime;
        interruption.duration_minutes = Math.floor(
          (resumeTime - new Date(interruption.pause_time)) / (1000 * 60)
        );
        await interruption.save();
      }
    }

    // Calculate total duration
    const endTime = new Date();
    const totalMinutes = Math.floor(
      (endTime - new Date(session.start_time)) / (1000 * 60)
    );

    // Update session
    session.end_time = endTime;
    session.total_duration_minutes = totalMinutes;
    session.status = 'completed';
    
    if (quality_rating) {
      session.quality_rating = quality_rating;
    }
    
    if (notes) {
      session.notes = notes;
    }

    await session.save();

    logger.info(`Sleep session completed: ${sessionId}`);

    res.json({
      success: true,
      message: 'Sleep session completed successfully',
      data: session
    });
  } catch (error) {
    logger.error('Error ending sleep session:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to end sleep session',
      error: error.message
    });
  }
};

/**
 * Get all sleep sessions for user
 */
export const getSleepSessions = async (req, res) => {
  try {
    const patientId = req.user.id;
    const { start_date, end_date, status, limit = 50, offset = 0 } = req.query;

    const whereClause = {
      patient_id: patientId
    };

    if (start_date) {
      whereClause.start_time = {
        ...whereClause.start_time,
        [Op.gte]: new Date(start_date)
      };
    }

    if (end_date) {
      whereClause.start_time = {
        ...whereClause.start_time,
        [Op.lte]: new Date(end_date)
      };
    }

    if (status) {
      whereClause.status = status;
    }

    const sessions = await SleepSession.findAll({
      where: whereClause,
      include: [{
        model: SleepInterruption,
        as: 'interruptions'
      }],
      order: [['start_time', 'DESC']],
      limit: parseInt(limit),
      offset: parseInt(offset)
    });

    res.json({
      success: true,
      data: sessions,
      pagination: {
        limit: parseInt(limit),
        offset: parseInt(offset),
        total: sessions.length
      }
    });
  } catch (error) {
    logger.error('Error fetching sleep sessions:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch sleep sessions',
      error: error.message
    });
  }
};

/**
 * Get current active session
 */
export const getActiveSession = async (req, res) => {
  try {
    const patientId = req.user.id;

    const session = await SleepSession.findOne({
      where: {
        patient_id: patientId,
        status: {
          [Op.in]: ['active', 'paused']
        }
      },
      include: [{
        model: SleepInterruption,
        as: 'interruptions'
      }],
      order: [['start_time', 'DESC']]
    });

    res.json({
      success: true,
      data: session
    });
  } catch (error) {
    logger.error('Error fetching active session:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch active session',
      error: error.message
    });
  }
};

/**
 * Get sleep analytics/summary
 */
export const getSleepAnalytics = async (req, res) => {
  try {
    const patientId = req.user.id;
    const { days = 7 } = req.query;

    const startDate = new Date();
    startDate.setDate(startDate.getDate() - parseInt(days));

    const sessions = await SleepSession.findAll({
      where: {
        patient_id: patientId,
        status: 'completed',
        start_time: {
          [Op.gte]: startDate
        }
      },
      include: [{
        model: SleepInterruption,
        as: 'interruptions'
      }]
    });

    // Calculate analytics
    const analytics = {
      totalSessions: sessions.length,
      averageDuration: 0,
      averageQuality: 0,
      totalWakeUps: 0,
      averageWakeUps: 0,
      sleepEfficiency: 0,
      dailyAverages: []
    };

    if (sessions.length > 0) {
      const totalDuration = sessions.reduce((sum, s) => sum + (s.total_duration_minutes || 0), 0);
      const totalQuality = sessions.reduce((sum, s) => sum + (s.quality_rating || 0), 0);
      const totalWakeUps = sessions.reduce((sum, s) => sum + (s.wake_up_count || 0), 0);

      analytics.averageDuration = Math.round(totalDuration / sessions.length);
      analytics.averageQuality = (totalQuality / sessions.length).toFixed(1);
      analytics.totalWakeUps = totalWakeUps;
      analytics.averageWakeUps = (totalWakeUps / sessions.length).toFixed(1);

      // Calculate sleep efficiency
      let totalEfficiency = 0;
      let efficiencyCount = 0;

      sessions.forEach(session => {
        const efficiency = session.calculateSleepEfficiency();
        if (efficiency) {
          totalEfficiency += efficiency;
          efficiencyCount++;
        }
      });

      if (efficiencyCount > 0) {
        analytics.sleepEfficiency = Math.round(totalEfficiency / efficiencyCount);
      }
    }

    res.json({
      success: true,
      data: analytics,
      sessions
    });
  } catch (error) {
    logger.error('Error fetching sleep analytics:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch sleep analytics',
      error: error.message
    });
  }
};

/**
 * Get single sleep session by ID
 */
export const getSleepSessionById = async (req, res) => {
  try {
    const { sessionId } = req.params;
    const patientId = req.user.id;

    const session = await SleepSession.findOne({
      where: {
        id: sessionId,
        patient_id: patientId
      },
      include: [{
        model: SleepInterruption,
        as: 'interruptions',
        order: [['pause_time', 'ASC']]
      }]
    });

    if (!session) {
      return res.status(404).json({
        success: false,
        message: 'Sleep session not found'
      });
    }

    res.json({
      success: true,
      data: session
    });
  } catch (error) {
    logger.error('Error fetching sleep session:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch sleep session',
      error: error.message
    });
  }
};

/**
 * Record a sleep interruption (wake-up)
 */
export const recordInterruption = async (req, res) => {
  try {
    const { sessionId } = req.params;
    const { reason, notes } = req.body;
    const patientId = req.user.id;

    const session = await SleepSession.findOne({
      where: {
        id: sessionId,
        patient_id: patientId
      }
    });

    if (!session) {
      return res.status(404).json({
        success: false,
        message: 'Sleep session not found'
      });
    }

    if (session.status === 'completed') {
      return res.status(400).json({
        success: false,
        message: 'Cannot add interruption to completed session'
      });
    }

    // Create interruption
    const interruption = await SleepInterruption.create({
      sleep_session_id: sessionId,
      pause_time: new Date(),
      reason,
      notes
    });

    // Increment wake up count
    session.wake_up_count += 1;
    await session.save();

    logger.info(`Sleep interruption recorded: ${interruption.id} for session ${sessionId}`);

    res.status(201).json({
      success: true,
      message: 'Sleep interruption recorded',
      data: interruption
    });
  } catch (error) {
    logger.error('Error recording sleep interruption:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to record sleep interruption',
      error: error.message
    });
  }
};

/**
 * Delete sleep session
 */
export const deleteSleepSession = async (req, res) => {
  try {
    const { sessionId } = req.params;
    const patientId = req.user.id;

    const session = await SleepSession.findOne({
      where: {
        id: sessionId,
        patient_id: patientId
      }
    });

    if (!session) {
      return res.status(404).json({
        success: false,
        message: 'Sleep session not found'
      });
    }

    // Delete associated interruptions first (cascade should handle this, but being explicit)
    await SleepInterruption.destroy({
      where: {
        sleep_session_id: sessionId
      }
    });

    // Delete the session
    await session.destroy();

    logger.info(`Sleep session deleted: ${sessionId}`);

    res.json({
      success: true,
      message: 'Sleep session deleted successfully'
    });
  } catch (error) {
    logger.error('Error deleting sleep session:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete sleep session',
      error: error.message
    });
  }
};
