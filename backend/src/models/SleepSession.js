import { Model } from 'sequelize';

export default (sequelize, DataTypes) => {
  class SleepSession extends Model {
    static associate(models) {
      // Association with User (patient)
      SleepSession.belongsTo(models.User, {
        foreignKey: 'patient_id',
        as: 'patient'
      });

      // Association with SleepInterruptions
      SleepSession.hasMany(models.SleepInterruption, {
        foreignKey: 'sleep_session_id',
        as: 'interruptions'
      });
    }

    // Calculate total sleep duration excluding interruptions
    calculateActualSleepDuration() {
      if (!this.end_time) return null;
      
      const totalMinutes = Math.floor(
        (new Date(this.end_time) - new Date(this.start_time)) / (1000 * 60)
      );
      
      // Subtract interruption durations
      const interruptionMinutes = this.interruptions?.reduce(
        (sum, interruption) => sum + (interruption.duration_minutes || 0),
        0
      ) || 0;
      
      return totalMinutes - interruptionMinutes;
    }

    // Calculate sleep efficiency (actual sleep / total time in bed)
    calculateSleepEfficiency() {
      if (!this.end_time) return null;
      
      const actualSleep = this.calculateActualSleepDuration();
      if (!actualSleep || !this.total_duration_minutes) return null;
      
      return Math.round((actualSleep / this.total_duration_minutes) * 100);
    }
  }

  SleepSession.init({
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    patient_id: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'users',
        key: 'id'
      }
    },
    start_time: {
      type: DataTypes.DATE,
      allowNull: false
    },
    end_time: {
      type: DataTypes.DATE,
      allowNull: true
    },
    quality_rating: {
      type: DataTypes.INTEGER,
      allowNull: true,
      validate: {
        min: 1,
        max: 5
      }
    },
    total_duration_minutes: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    wake_up_count: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
      allowNull: false
    },
    notes: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    environment_factors: {
      type: DataTypes.JSONB,
      allowNull: true
    },
    status: {
      type: DataTypes.ENUM('active', 'paused', 'completed'),
      defaultValue: 'active',
      allowNull: false
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
  }, {
    sequelize,
    modelName: 'SleepSession',
    tableName: 'sleep_sessions',
    timestamps: true,
    underscored: true
  });

  return SleepSession;
};
