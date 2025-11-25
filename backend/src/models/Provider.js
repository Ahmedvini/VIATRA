import { Model } from 'sequelize';

export default (sequelize, DataTypes) => {
  class Provider extends Model {
    static associate(models) {
      // Associations are defined in models/index.js
    }
    
    // Instance methods
    getFullName() {
      return `${this.User?.first_name || ''} ${this.User?.last_name || ''}`.trim();
    }
    
    getDisplayName() {
      const name = this.getFullName();
      return this.title ? `${this.title} ${name}` : name;
    }
    
    isAvailable(dateTime) {
      // Simple availability check - can be expanded
      if (!this.is_accepting_patients) return false;
      
      // Add more complex availability logic here
      return true;
    }
  }
  
  Provider.init({
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
    license_number: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true
    },
    specialty: {
      type: DataTypes.STRING,
      allowNull: false
    },
    sub_specialty: {
      type: DataTypes.STRING
    },
    title: {
      type: DataTypes.ENUM('Dr.', 'PA', 'NP', 'MD', 'DO', 'RN'),
      allowNull: false
    },
    npi_number: {
      type: DataTypes.STRING,
      unique: true,
      validate: {
        len: [10, 10],
        isNumeric: true
      }
    },
    dea_number: {
      type: DataTypes.STRING,
      validate: {
        is: /^[A-Z]{2}\d{7}$/
      }
    },
    years_of_experience: {
      type: DataTypes.INTEGER,
      validate: {
        min: 0,
        max: 60
      }
    },
    education: {
      type: DataTypes.TEXT
    },
    certifications: {
      type: DataTypes.JSON,
      defaultValue: []
    },
    languages_spoken: {
      type: DataTypes.JSON,
      defaultValue: ['en']
    },
    bio: {
      type: DataTypes.TEXT
    },
    consultation_fee: {
      type: DataTypes.DECIMAL(10, 2),
      validate: {
        min: 0
      }
    },
    telehealth_enabled: {
      type: DataTypes.BOOLEAN,
      defaultValue: true
    },
    is_accepting_patients: {
      type: DataTypes.BOOLEAN,
      defaultValue: true
    },
    office_address_line1: {
      type: DataTypes.STRING
    },
    office_address_line2: {
      type: DataTypes.STRING
    },
    office_city: {
      type: DataTypes.STRING
    },
    office_state: {
      type: DataTypes.STRING,
      validate: {
        len: [2, 2] // US state abbreviation
      }
    },
    office_zip_code: {
      type: DataTypes.STRING,
      validate: {
        is: /^\d{5}(-\d{4})?$/
      }
    },
    office_phone: {
      type: DataTypes.STRING,
      validate: {
        is: /^\+?[\d\s\-\(\)]+$/
      }
    },
    working_hours: {
      type: DataTypes.JSON,
      defaultValue: {
        monday: { start: '09:00', end: '17:00', available: true },
        tuesday: { start: '09:00', end: '17:00', available: true },
        wednesday: { start: '09:00', end: '17:00', available: true },
        thursday: { start: '09:00', end: '17:00', available: true },
        friday: { start: '09:00', end: '17:00', available: true },
        saturday: { start: null, end: null, available: false },
        sunday: { start: null, end: null, available: false }
      }
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
    modelName: 'Provider',
    tableName: 'providers',
    timestamps: true,
    underscored: true
  });
  
  return Provider;
};
