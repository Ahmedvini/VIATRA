import { PsychologicalAssessment, Patient, SleepSession, FoodLog } from '../models/index.js';
import logger, { logError } from '../config/logger.js';
import { Op } from 'sequelize';

/**
 * AI Health Chatbot Controller
 * Provides AI-powered health insights based on user's health data
 */

// Store for chat history (in production, use a database)
const chatHistory = new Map();

// Store for user consent (in production, use a database)
const userConsents = new Map();

/**
 * Request or update data consent
 */
export const requestConsent = async (req, res) => {
  try {
    const userId = req.user.id;
    const { consent_given } = req.body;

    // Store consent (in production, save to database)
    userConsents.set(userId, {
      consent_given: consent_given,
      timestamp: new Date(),
    });

    logger.info(`User ${userId} ${consent_given ? 'granted' : 'revoked'} data consent`);

    res.status(200).json({
      success: true,
      message: consent_given ? 'Consent granted successfully' : 'Consent revoked',
      data: { consent_given },
    });
  } catch (error) {
    logError('Error in requestConsent:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update consent',
      error: error.message,
    });
  }
};

/**
 * Check if user has given consent
 */
export const checkConsent = async (req, res) => {
  try {
    const userId = req.user.id;
    const consent = userConsents.get(userId);

    res.status(200).json({
      success: true,
      data: {
        consent_given: consent?.consent_given || false,
        timestamp: consent?.timestamp || null,
      },
    });
  } catch (error) {
    logError('Error in checkConsent:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to check consent',
      error: error.message,
    });
  }
};

/**
 * Revoke data consent
 */
export const revokeConsent = async (req, res) => {
  try {
    const userId = req.user.id;
    userConsents.delete(userId);

    logger.info(`User ${userId} revoked data consent`);

    res.status(200).json({
      success: true,
      message: 'Consent revoked successfully',
    });
  } catch (error) {
    logError('Error in revokeConsent:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to revoke consent',
      error: error.message,
    });
  }
};

/**
 * Get health data summary
 */
export const getHealthSummary = async (req, res) => {
  try {
    const userId = req.user.id;

    // Check consent
    const consent = userConsents.get(userId);
    if (!consent?.consent_given) {
      return res.status(403).json({
        success: false,
        message: 'Data consent not granted',
      });
    }

    // Get patient record
    const patient = await Patient.findOne({ where: { user_id: userId } });
    if (!patient) {
      return res.status(404).json({
        success: false,
        message: 'Patient record not found',
      });
    }

    const patientId = patient.id;

    // Get recent sleep data (last 7 days)
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

    const recentSleep = await SleepSession.findAll({
      where: {
        patient_id: patientId,
        start_time: { [Op.gte]: sevenDaysAgo },
        status: 'completed',
      },
      order: [['start_time', 'DESC']],
      limit: 7,
    });

    // Get recent food logs (last 7 days)
    const recentFood = await FoodLog.findAll({
      where: {
        patient_id: patientId,
        consumed_at: { [Op.gte]: sevenDaysAgo },
      },
      order: [['consumed_at', 'DESC']],
      limit: 20,
    });

    // Get latest PHQ-9 assessment
    const latestPHQ9 = await PsychologicalAssessment.findOne({
      where: {
        patient_id: patientId,
        assessment_type: 'PHQ9',
      },
      order: [['assessment_date', 'DESC']],
    });

    res.status(200).json({
      success: true,
      data: {
        recent_sleep: recentSleep,
        recent_food: recentFood,
        latest_phq9: latestPHQ9,
        has_consent: true,
      },
    });
  } catch (error) {
    logError('Error in getHealthSummary:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get health summary',
      error: error.message,
    });
  }
};

/**
 * Generate AI response based on user message and health data
 */
