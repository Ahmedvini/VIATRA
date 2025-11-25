import { Model } from 'sequelize';

export default (sequelize, DataTypes) => {
  class HealthProfile extends Model {
    static associate(models) {
      // Associations are defined in models/index.js
    }
    
    // Instance methods
    calculateBMI() {
      if (!this.height || !this.weight) return null;
      
      // Convert height from cm to meters if needed
      const heightInMeters = this.height > 3 ? this.height / 100 : this.height;
      const bmi = this.weight / (heightInMeters * heightInMeters);
      
      return Math.round(bmi * 10) / 10; // Round to 1 decimal place
    }
    
    getBMICategory() {
      const bmi = this.calculateBMI();
      if (!bmi) return null;
      
      if (bmi < 18.5) return 'Underweight';
      if (bmi < 25) return 'Normal weight';
      if (bmi < 30) return 'Overweight';
      return 'Obese';
    }
    
    addAllergy(allergen, severity = 'mild', notes = '') {
      const allergies = [...(this.allergies || [])];
      allergies.push({
        allergen,
        severity,
        notes,
        date_added: new Date()
      });
      this.allergies = allergies;
      return this.save();
    }
    
    removeAllergy(allergen) {
      if (!this.allergies) return this;
      
      this.allergies = this.allergies.filter(allergy => 
        allergy.allergen !== allergen
      );
      return this.save();
    }
  }
  
  HealthProfile.init({
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    patient_id: {
      type: DataTypes.UUID,
      allowNull: false,
      unique: true,
      references: {
        model: 'patients',
        key: 'id'
      }
    },
    blood_type: {
      type: DataTypes.ENUM('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'),
      allowNull: true
    },
    height: {
      type: DataTypes.DECIMAL(5, 2), // Height in cm
      allowNull: true,
      validate: {
        min: 30,
        max: 300
      }
    },
    weight: {
      type: DataTypes.DECIMAL(5, 2), // Weight in kg
      allowNull: true,
      validate: {
        min: 1,
        max: 1000
      }
    },
    allergies: {
      type: DataTypes.JSON,
      defaultValue: [],
      comment: 'Array of allergy objects with allergen, severity, and notes'
    },
    chronic_conditions: {
      type: DataTypes.JSON,
      defaultValue: [],
      comment: 'Array of chronic condition objects'
    },
    current_medications: {
      type: DataTypes.JSON,
      defaultValue: [],
      comment: 'Array of current medication objects'
    },
    family_history: {
      type: DataTypes.JSON,
      defaultValue: {},
      comment: 'Object containing family medical history'
    },
    lifestyle: {
      type: DataTypes.JSON,
      defaultValue: {
        smoking: 'never',
        alcohol: 'never',
        exercise_frequency: 'rarely',
        diet: 'regular'
      },
      comment: 'Object containing lifestyle information'
    },
    emergency_contact_name: {
      type: DataTypes.STRING,
      allowNull: true
    },
    emergency_contact_phone: {
      type: DataTypes.STRING,
      allowNull: true,
      validate: {
        is: /^\+?[\d\s\-\(\)]+$/
      }
    },
    emergency_contact_relationship: {
      type: DataTypes.STRING,
      allowNull: true
    },
    preferred_pharmacy: {
      type: DataTypes.STRING,
      allowNull: true
    },
    insurance_provider: {
      type: DataTypes.STRING,
      allowNull: true
    },
    insurance_id: {
      type: DataTypes.STRING,
      allowNull: true
    },
    notes: {
      type: DataTypes.TEXT,
      comment: 'Additional health notes and observations'
    },
    created_at: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW
    },
    updated_at: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW
    }
  }, {
    sequelize,
    modelName: 'HealthProfile',
    tableName: 'health_profiles',
    timestamps: true,
    underscored: true
  });
  
  return HealthProfile;
};
