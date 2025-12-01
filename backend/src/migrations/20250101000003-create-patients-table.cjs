'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('patients', {
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
      date_of_birth: {
        type: Sequelize.DATEONLY,
        allowNull: false
      },
      gender: {
        type: Sequelize.ENUM('male', 'female', 'other', 'prefer_not_to_say'),
        allowNull: false
      },
      address_line1: {
        type: Sequelize.STRING,
        allowNull: true
      },
      address_line2: {
        type: Sequelize.STRING,
        allowNull: true
      },
      city: {
        type: Sequelize.STRING,
        allowNull: true
      },
      state: {
        type: Sequelize.STRING(2),
        allowNull: true
      },
      zip_code: {
        type: Sequelize.STRING,
        allowNull: true
      },
      preferred_language: {
        type: Sequelize.STRING,
        allowNull: false,
        defaultValue: 'en'
      },
      marital_status: {
        type: Sequelize.ENUM('single', 'married', 'divorced', 'widowed', 'other'),
        allowNull: true
      },
      occupation: {
        type: Sequelize.STRING,
        allowNull: true
      },
      employer: {
        type: Sequelize.STRING,
        allowNull: true
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
    await queryInterface.addIndex('patients', ['user_id'], {
      unique: true,
      name: 'patients_user_id_unique_idx'
    });
    
    await queryInterface.addIndex('patients', ['date_of_birth'], {
      name: 'patients_dob_idx'
    });
    
    await queryInterface.addIndex('patients', ['gender'], {
      name: 'patients_gender_idx'
    });
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('patients');
  }
};
