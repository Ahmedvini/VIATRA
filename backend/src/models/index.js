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

// Export models with lazy getters (but return actual model, not proxy)
let _User, _Doctor, _Patient, _Appointment, _HealthProfile, _Verification, _Conversation, _Message, _sequelize;

export const User = {
  get create() { return (_User = _User || initializeModels().User).create.bind(_User); },
  get findOne() { return (_User = _User || initializeModels().User).findOne.bind(_User); },
  get findAll() { return (_User = _User || initializeModels().User).findAll.bind(_User); },
  get findByPk() { return (_User = _User || initializeModels().User).findByPk.bind(_User); },
  get update() { return (_User = _User || initializeModels().User).update.bind(_User); },
  get destroy() { return (_User = _User || initializeModels().User).destroy.bind(_User); },
  get count() { return (_User = _User || initializeModels().User).count.bind(_User); },
};

export const Doctor = {
  get create() { return (_Doctor = _Doctor || initializeModels().Doctor).create.bind(_Doctor); },
  get findOne() { return (_Doctor = _Doctor || initializeModels().Doctor).findOne.bind(_Doctor); },
  get findAll() { return (_Doctor = _Doctor || initializeModels().Doctor).findAll.bind(_Doctor); },
  get findByPk() { return (_Doctor = _Doctor || initializeModels().Doctor).findByPk.bind(_Doctor); },
  get update() { return (_Doctor = _Doctor || initializeModels().Doctor).update.bind(_Doctor); },
  get destroy() { return (_Doctor = _Doctor || initializeModels().Doctor).destroy.bind(_Doctor); },
  get count() { return (_Doctor = _Doctor || initializeModels().Doctor).count.bind(_Doctor); },
};

export const Patient = {
  get create() { return (_Patient = _Patient || initializeModels().Patient).create.bind(_Patient); },
  get findOne() { return (_Patient = _Patient || initializeModels().Patient).findOne.bind(_Patient); },
  get findAll() { return (_Patient = _Patient || initializeModels().Patient).findAll.bind(_Patient); },
  get findByPk() { return (_Patient = _Patient || initializeModels().Patient).findByPk.bind(_Patient); },
  get update() { return (_Patient = _Patient || initializeModels().Patient).update.bind(_Patient); },
  get destroy() { return (_Patient = _Patient || initializeModels().Patient).destroy.bind(_Patient); },
  get count() { return (_Patient = _Patient || initializeModels().Patient).count.bind(_Patient); },
};

export const Appointment = {
  get create() { return (_Appointment = _Appointment || initializeModels().Appointment).create.bind(_Appointment); },
  get findOne() { return (_Appointment = _Appointment || initializeModels().Appointment).findOne.bind(_Appointment); },
  get findAll() { return (_Appointment = _Appointment || initializeModels().Appointment).findAll.bind(_Appointment); },
  get findByPk() { return (_Appointment = _Appointment || initializeModels().Appointment).findByPk.bind(_Appointment); },
  get update() { return (_Appointment = _Appointment || initializeModels().Appointment).update.bind(_Appointment); },
  get destroy() { return (_Appointment = _Appointment || initializeModels().Appointment).destroy.bind(_Appointment); },
  get count() { return (_Appointment = _Appointment || initializeModels().Appointment).count.bind(_Appointment); },
};

export const HealthProfile = {
  get create() { return (_HealthProfile = _HealthProfile || initializeModels().HealthProfile).create.bind(_HealthProfile); },
  get findOne() { return (_HealthProfile = _HealthProfile || initializeModels().HealthProfile).findOne.bind(_HealthProfile); },
  get findAll() { return (_HealthProfile = _HealthProfile || initializeModels().HealthProfile).findAll.bind(_HealthProfile); },
  get findByPk() { return (_HealthProfile = _HealthProfile || initializeModels().HealthProfile).findByPk.bind(_HealthProfile); },
  get update() { return (_HealthProfile = _HealthProfile || initializeModels().HealthProfile).update.bind(_HealthProfile); },
  get destroy() { return (_HealthProfile = _HealthProfile || initializeModels().HealthProfile).destroy.bind(_HealthProfile); },
  get count() { return (_HealthProfile = _HealthProfile || initializeModels().HealthProfile).count.bind(_HealthProfile); },
};

export const Verification = {
  get create() { return (_Verification = _Verification || initializeModels().Verification).create.bind(_Verification); },
  get findOne() { return (_Verification = _Verification || initializeModels().Verification).findOne.bind(_Verification); },
  get findAll() { return (_Verification = _Verification || initializeModels().Verification).findAll.bind(_Verification); },
  get findByPk() { return (_Verification = _Verification || initializeModels().Verification).findByPk.bind(_Verification); },
  get findOrCreate() { return (_Verification = _Verification || initializeModels().Verification).findOrCreate.bind(_Verification); },
  get update() { return (_Verification = _Verification || initializeModels().Verification).update.bind(_Verification); },
  get destroy() { return (_Verification = _Verification || initializeModels().Verification).destroy.bind(_Verification); },
  get count() { return (_Verification = _Verification || initializeModels().Verification).count.bind(_Verification); },
};

export const Conversation = {
  get create() { return (_Conversation = _Conversation || initializeModels().Conversation).create.bind(_Conversation); },
  get findOne() { return (_Conversation = _Conversation || initializeModels().Conversation).findOne.bind(_Conversation); },
  get findAll() { return (_Conversation = _Conversation || initializeModels().Conversation).findAll.bind(_Conversation); },
  get findByPk() { return (_Conversation = _Conversation || initializeModels().Conversation).findByPk.bind(_Conversation); },
  get update() { return (_Conversation = _Conversation || initializeModels().Conversation).update.bind(_Conversation); },
  get destroy() { return (_Conversation = _Conversation || initializeModels().Conversation).destroy.bind(_Conversation); },
  get count() { return (_Conversation = _Conversation || initializeModels().Conversation).count.bind(_Conversation); },
};

export const Message = {
  get create() { return (_Message = _Message || initializeModels().Message).create.bind(_Message); },
  get findOne() { return (_Message = _Message || initializeModels().Message).findOne.bind(_Message); },
  get findAll() { return (_Message = _Message || initializeModels().Message).findAll.bind(_Message); },
  get findByPk() { return (_Message = _Message || initializeModels().Message).findByPk.bind(_Message); },
  get update() { return (_Message = _Message || initializeModels().Message).update.bind(_Message); },
  get destroy() { return (_Message = _Message || initializeModels().Message).destroy.bind(_Message); },
  get count() { return (_Message = _Message || initializeModels().Message).count.bind(_Message); },
};

export const sequelize = {
  get transaction() { return (_sequelize = _sequelize || initializeModels().sequelize).transaction.bind(_sequelize); },
  get query() { return (_sequelize = _sequelize || initializeModels().sequelize).query.bind(_sequelize); },
  get Op() { return (_sequelize = _sequelize || initializeModels().sequelize).Op; },
};

// Export all models as a single object for convenience
export default initializeModels;
