'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('health_profiles', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
        allowNull: false
      },
      patient_id: {
        type: Sequelize.UUID,
        allowNull: false,
        unique: true,
        references: {
          model: 'patients',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      blood_type: {
        type: Sequelize.ENUM('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'),
        allowNull: true
      },
      height: {
        type: Sequelize.DECIMAL(5, 2),
        allowNull: true,
        comment: 'Height in cm'
      },
      weight: {
        type: Sequelize.DECIMAL(5, 2),
        allowNull: true,
        comment: 'Weight in kg'
      },
      allergies: {
        type: Sequelize.JSON,
        allowNull: true,
        defaultValue: [],
        comment: 'Array of allergy objects with allergen, severity, and notes'
      },
      chronic_conditions: {
        type: Sequelize.JSON,
        allowNull: true,
        defaultValue: [],
        comment: 'Array of chronic condition objects'
      },
      current_medications: {
        type: Sequelize.JSON,
        allowNull: true,
        defaultValue: [],
        comment: 'Array of current medication objects'
      },
      family_history: {
        type: Sequelize.JSON,
        allowNull: true,
        defaultValue: {},
        comment: 'Object containing family medical history'
      },
      lifestyle: {
        type: Sequelize.JSON,
        allowNull: true,
        defaultValue: {
          smoking: 'never',
          alcohol: 'never',
          exercise_frequency: 'rarely',
          diet: 'regular'
        },
        comment: 'Object containing lifestyle information'
      },
      emergency_contact_name: {
        type: Sequelize.STRING,
        allowNull: true
      },
      emergency_contact_phone: {
        type: Sequelize.STRING,
        allowNull: true
      },
      emergency_contact_relationship: {
        type: Sequelize.STRING,
        allowNull: true
      },
      preferred_pharmacy: {
        type: Sequelize.STRING,
        allowNull: true
      },
      insurance_provider: {
        type: Sequelize.STRING,
        allowNull: true
      },
      insurance_id: {
        type: Sequelize.STRING,
        allowNull: true
      },
      notes: {
        type: Sequelize.TEXT,
        allowNull: true,
        comment: 'Additional health notes and observations'
      },
      created_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
      },
      updated_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
      }
    });

    // Add indexes for performance
    await queryInterface.addIndex('health_profiles', ['patient_id'], {
      unique: true,
      name: 'health_profiles_patient_id_unique_idx'
    });
    
    await queryInterface.addIndex('health_profiles', ['blood_type'], {
      name: 'health_profiles_blood_type_idx'
    });
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('health_profiles');
  }
};
