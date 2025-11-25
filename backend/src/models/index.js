import { Sequelize, DataTypes } from 'sequelize';
import { getSequelize } from '../config/database.js';

// Import models
import UserModel from './User.js';
import DoctorModel from './Doctor.js';
import PatientModel from './Patient.js';
import AppointmentModel from './Appointment.js';
import HealthProfileModel from './HealthProfile.js';
import VerificationModel from './Verification.js';

// Initialize models
const initModels = () => {
  const sequelize = getSequelize();
  
  // Initialize all models
  const User = UserModel(sequelize, DataTypes);
  const Doctor = DoctorModel(sequelize, DataTypes);
  const Patient = PatientModel(sequelize, DataTypes);
  const Appointment = AppointmentModel(sequelize, DataTypes);
  const HealthProfile = HealthProfileModel(sequelize, DataTypes);
  const Verification = VerificationModel(sequelize, DataTypes);
  
  // Define associations
  
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
  
  // Return all models
  return {
    User,
    Doctor,
    Patient,
    Appointment,
    HealthProfile,
    Verification,
    sequelize
  };
};

export default initModels;
