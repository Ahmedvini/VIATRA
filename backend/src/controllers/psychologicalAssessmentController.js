import PsychologicalAssessment from '../models/PsychologicalAssessment.js';
import { Patient } from '../models/index.js';
import { Op } from 'sequelize';
import logger from '../config/logger.js';

/**
 * Submit a new PHQ-9 assessment
 */
export const submitAssessment = async (req, res) => {
  try {
    // Find patient by user ID
    const patient = await Patient.findOne({
      where: { user_id: req.user.id }
    });

    if (!patient) {
      return res.status(404).json({
        success: false,
        message: 'Patient profile not found'
      });
    }

    const patientId = patient.id;
    const {
      assessment_type = 'PHQ9',
      q1_interest,
      q2_feeling_down,
      q3_sleep,
      q4_energy,
      q5_appetite,
      q6_self_worth,
      q7_concentration,
      q8_movement,
      q9_self_harm,
      notes,
      difficulty_level
    } = req.body;

    // Validate all questions are answered
    if ([q1_interest, q2_feeling_down, q3_sleep, q4_energy, q5_appetite,
         q6_self_worth, q7_concentration, q8_movement, q9_self_harm].some(q => q === undefined || q === null)) {
      return res.status(400).json({
        success: false,
        message: 'All 9 questions must be answered'
      });
    }

    // Create assessment
    const assessment = await PsychologicalAssessment.create({
      patient_id: patientId,
      assessment_type,
      q1_interest,
      q2_feeling_down,
      q3_sleep,
      q4_energy,
      q5_appetite,
      q6_self_worth,
      q7_concentration,
      q8_movement,
      q9_self_harm,
      notes,
      difficulty_level
    });

    // Get recommendations
    const recommendations = PsychologicalAssessment.getRecommendations(assessment.total_score);

    logger.info(`PHQ-9 assessment submitted: ${assessment.id}, Score: ${assessment.total_score}`);

    // Check for critical score (high self-harm risk)
    if (assessment.q9_self_harm >= 2) {
      logger.warn(`HIGH RISK: Patient ${patientId} reported self-harm thoughts (score: ${assessment.q9_self_harm})`);
    }

    res.status(201).json({
      success: true,
      message: 'Assessment submitted successfully',
      data: {
        assessment,
        recommendations,
        severity_display: {
          en: PsychologicalAssessment.getSeverityDisplay(assessment.severity_level),
          ar: PsychologicalAssessment.getSeverityDisplayAr(assessment.severity_level)
        }
      }
    });
  } catch (error) {
    logger.error('Error submitting psychological assessment:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to submit assessment',
      error: error.message
    });
  }
};

/**
 * Get assessment history for the patient
 */
export const getAssessmentHistory = async (req, res) => {
  try {
    // Find patient by user ID
    const patient = await Patient.findOne({
      where: { user_id: req.user.id }
    });

    if (!patient) {
      return res.status(404).json({
        success: false,
        message: 'Patient profile not found'
      });
    }

    const patientId = patient.id;
    const { startDate, endDate, limit = 50 } = req.query;

    const whereClause = {
      patient_id: patientId
    };

    if (startDate || endDate) {
      whereClause.assessment_date = {};
      if (startDate) {
        whereClause.assessment_date[Op.gte] = new Date(startDate);
      }
      if (endDate) {
        whereClause.assessment_date[Op.lte] = new Date(endDate);
      }
    }

    const assessments = await PsychologicalAssessment.findAll({
      where: whereClause,
      order: [['assessment_date', 'DESC']],
      limit: parseInt(limit)
    });

    res.json({
      success: true,
      data: assessments
    });
  } catch (error) {
    logger.error('Error fetching assessment history:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch assessment history',
      error: error.message
    });
  }
};

/**
 * Get a specific assessment by ID
 */
