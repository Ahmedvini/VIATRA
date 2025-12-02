import { Sequelize, DataTypes } from 'sequelize';
import { getSequelize } from '../config/database.js';

// Import model factories
import UserModel from './User.js';
import DoctorModel from './Doctor.js';
import PatientModel from './Patient.js';
import AppointmentModel from './Appointment.js';
import HealthProfileModel from './HealthProfile.js';
import VerificationModel from './Verification.js';
import ConversationModel from './Conversation.js';
import MessageModel from './Message.js';
import FoodLogModel from './FoodLog.js';
import SleepSessionModel from './SleepSession.js';
import SleepInterruptionModel from './SleepInterruption.js';

// Get sequelize instance
const sequelize = getSequelize();

// Initialize all models
const User = UserModel(sequelize, DataTypes);
const Doctor = DoctorModel(sequelize, DataTypes);
const Patient = PatientModel(sequelize, DataTypes);
const Appointment = AppointmentModel(sequelize, DataTypes);
const HealthProfile = HealthProfileModel(sequelize, DataTypes);
const Verification = VerificationModel(sequelize, DataTypes);
const Conversation = ConversationModel(sequelize, DataTypes);
const Message = MessageModel(sequelize, DataTypes);
const FoodLog = FoodLogModel(sequelize, DataTypes);
const SleepSession = SleepSessionModel(sequelize, DataTypes);
const SleepInterruption = SleepInterruptionModel(sequelize, DataTypes);

// Define associations after all models are initialized
// User associations
User.hasOne(Doctor, { foreignKey: 'user_id', as: 'doctorProfile' });
User.hasOne(Patient, { foreignKey: 'user_id', as: 'patientProfile' });
User.hasMany(Verification, { foreignKey: 'user_id', as: 'verifications' });

// Doctor associations
Doctor.belongsTo(User, { foreignKey: 'user_id', as: 'user' });
Doctor.hasMany(Appointment, { foreignKey: 'doctor_id', as: 'appointments' });
Doctor.hasMany(Verification, { foreignKey: 'doctor_id', as: 'verifications' });

// Patient associations
Patient.belongsTo(User, { foreignKey: 'user_id', as: 'user' });
Patient.hasMany(Appointment, { foreignKey: 'patient_id', as: 'appointments' });
Patient.hasOne(HealthProfile, { foreignKey: 'patient_id', as: 'healthProfile' });

// User associations with FoodLog
User.hasMany(FoodLog, { foreignKey: 'patient_id', as: 'foodLogs' });

// User associations with SleepSession
User.hasMany(SleepSession, { foreignKey: 'patient_id', as: 'sleepSessions' });

// FoodLog associations
FoodLog.belongsTo(User, { foreignKey: 'patient_id', as: 'patient' });

// SleepSession associations
SleepSession.belongsTo(User, { foreignKey: 'patient_id', as: 'patient' });
SleepSession.hasMany(SleepInterruption, { foreignKey: 'sleep_session_id', as: 'interruptions' });

// SleepInterruption associations
SleepInterruption.belongsTo(SleepSession, { foreignKey: 'sleep_session_id', as: 'session' });

// Appointment associations
Appointment.belongsTo(Patient, { foreignKey: 'patient_id', as: 'patient' });
Appointment.belongsTo(Doctor, { foreignKey: 'doctor_id', as: 'doctor' });

// HealthProfile associations
HealthProfile.belongsTo(Patient, { foreignKey: 'patient_id', as: 'patient' });

// Verification associations
Verification.belongsTo(User, { foreignKey: 'user_id', as: 'user' });
Verification.belongsTo(Doctor, { foreignKey: 'doctor_id', as: 'doctor' });

// Conversation associations
Conversation.hasMany(Message, { foreignKey: 'conversation_id', as: 'messages' });

// Message associations
Message.belongsTo(Conversation, { foreignKey: 'conversation_id', as: 'conversation' });
Message.belongsTo(User, { foreignKey: 'sender_id', as: 'sender' });

// Export models
export { User, Doctor, Patient, Appointment, HealthProfile, Verification, Conversation, Message, FoodLog, SleepSession, SleepInterruption, sequelize };

export default {
  User,
  Doctor,
  Patient,
  Appointment,
  HealthProfile,
  Verification,
  Conversation,
  Message,
  FoodLog,
  SleepSession,
  SleepInterruption,
  sequelize,
  getSequelize
};