const generateAIResponse = async (message, healthData, userId) => {
  // This is a simplified AI response generator
  // In production, integrate with OpenAI, Anthropic, or other AI services

  const lowercaseMessage = message.toLowerCase();

  // Analyze health data
  const { recentSleep, recentFood, latestPHQ9 } = healthData;

  let response = '';
  let needsDoctorVisit = false;

  // Check for urgent keywords
  const urgentKeywords = ['suicide', 'kill myself', 'end my life', 'hurt myself', 'emergency'];
  if (urgentKeywords.some(keyword => lowercaseMessage.includes(keyword))) {
    return {
      content: '🚨 **URGENT: Please seek immediate help**\n\n' +
        'If you\'re in crisis, please:\n' +
        '• Call emergency services (911)\n' +
        '• Contact National Suicide Prevention Lifeline: 988\n' +
        '• Go to your nearest emergency room\n\n' +
        'Your life matters, and help is available 24/7.',
      needsDoctorVisit: true,
    };
  }

  // Sleep-related responses
  if (lowercaseMessage.includes('sleep') || lowercaseMessage.includes('tired') || lowercaseMessage.includes('insomnia')) {
    if (recentSleep && recentSleep.length > 0) {
      const avgSleep = recentSleep.reduce((sum, s) => sum + (s.total_duration_minutes || 0), 0) / recentSleep.length;
      const avgQuality = recentSleep.reduce((sum, s) => sum + (s.quality_rating || 0), 0) / recentSleep.length;
      const avgWakeUps = recentSleep.reduce((sum, s) => sum + (s.wake_up_count || 0), 0) / recentSleep.length;

      response += `📊 **Your Sleep Pattern (Last ${recentSleep.length} nights)**\n\n`;
      response += `• Average sleep: ${(avgSleep / 60).toFixed(1)} hours\n`;
      response += `• Average quality: ${avgQuality.toFixed(1)}/5 ⭐\n`;
      response += `• Average wake-ups: ${avgWakeUps.toFixed(1)} times\n\n`;

      if (avgSleep < 360) { // Less than 6 hours
        response += '⚠️ You\'re not getting enough sleep. Most adults need 7-9 hours.\n\n';
        response += '**Recommendations:**\n';
        response += '• Establish a consistent bedtime routine\n';
        response += '• Avoid screens 1 hour before bed\n';
        response += '• Keep your bedroom cool and dark\n';
        response += '• Limit caffeine after 2 PM\n\n';
        needsDoctorVisit = avgSleep < 300; // Less than 5 hours
      } else if (avgSleep > 600) { // More than 10 hours
        response += '💤 You\'re sleeping more than average. This could indicate:\n';
        response += '• Sleep debt recovery\n';
        response += '• Depression or mood disorders\n';
        response += '• Medical conditions\n\n';
        needsDoctorVisit = true;
      } else {
        response += '✅ Your sleep duration looks good!\n\n';
      }

      if (avgWakeUps > 2) {
        response += '⚠️ Frequent wake-ups can affect sleep quality.\n';
        response += 'Consider tracking interruption reasons to identify patterns.\n\n';
      }
    } else {
      response += '💤 I don\'t have recent sleep data. Start tracking your sleep to get personalized insights!\n\n';
    }
  }

  // Food/nutrition-related responses
  if (lowercaseMessage.includes('food') || lowercaseMessage.includes('eat') || lowercaseMessage.includes('nutrition') || lowercaseMessage.includes('diet')) {
    if (recentFood && recentFood.length > 0) {
      const totalCalories = recentFood.reduce((sum, f) => sum + (f.calories || 0), 0);
      const avgDailyCalories = totalCalories / 7;

      response += `🍽️ **Your Nutrition (Last 7 days)**\n\n`;
      response += `• Total calories: ${totalCalories.toFixed(0)}\n`;
      response += `• Average per day: ${avgDailyCalories.toFixed(0)} cal\n`;
      response += `• Meals logged: ${recentFood.length}\n\n`;

      if (avgDailyCalories < 1200) {
        response += '⚠️ Your calorie intake seems low. This may not provide adequate nutrition.\n\n';
        needsDoctorVisit = true;
      } else if (avgDailyCalories > 3000) {
        response += '⚠️ Your calorie intake is high. Consider:\n';
        response += '• Portion control\n';
        response += '• More vegetables and fruits\n';
        response += '• Reducing processed foods\n\n';
      } else {
        response += '✅ Your calorie intake seems reasonable!\n\n';
      }

      response += '**General Nutrition Tips:**\n';
      response += '• Eat a variety of colorful foods\n';
      response += '• Stay hydrated (8 glasses of water daily)\n';
      response += '• Limit sugar and processed foods\n';
      response += '• Include protein in every meal\n\n';
    } else {
      response += '🍽️ I don\'t have recent food data. Start tracking your meals for personalized nutrition advice!\n\n';
    }
  }

  // Mental health-related responses
  if (lowercaseMessage.includes('mental') || lowercaseMessage.includes('depress') || lowercaseMessage.includes('anxious') || lowercaseMessage.includes('sad') || lowercaseMessage.includes('stress')) {
    if (latestPHQ9) {
      const score = latestPHQ9.total_score;
      const severity = latestPHQ9.severity_level;

      response += `🧠 **Your Latest PHQ-9 Assessment**\n\n`;
      response += `• Score: ${score}/27\n`;
      response += `• Severity: ${severity}\n`;
      response += `• Date: ${new Date(latestPHQ9.assessment_date).toLocaleDateString()}\n\n`;

      if (severity === 'severe' || score >= 20) {
        response += '🚨 **Your PHQ-9 score indicates severe depression.**\n\n';
        response += '**PLEASE SEEK IMMEDIATE HELP:**\n';
        response += '• Contact a mental health professional\n';
        response += '• Talk to your doctor\n';
        response += '• Consider crisis hotline: 988\n\n';
        needsDoctorVisit = true;
      } else if (severity === 'moderately_severe' || score >= 15) {
        response += '⚠️ Your score suggests moderately severe depression.\n\n';
        response += '**Recommended Actions:**\n';
        response += '• Schedule appointment with a therapist\n';
        response += '• Talk to your primary care doctor\n';
        response += '• Practice self-care daily\n\n';
        needsDoctorVisit = true;
      } else if (severity === 'moderate' || score >= 10) {
        response += '⚠️ Your score indicates moderate depression.\n\n';
        response += '**Self-Care Tips:**\n';
        response += '• Regular exercise (30 min daily)\n';
        response += '• Connect with friends/family\n';
        response += '• Practice mindfulness or meditation\n';
        response += '• Consider talking to a counselor\n\n';
      } else {
        response += '✅ Your PHQ-9 score is in a healthy range.\n\n';
        response += '**Maintain Mental Wellness:**\n';
        response += '• Continue healthy habits\n';
        response += '• Stay socially connected\n';
        response += '• Manage stress proactively\n\n';
      }
    } else {
      response += '🧠 I don\'t have mental health assessment data.\n';
      response += 'Consider taking the PHQ-9 assessment to track your mental wellness.\n\n';
    }

    response += '**General Mental Health Tips:**\n';
    response += '• Exercise regularly\n';
    response += '• Get adequate sleep\n';
    response += '• Practice mindfulness\n';
    response += '• Limit alcohol and caffeine\n';
    response += '• Stay connected with loved ones\n\n';
  }

  // General wellness query
  if (lowercaseMessage.includes('feel') || lowercaseMessage.includes('how am i') || lowercaseMessage.includes('health')) {
    if (!response) {
      response += '👋 Based on your health data:\n\n';

      let overallScore = 0;
      let factors = 0;

      if (recentSleep && recentSleep.length > 0) {
        const avgSleep = recentSleep.reduce((sum, s) => sum + (s.total_duration_minutes || 0), 0) / recentSleep.length;
        if (avgSleep >= 360 && avgSleep <= 540) overallScore += 1;
        factors += 1;
      }

      if (latestPHQ9 && latestPHQ9.total_score < 10) {
        overallScore += 1;
        factors += 1;
      }

      if (factors > 0) {
        const percentage = (overallScore / factors) * 100;
        response += `📊 Overall wellness: ${percentage.toFixed(0)}%\n\n`;

        if (percentage >= 75) {
          response += '✅ You\'re doing well! Keep up the good habits.\n\n';
        } else if (percentage >= 50) {
          response += '⚠️ There\'s room for improvement. Focus on sleep and mental health.\n\n';
        } else {
          response += '⚠️ Several areas need attention. Consider consulting a doctor.\n\n';
          needsDoctorVisit = true;
        }
      }
    }
  }

  // Default response
  if (!response) {
    response = 'I\'m here to help with your health questions! You can ask me about:\n\n';
    response += '• Sleep patterns and quality\n';
    response += '• Nutrition and diet\n';
    response += '• Mental health and wellness\n';
    response += '• General health concerns\n\n';
    response += 'What would you like to know?';
  }

  // Add doctor visit recommendation
  if (needsDoctorVisit) {
    response += '\n\n⚕️ **Important: Based on your data, I recommend scheduling a doctor appointment soon.**';
  }

  return {
    content: response,
    needsDoctorVisit,
  };
};