export const getAssessmentById = async (req, res) => {
  try {
    // Find patient by user ID
    const patient = await Patient.findOne({
      where: { user_id: req.user.id }
    });

    if (!patient) {
      return res.status(404).json({
        success: false,
        message: 'Patient profile not found'
      });
    }

    const { assessmentId } = req.params;
    const patientId = patient.id;

    const assessment = await PsychologicalAssessment.findOne({
      where: {
        id: assessmentId,
        patient_id: patientId
      }
    });

    if (!assessment) {
      return res.status(404).json({
        success: false,
        message: 'Assessment not found'
      });
    }

    const recommendations = PsychologicalAssessment.getRecommendations(assessment.total_score);

    res.json({
      success: true,
      data: {
        assessment,
        recommendations,
        severity_display: {
          en: PsychologicalAssessment.getSeverityDisplay(assessment.severity_level),
          ar: PsychologicalAssessment.getSeverityDisplayAr(assessment.severity_level)
        }
      }
    });
  } catch (error) {
    logger.error('Error fetching assessment:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch assessment',
      error: error.message
    });
  }
};

/**
 * Get assessment analytics and trends
 */
export const getAssessmentAnalytics = async (req, res) => {
  try {
    // Find patient by user ID
    const patient = await Patient.findOne({
      where: { user_id: req.user.id }
    });

    if (!patient) {
      return res.status(404).json({
        success: false,
        message: 'Patient profile not found'
      });
    }

    const patientId = patient.id;
    const { days = 90 } = req.query;

    const startDate = new Date();
    startDate.setDate(startDate.getDate() - parseInt(days));

    const assessments = await PsychologicalAssessment.findAll({
      where: {
        patient_id: patientId,
        assessment_date: {
          [Op.gte]: startDate
        }
      },
      order: [['assessment_date', 'ASC']]
    });

    if (assessments.length === 0) {
      return res.json({
        success: true,
        data: {
          total_assessments: 0,
          average_score: 0,
          current_severity: null,
          trend: 'no_data',
          assessments: []
        }
      });
    }

    // Calculate analytics
    const totalScore = assessments.reduce((sum, a) => sum + a.total_score, 0);
    const averageScore = totalScore / assessments.length;
    const latestAssessment = assessments[assessments.length - 1];
    
    // Calculate trend (comparing last assessment to previous average)
    let trend = 'stable';
    if (assessments.length > 1) {
      const previousAvg = assessments.slice(0, -1).reduce((sum, a) => sum + a.total_score, 0) / (assessments.length - 1);
      const diff = latestAssessment.total_score - previousAvg;
      if (diff > 2) trend = 'worsening';
      else if (diff < -2) trend = 'improving';
    }

    // Calculate severity distribution
    const severityDistribution = assessments.reduce((acc, a) => {
      acc[a.severity_level] = (acc[a.severity_level] || 0) + 1;
      return acc;
    }, {});

    // Identify symptom patterns (which questions score consistently high)
    const symptomAverages = {
      interest: assessments.reduce((sum, a) => sum + a.q1_interest, 0) / assessments.length,
      feeling_down: assessments.reduce((sum, a) => sum + a.q2_feeling_down, 0) / assessments.length,
      sleep: assessments.reduce((sum, a) => sum + a.q3_sleep, 0) / assessments.length,
      energy: assessments.reduce((sum, a) => sum + a.q4_energy, 0) / assessments.length,
      appetite: assessments.reduce((sum, a) => sum + a.q5_appetite, 0) / assessments.length,
      self_worth: assessments.reduce((sum, a) => sum + a.q6_self_worth, 0) / assessments.length,
      concentration: assessments.reduce((sum, a) => sum + a.q7_concentration, 0) / assessments.length,
      movement: assessments.reduce((sum, a) => sum + a.q8_movement, 0) / assessments.length,
      self_harm: assessments.reduce((sum, a) => sum + a.q9_self_harm, 0) / assessments.length
    };

    res.json({
      success: true,
      data: {
        total_assessments: assessments.length,
        average_score: Math.round(averageScore * 10) / 10,
        current_severity: latestAssessment.severity_level,
        current_score: latestAssessment.total_score,
        trend,
        severity_distribution: severityDistribution,
        symptom_averages: symptomAverages,
        assessments: assessments.map(a => ({
          id: a.id,
          date: a.assessment_date,
          score: a.total_score,
          severity: a.severity_level
        }))
      }
    });
  } catch (error) {
    logger.error('Error fetching assessment analytics:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch analytics',
      error: error.message
    });
  }
};

