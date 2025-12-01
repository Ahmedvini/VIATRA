import { Model } from 'sequelize';

export default (sequelize, DataTypes) => {
  class Patient extends Model {
    static associate(models) {
      // Associations are defined in models/index.js
    }
    
    // Instance methods
    getFullName() {
      return `${this.User?.first_name || ''} ${this.User?.last_name || ''}`.trim();
    }
    
    calculateAge() {
      if (!this.date_of_birth) return null;
      const today = new Date();
      const birthDate = new Date(this.date_of_birth);
      let age = today.getFullYear() - birthDate.getFullYear();
      const monthDiff = today.getMonth() - birthDate.getMonth();
      if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
        age--;
      }
      return age;
    }
  }
  
  Patient.init({
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    user_id: {
      type: DataTypes.UUID,
      allowNull: false,
      unique: true,
      references: {
        model: 'users',
        key: 'id'
      }
    },
    date_of_birth: {
      type: DataTypes.DATEONLY,
      allowNull: false
    },
    gender: {
      type: DataTypes.ENUM('male', 'female', 'other', 'prefer_not_to_say'),
      allowNull: false
    },
    address_line1: {
      type: DataTypes.STRING,
      allowNull: true  // Made optional to match database schema
    },
    address_line2: {
      type: DataTypes.STRING,
      allowNull: true
    },
    city: {
      type: DataTypes.STRING,
      allowNull: true  // Made optional to match database schema
    },
    state: {
      type: DataTypes.STRING,
      allowNull: true  // Made optional to match database schema
    },
    zip_code: {
      type: DataTypes.STRING,
      allowNull: true  // Made optional to match database schema
    },
    emergency_contact_name: {
      type: DataTypes.STRING
    },
    emergency_contact_phone: {
      type: DataTypes.STRING,
      validate: {
        is: /^\+?[\d\s\-\(\)]+$/
      }
    },
    emergency_contact_relationship: {
      type: DataTypes.STRING
    },
    medical_history: {
      type: DataTypes.TEXT
    },
    allergies: {
      type: DataTypes.TEXT
    },
    current_medications: {
      type: DataTypes.TEXT
    },
    preferred_language: {
      type: DataTypes.STRING,
      defaultValue: 'en'
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
    modelName: 'Patient',
    tableName: 'patients',
    timestamps: true,
    underscored: true
  });
  
  return Patient;
};
