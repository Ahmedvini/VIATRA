import { Model } from 'sequelize';

export default (sequelize, DataTypes) => {
  class Verification extends Model {
    static associate(models) {
      // Associations are defined in models/index.js
    }
    
    // Instance methods
    isExpired() {
      if (!this.expires_at) return false;
      return new Date() > this.expires_at;
    }
    
    isValid() {
      return this.status === 'verified' && !this.isExpired();
    }
    
    markAsVerified() {
      this.status = 'verified';
      this.verified_at = new Date();
      return this.save();
    }
    
    markAsPending() {
      this.status = 'pending';
      this.verified_at = null;
      return this.save();
    }
    
    markAsRejected(reason = '') {
      this.status = 'rejected';
      this.rejection_reason = reason;
      this.verified_at = null;
      return this.save();
    }
  }
  
  Verification.init({
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    user_id: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'users',
        key: 'id'
      }
    },
    doctor_id: {
      type: DataTypes.UUID,
      allowNull: true,
      references: {
        model: 'doctors',
        key: 'id'
      },
      comment: 'Only set for doctor-specific verifications'
    },
    type: {
      type: DataTypes.ENUM(
        'email',
        'phone',
        'identity',
        'medical_license',
        'insurance',
        'background_check',
        'education',
        'certification'
      ),
      allowNull: false
    },
    status: {
      type: DataTypes.ENUM('pending', 'verified', 'rejected', 'expired'),
      allowNull: false,
      defaultValue: 'pending'
    },
    verification_code: {
      type: DataTypes.STRING,
      allowNull: true,
      comment: 'Used for email and phone verifications'
    },
    document_url: {
      type: DataTypes.STRING,
      allowNull: true,
      comment: 'URL to uploaded verification document'
    },
    document_type: {
      type: DataTypes.STRING,
      allowNull: true,
      comment: 'Type of document uploaded'
    },
    verification_data: {
      type: DataTypes.JSON,
      defaultValue: {},
      comment: 'Additional verification data and metadata'
    },
    verified_at: {
      type: DataTypes.DATE,
      allowNull: true
    },
    expires_at: {
      type: DataTypes.DATE,
      allowNull: true,
      comment: 'When this verification expires (if applicable)'
    },
    verified_by: {
      type: DataTypes.UUID,
      allowNull: true,
      references: {
        model: 'users',
        key: 'id'
      },
      comment: 'User ID of admin who verified this'
    },
    rejection_reason: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    attempts: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
      validate: {
        min: 0
      },
      comment: 'Number of verification attempts'
    },
    max_attempts: {
      type: DataTypes.INTEGER,
      defaultValue: 3,
      validate: {
        min: 1
      }
    },
    notes: {
      type: DataTypes.TEXT,
      comment: 'Additional notes about the verification'
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
    modelName: 'Verification',
    tableName: 'verifications',
    timestamps: true,
    underscored: true,
    indexes: [
      {
        fields: ['user_id', 'type'],
        unique: false
      },
      {
        fields: ['doctor_id', 'type'],
        unique: false
      },
      {
        fields: ['status']
      },
      {
        fields: ['expires_at']
      }
    ]
  });
  
  return Verification;
};
