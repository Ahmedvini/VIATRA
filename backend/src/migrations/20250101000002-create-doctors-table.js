'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('doctors', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
        allowNull: false
      },
      user_id: {
        type: Sequelize.UUID,
        allowNull: false,
        unique: true,
        references: {
          model: 'users',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      license_number: {
        type: Sequelize.STRING,
        allowNull: false,
        unique: true
      },
      specialty: {
        type: Sequelize.STRING,
        allowNull: false
      },
      sub_specialty: {
        type: Sequelize.STRING,
        allowNull: true
      },
      title: {
        type: Sequelize.ENUM('Dr.', 'PA', 'NP', 'MD', 'DO', 'RN'),
        allowNull: false
      },
      npi_number: {
        type: Sequelize.STRING(10),
        allowNull: true,
        unique: true
      },
      dea_number: {
        type: Sequelize.STRING,
        allowNull: true
      },
      years_of_experience: {
        type: Sequelize.INTEGER,
        allowNull: true
      },
      education: {
        type: Sequelize.TEXT,
        allowNull: true
      },
      certifications: {
        type: Sequelize.JSON,
        allowNull: true,
        defaultValue: []
      },
      languages_spoken: {
        type: Sequelize.JSON,
        allowNull: true,
        defaultValue: ['en']
      },
      bio: {
        type: Sequelize.TEXT,
        allowNull: true
      },
      consultation_fee: {
        type: Sequelize.DECIMAL(10, 2),
        allowNull: true
      },
      telehealth_enabled: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true
      },
      is_accepting_patients: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true
      },
      office_address_line1: {
        type: Sequelize.STRING,
        allowNull: true
      },
      office_address_line2: {
        type: Sequelize.STRING,
        allowNull: true
      },
      office_city: {
        type: Sequelize.STRING,
        allowNull: true
      },
      office_state: {
        type: Sequelize.STRING(2),
        allowNull: true
      },
      office_zip_code: {
        type: Sequelize.STRING,
        allowNull: true
      },
      office_phone: {
        type: Sequelize.STRING,
        allowNull: true
      },
      working_hours: {
        type: Sequelize.JSON,
        allowNull: true,
        defaultValue: {
          monday: { start: '09:00', end: '17:00', available: true },
          tuesday: { start: '09:00', end: '17:00', available: true },
          wednesday: { start: '09:00', end: '17:00', available: true },
          thursday: { start: '09:00', end: '17:00', available: true },
          friday: { start: '09:00', end: '17:00', available: true },
          saturday: { start: null, end: null, available: false },
          sunday: { start: null, end: null, available: false }
        }
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
    await queryInterface.addIndex('doctors', ['user_id'], {
      unique: true,
      name: 'doctors_user_id_unique_idx'
    });
    
    await queryInterface.addIndex('doctors', ['license_number'], {
      unique: true,
      name: 'doctors_license_number_unique_idx'
    });
    
    await queryInterface.addIndex('doctors', ['specialty'], {
      name: 'doctors_specialty_idx'
    });
    
    await queryInterface.addIndex('doctors', ['is_accepting_patients'], {
      name: 'doctors_accepting_patients_idx'
    });
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('doctors');
  }
};