/**
 * Delete an assessment
 */
export const deleteAssessment = async (req, res) => {
  try {
    // Find patient by user ID
    const patient = await Patient.findOne({
      where: { user_id: req.user.id }
    });

    if (!patient) {
      return res.status(404).json({
        success: false,
        message: 'Patient profile not found'
      });
    }

    const { assessmentId } = req.params;
    const patientId = patient.id;

    const assessment = await PsychologicalAssessment.findOne({
      where: {
        id: assessmentId,
        patient_id: patientId
      }
    });

    if (!assessment) {
      return res.status(404).json({
        success: false,
        message: 'Assessment not found'
      });
    }

    await assessment.destroy();

    logger.info(`Assessment deleted: ${assessmentId}`);

    res.json({
      success: true,
      message: 'Assessment deleted successfully'
    });
  } catch (error) {
    logger.error('Error deleting assessment:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete assessment',
      error: error.message
    });
  }
};

/**
 * Get PHQ-9 questions (for reference)
 */
export const getQuestions = async (req, res) => {
  const questions = [
    {
      id: 'q1',
      en: 'Little interest or pleasure in doing things',
      ar: 'قلة الاهتمام أو المتعة في فعل الأشياء'
    },
    {
      id: 'q2',
      en: 'Feeling down, depressed, or hopeless',
      ar: 'الشعور بالإحباط أو الاكتئاب أو اليأس'
    },
    {
      id: 'q3',
      en: 'Trouble falling or staying asleep, or sleeping too much',
      ar: 'صعوبة في النوم أو البقاء نائماً، أو النوم أكثر من اللازم'
    },
    {
      id: 'q4',
      en: 'Feeling tired or having little energy',
      ar: 'الشعور بالتعب أو قلة الطاقة'
    },
    {
      id: 'q5',
      en: 'Poor appetite or overeating',
      ar: 'ضعف الشهية أو الإفراط في الأكل'
    },
    {
      id: 'q6',
      en: 'Feeling bad about yourself — or that you are a failure or have let yourself or your family down',
      ar: 'الشعور بالسوء تجاه نفسك — أو أنك فاشل أو خذلت نفسك أو عائلتك'
    },
    {
      id: 'q7',
      en: 'Trouble concentrating on things, such as reading the newspaper or watching television',
      ar: 'صعوبة في التركيز على الأشياء، مثل قراءة الصحف أو مشاهدة التلفزيون'
    },
    {
      id: 'q8',
      en: 'Moving or speaking so slowly that other people could have noticed, or the opposite — being so fidgety or restless that you have been moving around a lot more than usual',
      ar: 'التحرك أو التحدث ببطء شديد بحيث يلاحظ الآخرون، أو العكس — أن تكون متوتراً أو قلقاً لدرجة أنك تتحرك أكثر من المعتاد'
    },
    {
      id: 'q9',
      en: 'Thoughts that you would be better off dead, or of hurting yourself in some way',
      ar: 'أفكار بأنك ستكون أفضل حالاً ميتاً، أو إيذاء نفسك بطريقة ما'
    }
  ];

  const scoreLabels = [
    { value: 0, en: 'Not at all', ar: 'على الإطلاق' },
    { value: 1, en: 'Several days', ar: 'عدة أيام' },
    { value: 2, en: 'More than half the days', ar: 'أكثر من نصف الأيام' },
    { value: 3, en: 'Nearly every day', ar: 'كل يوم تقريباً' }
  ];

  res.json({
    success: true,
    data: {
      questions,
      score_labels: scoreLabels,
      instructions: {
        en: 'Over the past two weeks, how often have you been bothered by the following problems?',
        ar: 'خلال الأسبوعين الماضيين، كم مرة أزعجتك المشاكل التالية؟'
      }
    }
  });
};
