'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('verifications', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
        allowNull: false
      },
      user_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: {
          model: 'users',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      doctor_id: {
        type: Sequelize.UUID,
        allowNull: true,
        references: {
          model: 'doctors',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE',
        comment: 'Only set for doctor-specific verifications'
      },
      type: {
        type: Sequelize.ENUM(
          'email',
          'phone',
          'identity',
          'medical_license',
          'insurance',
          'background_check',
          'education',
          'certification'
        ),
        allowNull: false
      },
      status: {
        type: Sequelize.ENUM('pending', 'verified', 'rejected', 'expired'),
        allowNull: false,
        defaultValue: 'pending'
      },
      verification_code: {
        type: Sequelize.STRING,
        allowNull: true,
        comment: 'Used for email and phone verifications'
      },
      document_url: {
        type: Sequelize.STRING,
        allowNull: true,
        comment: 'URL to uploaded verification document'
      },
      document_type: {
        type: Sequelize.STRING,
        allowNull: true,
        comment: 'Type of document uploaded'
      },
      verification_data: {
        type: Sequelize.JSON,
        allowNull: true,
        defaultValue: {},
        comment: 'Additional verification data and metadata'
      },
      verified_at: {
        type: Sequelize.DATE,
        allowNull: true
      },
      expires_at: {
        type: Sequelize.DATE,
        allowNull: true,
        comment: 'When this verification expires (if applicable)'
      },
      verified_by: {
        type: Sequelize.UUID,
        allowNull: true,
        references: {
          model: 'users',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'SET NULL',
        comment: 'User ID of admin who verified this'
      },
      rejection_reason: {
        type: Sequelize.TEXT,
        allowNull: true
      },
      attempts: {
        type: Sequelize.INTEGER,
        allowNull: false,
        defaultValue: 0,
        comment: 'Number of verification attempts'
      },
      max_attempts: {
        type: Sequelize.INTEGER,
        allowNull: false,
        defaultValue: 3
      },
      notes: {
        type: Sequelize.TEXT,
        allowNull: true,
        comment: 'Additional notes about the verification'
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
    await queryInterface.addIndex('verifications', ['user_id', 'type'], {
      name: 'verifications_user_type_idx'
    });
    
    await queryInterface.addIndex('verifications', ['doctor_id', 'type'], {
      name: 'verifications_doctor_type_idx'
    });
    
    await queryInterface.addIndex('verifications', ['status'], {
      name: 'verifications_status_idx'
    });
    
    await queryInterface.addIndex('verifications', ['expires_at'], {
      name: 'verifications_expires_at_idx'
    });
    
    await queryInterface.addIndex('verifications', ['type'], {
      name: 'verifications_type_idx'
    });
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('verifications');
  }
};
