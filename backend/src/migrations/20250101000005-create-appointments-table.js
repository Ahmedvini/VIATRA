'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('appointments', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
        allowNull: false
      },
      patient_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: {
          model: 'patients',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      doctor_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: {
          model: 'doctors',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      appointment_type: {
        type: Sequelize.ENUM('telehealth', 'in_person', 'phone'),
        allowNull: false,
        defaultValue: 'telehealth'
      },
      scheduled_start: {
        type: Sequelize.DATE,
        allowNull: false
      },
      scheduled_end: {
        type: Sequelize.DATE,
        allowNull: false
      },
      actual_start: {
        type: Sequelize.DATE,
        allowNull: true
      },
      actual_end: {
        type: Sequelize.DATE,
        allowNull: true
      },
      status: {
        type: Sequelize.ENUM('scheduled', 'confirmed', 'in_progress', 'completed', 'cancelled', 'no_show'),
        allowNull: false,
        defaultValue: 'scheduled'
      },
      reason_for_visit: {
        type: Sequelize.TEXT,
        allowNull: false
      },
      chief_complaint: {
        type: Sequelize.TEXT,
        allowNull: true
      },
      urgent: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: false
      },
      follow_up_required: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: false
      },
      follow_up_instructions: {
        type: Sequelize.TEXT,
        allowNull: true
      },
      cancellation_reason: {
        type: Sequelize.TEXT,
        allowNull: true
      },
      cancelled_by: {
        type: Sequelize.ENUM('patient', 'doctor', 'system'),
        allowNull: true
      },
      cancelled_at: {
        type: Sequelize.DATE,
        allowNull: true
      },
      notes: {
        type: Sequelize.TEXT,
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
    await queryInterface.addIndex('appointments', ['patient_id'], {
      name: 'appointments_patient_id_idx'
    });
    
    await queryInterface.addIndex('appointments', ['doctor_id'], {
      name: 'appointments_doctor_id_idx'
    });
    
    await queryInterface.addIndex('appointments', ['scheduled_start'], {
      name: 'appointments_scheduled_start_idx'
    });
    
    await queryInterface.addIndex('appointments', ['status'], {
      name: 'appointments_status_idx'
    });
    
    await queryInterface.addIndex('appointments', ['patient_id', 'scheduled_start'], {
      name: 'appointments_patient_schedule_idx'
    });
    
    await queryInterface.addIndex('appointments', ['doctor_id', 'scheduled_start'], {
      name: 'appointments_doctor_schedule_idx'
    });
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('appointments');
  }
};