/**
 * Send message to AI chatbot
 */
export const sendMessage = async (req, res) => {
  try {
    const userId = req.user.id;
    const { message, include_health_data, timestamp } = req.body;

    if (!message || message.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Message is required',
      });
    }

    // Check consent if health data is requested
    if (include_health_data) {
      const consent = userConsents.get(userId);
      if (!consent?.consent_given) {
        return res.status(403).json({
          success: false,
          message: 'Data consent not granted',
        });
      }
    }

    // Get health data if consent given
    let healthData = {};
    if (include_health_data) {
      const patient = await Patient.findOne({ where: { user_id: userId } });
      if (patient) {
        const patientId = patient.id;
        const sevenDaysAgo = new Date();
        sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

        healthData = {
          recentSleep: await SleepSession.findAll({
            where: {
              patient_id: patientId,
              start_time: { [Op.gte]: sevenDaysAgo },
              status: 'completed',
            },
            order: [['start_time', 'DESC']],
            limit: 7,
          }),
          recentFood: await FoodLog.findAll({
            where: {
              patient_id: patientId,
              consumed_at: { [Op.gte]: sevenDaysAgo },
            },
            order: [['consumed_at', 'DESC']],
            limit: 20,
          }),
          latestPHQ9: await PsychologicalAssessment.findOne({
            where: {
              patient_id: patientId,
              assessment_type: 'PHQ9',
            },
            order: [['assessment_date', 'DESC']],
          }),
        };
      }
    }

    // Generate AI response
    const aiResponse = await generateAIResponse(message, healthData, userId);

    // Store in chat history
    if (!chatHistory.has(userId)) {
      chatHistory.set(userId, []);
    }

    const userMessage = {
      id: Date.now().toString() + '_user',
      content: message,
      is_user: true,
      timestamp: timestamp || new Date().toISOString(),
    };

    const aiMessage = {
      id: Date.now().toString() + '_ai',
      content: aiResponse.content,
      is_user: false,
      timestamp: new Date().toISOString(),
      requires_consent: false,
      consent_given: include_health_data,
    };

    chatHistory.get(userId).push(userMessage, aiMessage);

    // Keep only last 100 messages
    if (chatHistory.get(userId).length > 100) {
      chatHistory.set(userId, chatHistory.get(userId).slice(-100));
    }

    logger.info(`AI chatbot message from user ${userId}`);

    res.status(200).json({
      success: true,
      data: {
        user_message: userMessage,
        ai_response: aiMessage,
      },
    });
  } catch (error) {
    logError('Error in sendMessage:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to send message',
      error: error.message,
    });
  }
};

