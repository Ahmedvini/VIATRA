'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    // Create sleep_sessions table
    await queryInterface.createTable('sleep_sessions', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
        allowNull: false
      },
      // Link to patient (users table with role='patient')
      patient_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: {
          model: 'users',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      // Session timing
      start_time: {
        type: Sequelize.DATE,
        allowNull: false
      },
      end_time: {
        type: Sequelize.DATE,
        allowNull: true // null if session is still active
      },
      // Sleep quality (1-5 stars, recorded at end)
      quality_rating: {
        type: Sequelize.INTEGER,
        allowNull: true,
        validate: {
          min: 1,
          max: 5
        }
      },
      // Total duration in minutes (calculated when session ends)
      total_duration_minutes: {
        type: Sequelize.INTEGER,
        allowNull: true
      },
      // How many times woke up during session
      wake_up_count: {
        type: Sequelize.INTEGER,
        defaultValue: 0,
        allowNull: false
      },
      // Notes about sleep (dreams, disturbances, etc.)
      notes: {
        type: Sequelize.TEXT,
        allowNull: true
      },
      // Environmental factors
      environment_factors: {
        type: Sequelize.JSONB,
        allowNull: true,
        comment: 'Factors like room temperature, noise level, etc.'
      },
      // Status of the session
      status: {
        type: Sequelize.ENUM('active', 'paused', 'completed'),
        defaultValue: 'active',
        allowNull: false
      },
      // Timestamps
      created_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.NOW
      },
      updated_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.NOW
      }
    });

    // Create sleep_interruptions table (for tracking wake-ups)
    await queryInterface.createTable('sleep_interruptions', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
        allowNull: false
      },
      // Link to sleep session
      sleep_session_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: {
          model: 'sleep_sessions',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      // When the interruption started (paused)
      pause_time: {
        type: Sequelize.DATE,
        allowNull: false
      },
      // When sleep resumed (unpaused)
      resume_time: {
        type: Sequelize.DATE,
        allowNull: true // null if still paused
      },
      // Duration of interruption in minutes
      duration_minutes: {
        type: Sequelize.INTEGER,
        allowNull: true
      },
      // Reason for waking up
      reason: {
        type: Sequelize.STRING,
        allowNull: true,
        comment: 'Bathroom, noise, discomfort, etc.'
      },
      // Additional notes
      notes: {
        type: Sequelize.TEXT,
        allowNull: true
      },
      // Timestamps
      created_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.NOW
      },
      updated_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.NOW
      }
    });

    // Add indexes for faster queries
    await queryInterface.addIndex('sleep_sessions', ['patient_id']);
    await queryInterface.addIndex('sleep_sessions', ['start_time']);
    await queryInterface.addIndex('sleep_sessions', ['status']);
    await queryInterface.addIndex('sleep_sessions', ['patient_id', 'start_time']);
    
    await queryInterface.addIndex('sleep_interruptions', ['sleep_session_id']);
    await queryInterface.addIndex('sleep_interruptions', ['pause_time']);
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('sleep_interruptions');
    await queryInterface.dropTable('sleep_sessions');
  }
};
