import { Model } from 'sequelize';

export default (sequelize, DataTypes) => {
  class SleepInterruption extends Model {
    static associate(models) {
      // Association with SleepSession
      SleepInterruption.belongsTo(models.SleepSession, {
        foreignKey: 'sleep_session_id',
        as: 'sleepSession'
      });
    }
  }

  SleepInterruption.init({
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    sleep_session_id: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'sleep_sessions',
        key: 'id'
      }
    },
    pause_time: {
      type: DataTypes.DATE,
      allowNull: false
    },
    resume_time: {
      type: DataTypes.DATE,
      allowNull: true
    },
    duration_minutes: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    reason: {
      type: DataTypes.STRING,
      allowNull: true
    },
    notes: {
      type: DataTypes.TEXT,
      allowNull: true
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
    modelName: 'SleepInterruption',
    tableName: 'sleep_interruptions',
    timestamps: true,
    underscored: true
  });

  return SleepInterruption;
};
