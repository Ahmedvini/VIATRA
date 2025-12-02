import { DataTypes, Model } from 'sequelize';
import { getSequelize } from '../config/database.js';

const sequelize = getSequelize();

/**
 * PsychologicalAssessment Model - PHQ-9 Depression Screening
 * 
 * PHQ-9 Scoring:
 * - Each question: 0 (Not at all) to 3 (Nearly every day)
 * - Total Score: 0-27
 * - Severity Levels:
 *   - 0-4: Minimal depression
 *   - 5-9: Mild depression
 *   - 10-14: Moderate depression
 *   - 15-19: Moderately severe depression
 *   - 20-27: Severe depression
 */
class PsychologicalAssessment extends Model {
  /**
   * Calculate severity level from total score
   */
  static getSeverityLevel(score) {
    if (score <= 4) return 'minimal';
    if (score <= 9) return 'mild';
    if (score <= 14) return 'moderate';
    if (score <= 19) return 'moderately_severe';
    return 'severe';
  }

  /**
   * Get severity level display text
   */
  static getSeverityDisplay(level) {
    const displays = {
      minimal: 'Minimal Depression',
      mild: 'Mild Depression',
      moderate: 'Moderate Depression',
      moderately_severe: 'Moderately Severe Depression',
      severe: 'Severe Depression'
    };
    return displays[level] || 'Unknown';
  }

  /**
   * Get severity level display text in Arabic
   */
  static getSeverityDisplayAr(level) {
    const displays = {
      minimal: 'اكتئاب خفيف جداً',
      mild: 'اكتئاب خفيف',
      moderate: 'اكتئاب متوسط',
      moderately_severe: 'اكتئاب متوسط إلى شديد',
      severe: 'اكتئاب شديد'
    };
    return displays[level] || 'غير معروف';
  }

  /**
   * Get clinical recommendations based on score
   */
  static getRecommendations(score) {
    if (score <= 4) {
      return {
        en: 'No treatment needed. Continue monitoring.',
        ar: 'لا حاجة للعلاج. استمر في المراقبة.'
      };
    }
    if (score <= 9) {
      return {
        en: 'Watchful waiting; repeat PHQ-9 at follow-up. Consider therapy.',
        ar: 'المراقبة والانتظار؛ كرر الفحص عند المتابعة. فكر في العلاج النفسي.'
      };
    }
    if (score <= 14) {
      return {
        en: 'Treatment plan including therapy, medications, or both.',
        ar: 'خطة علاجية تتضمن العلاج النفسي أو الأدوية أو كليهما.'
      };
    }
    if (score <= 19) {
      return {
        en: 'Active treatment with medications and/or psychotherapy.',
        ar: 'علاج نشط بالأدوية و/أو العلاج النفسي.'
      };
    }
    return {
      en: 'Immediate treatment with medications and psychotherapy. Consider hospitalization if severe.',
      ar: 'علاج فوري بالأدوية والعلاج النفسي. فكر في الإدخال إلى المستشفى إذا كان شديداً.'
    };
  }
}

PsychologicalAssessment.init(
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    patient_id: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'patients',
        key: 'id'
      }
    },
    assessment_type: {
      type: DataTypes.STRING(50),
      allowNull: false,
      defaultValue: 'PHQ9'
    },
    assessment_date: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: DataTypes.NOW
    },
    
    // PHQ-9 Questions (0-3 each)
    q1_interest: {
      type: DataTypes.INTEGER,
      validate: { min: 0, max: 3 },
      comment: 'Little interest or pleasure in doing things'
    },
    q2_feeling_down: {
      type: DataTypes.INTEGER,
      validate: { min: 0, max: 3 },
      comment: 'Feeling down, depressed, or hopeless'
    },
    q3_sleep: {
      type: DataTypes.INTEGER,
      validate: { min: 0, max: 3 },
      comment: 'Trouble falling/staying asleep or sleeping too much'
    },
    q4_energy: {
      type: DataTypes.INTEGER,
      validate: { min: 0, max: 3 },
      comment: 'Feeling tired or having little energy'
    },
    q5_appetite: {
      type: DataTypes.INTEGER,
      validate: { min: 0, max: 3 },
      comment: 'Poor appetite or overeating'
    },
    q6_self_worth: {
      type: DataTypes.INTEGER,
      validate: { min: 0, max: 3 },
      comment: 'Feeling bad about yourself or that you are a failure'
    },
    q7_concentration: {
      type: DataTypes.INTEGER,
      validate: { min: 0, max: 3 },
      comment: 'Trouble concentrating on things'
    },
    q8_movement: {
      type: DataTypes.INTEGER,
      validate: { min: 0, max: 3 },
      comment: 'Moving/speaking slowly or being fidgety/restless'
    },
    q9_self_harm: {
      type: DataTypes.INTEGER,
      validate: { min: 0, max: 3 },
      comment: 'Thoughts of being better off dead or hurting yourself'
    },
    
    // Calculated fields
    total_score: {
      type: DataTypes.INTEGER,
      validate: { min: 0, max: 27 }
    },
    severity_level: {
      type: DataTypes.STRING(50)
    },
    
    // Additional context
    notes: {
      type: DataTypes.TEXT
    },
    difficulty_level: {
      type: DataTypes.STRING(20),
      comment: 'How difficult symptoms made functioning: not_difficult, somewhat_difficult, very_difficult, extremely_difficult'
    },
    
    created_at: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: DataTypes.NOW
    },
    updated_at: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: DataTypes.NOW
    }
  },
  {
    sequelize,
    modelName: 'PsychologicalAssessment',
    tableName: 'psychological_assessments',
    timestamps: true,
    underscored: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at',
    hooks: {
      beforeSave: (assessment) => {
        // Calculate total score
        assessment.total_score = 
          (assessment.q1_interest || 0) +
          (assessment.q2_feeling_down || 0) +
          (assessment.q3_sleep || 0) +
          (assessment.q4_energy || 0) +
          (assessment.q5_appetite || 0) +
          (assessment.q6_self_worth || 0) +
          (assessment.q7_concentration || 0) +
          (assessment.q8_movement || 0) +
          (assessment.q9_self_harm || 0);
        
        // Calculate severity level
        assessment.severity_level = PsychologicalAssessment.getSeverityLevel(assessment.total_score);
      }
    }
  }
);

export default PsychologicalAssessment;
