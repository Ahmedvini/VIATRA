import { Model } from 'sequelize';

export default (sequelize, DataTypes) => {
  class Appointment extends Model {
    static associate(models) {
      // Associations are defined in models/index.js
    }
    
    // Instance methods
    isUpcoming() {
      return new Date(this.scheduled_start) > new Date();
    }
    
    isPast() {
      return new Date(this.scheduled_end) < new Date();
    }
    
    isActive() {
      const now = new Date();
      return now >= new Date(this.scheduled_start) && now <= new Date(this.scheduled_end);
    }
    
    getDuration() {
      if (!this.scheduled_start || !this.scheduled_end) return 0;
      return (new Date(this.scheduled_end) - new Date(this.scheduled_start)) / (1000 * 60); // minutes
    }
    
    canBeCancelled() {
      const now = new Date();
      const appointmentStart = new Date(this.scheduled_start);
      const hoursUntilAppointment = (appointmentStart - now) / (1000 * 60 * 60);
      
      // Can be cancelled if more than 2 hours in advance and not already cancelled/completed
      return hoursUntilAppointment > 2 && !['cancelled', 'completed'].includes(this.status);
    }
  }
  
  Appointment.init({
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
    doctor_id: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'doctors',
        key: 'id'
      }
    },
    appointment_type: {
      type: DataTypes.ENUM('telehealth', 'in_person', 'phone'),
      allowNull: false,
      defaultValue: 'telehealth'
    },
    scheduled_start: {
      type: DataTypes.DATE,
      allowNull: false
    },
    scheduled_end: {
      type: DataTypes.DATE,
      allowNull: false
    },
    actual_start: {
      type: DataTypes.DATE
    },
    actual_end: {
      type: DataTypes.DATE
    },
    status: {
      type: DataTypes.ENUM('scheduled', 'confirmed', 'in_progress', 'completed', 'cancelled', 'no_show'),
      allowNull: false,
      defaultValue: 'scheduled'
    },
    reason_for_visit: {
      type: DataTypes.TEXT,
      allowNull: false
    },
    chief_complaint: {
      type: DataTypes.TEXT
    },
    urgent: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },
    follow_up_required: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },
    follow_up_instructions: {
      type: DataTypes.TEXT
    },
    cancellation_reason: {
      type: DataTypes.TEXT
    },
    cancelled_by: {
      type: DataTypes.ENUM('patient', 'doctor', 'system'),
      allowNull: true
    },
    cancelled_at: {
      type: DataTypes.DATE
    },
    notes: {
      type: DataTypes.TEXT
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
    modelName: 'Appointment',
    tableName: 'appointments',
    timestamps: true,
    underscored: true,
    validate: {
      scheduledEndAfterStart() {
        if (this.scheduled_end <= this.scheduled_start) {
          throw new Error('Scheduled end time must be after start time');
        }
      },
      actualEndAfterStart() {
        if (this.actual_end && this.actual_start && this.actual_end <= this.actual_start) {
          throw new Error('Actual end time must be after start time');
        }
      }
    }
  });
  
  return Appointment;
};