/**
 * Get chat history
 */
export const getChatHistory = async (req, res) => {
  try {
    const userId = req.user.id;
    const { limit = 50, offset = 0 } = req.query;

    const history = chatHistory.get(userId) || [];
    const messages = history.slice(parseInt(offset), parseInt(offset) + parseInt(limit));

    res.status(200).json({
      success: true,
      data: {
        messages,
        total: history.length,
      },
    });
  } catch (error) {
    logError('Error in getChatHistory:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get chat history',
      error: error.message,
    });
  }
};

/**
 * Clear chat history
 */
export const clearHistory = async (req, res) => {
  try {
    const userId = req.user.id;
    chatHistory.delete(userId);

    logger.info(`User ${userId} cleared chat history`);

    res.status(200).json({
      success: true,
      message: 'Chat history cleared',
    });
  } catch (error) {
    logError('Error in clearHistory:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to clear history',
      error: error.message,
    });
  }
};

/**
 * Get AI health insights
 */
export const getHealthInsights = async (req, res) => {
  try {
    const userId = req.user.id;

    // Check consent
    const consent = userConsents.get(userId);
    if (!consent?.consent_given) {
      return res.status(403).json({
        success: false,
        message: 'Data consent not granted',
      });
    }

    // Get patient and health data
    const patient = await Patient.findOne({ where: { user_id: userId } });
    if (!patient) {
      return res.status(404).json({
        success: false,
        message: 'Patient record not found',
      });
    }

    const patientId = patient.id;
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const sleepData = await SleepSession.findAll({
      where: {
        patient_id: patientId,
        start_time: { [Op.gte]: thirtyDaysAgo },
        status: 'completed',
      },
    });

    const foodData = await FoodLog.findAll({
      where: {
        patient_id: patientId,
        consumed_at: { [Op.gte]: thirtyDaysAgo },
      },
    });

    const phq9Data = await PsychologicalAssessment.findAll({
      where: {
        patient_id: patientId,
        assessment_type: 'PHQ9',
        assessment_date: { [Op.gte]: thirtyDaysAgo },
      },
      order: [['assessment_date', 'DESC']],
    });

    // Generate insights summary
    let summary = '📊 **Your 30-Day Health Insights**\n\n';

    if (sleepData.length > 0) {
      const avgSleep = sleepData.reduce((sum, s) => sum + (s.total_duration_minutes || 0), 0) / sleepData.length;
      summary += `💤 Sleep: ${(avgSleep / 60).toFixed(1)} hours average\n`;
    }

    if (foodData.length > 0) {
      const totalCalories = foodData.reduce((sum, f) => sum + (f.calories || 0), 0);
      summary += `🍽️ Nutrition: ${(totalCalories / 30).toFixed(0)} calories/day average\n`;
    }

    if (phq9Data.length > 0) {
      const latestScore = phq9Data[0].total_score;
      summary += `🧠 Mental Health: PHQ-9 score ${latestScore}/27\n`;
    }

    summary += '\n Keep tracking your health data for better insights!';

    res.status(200).json({
      success: true,
      data: {
        summary,
        sleep_sessions: sleepData.length,
        food_logs: foodData.length,
        phq9_assessments: phq9Data.length,
      },
    });
  } catch (error) {
    logError('Error in getHealthInsights:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get health insights',
      error: error.message,
    });
  }
};
