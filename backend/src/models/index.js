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

// Get sequelize instance (must be initialized first via initializeSequelize)
const sequelize = getSequelize();

// Initialize all models - these are invoked at module load time
export const User = UserModel(sequelize, DataTypes);
export const Doctor = DoctorModel(sequelize, DataTypes);
export const Patient = PatientModel(sequelize, DataTypes);
export const Appointment = AppointmentModel(sequelize, DataTypes);
export const HealthProfile = HealthProfileModel(sequelize, DataTypes);
export const Verification = VerificationModel(sequelize, DataTypes);
export const Conversation = ConversationModel(sequelize, DataTypes);
export const Message = MessageModel(sequelize, DataTypes);

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

// Export sequelize instance for direct access
export { sequelize };

// Export all models as a single object for convenience
export default {
  User,
  Doctor,
  Patient,
  Appointment,
  HealthProfile,
  Verification,
  Conversation,
  Message,
  sequelize
};
