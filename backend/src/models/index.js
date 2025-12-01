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

// Cache for initialized models
let modelsCache = null;

// Initialize models lazily
const initializeModels = () => {
  if (modelsCache) {
    return modelsCache;
  }

  // Get sequelize instance (must be initialized first via initializeSequelize)
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

  // Cache the models
  modelsCache = {
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

  return modelsCache;
};

// Export models with getters to ensure lazy initialization
export const User = new Proxy({}, {
  get: (target, prop) => initializeModels().User[prop],
  set: (target, prop, value) => { initializeModels().User[prop] = value; return true; }
});

export const Doctor = new Proxy({}, {
  get: (target, prop) => initializeModels().Doctor[prop],
  set: (target, prop, value) => { initializeModels().Doctor[prop] = value; return true; }
});

export const Patient = new Proxy({}, {
  get: (target, prop) => initializeModels().Patient[prop],
  set: (target, prop, value) => { initializeModels().Patient[prop] = value; return true; }
});

export const Appointment = new Proxy({}, {
  get: (target, prop) => initializeModels().Appointment[prop],
  set: (target, prop, value) => { initializeModels().Appointment[prop] = value; return true; }
});

export const HealthProfile = new Proxy({}, {
  get: (target, prop) => initializeModels().HealthProfile[prop],
  set: (target, prop, value) => { initializeModels().HealthProfile[prop] = value; return true; }
});

export const Verification = new Proxy({}, {
  get: (target, prop) => initializeModels().Verification[prop],
  set: (target, prop, value) => { initializeModels().Verification[prop] = value; return true; }
});

export const Conversation = new Proxy({}, {
  get: (target, prop) => initializeModels().Conversation[prop],
  set: (target, prop, value) => { initializeModels().Conversation[prop] = value; return true; }
});

export const Message = new Proxy({}, {
  get: (target, prop) => initializeModels().Message[prop],
  set: (target, prop, value) => { initializeModels().Message[prop] = value; return true; }
});

// Export sequelize instance getter
export const sequelize = new Proxy({}, {
  get: (target, prop) => {
    const seq = getSequelize();
    return typeof seq[prop] === 'function' ? seq[prop].bind(seq) : seq[prop];
  }
});

// Export all models as a single object for convenience
export default initializeModels;
