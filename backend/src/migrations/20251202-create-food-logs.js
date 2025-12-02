'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('food_logs', {
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
      meal_type: {
        type: Sequelize.ENUM('breakfast', 'lunch', 'dinner', 'snack'),
        allowNull: false
      },
      food_name: {
        type: Sequelize.STRING,
        allowNull: false
      },
      description: {
        type: Sequelize.TEXT,
        allowNull: true
      },
      image_url: {
        type: Sequelize.STRING,
        allowNull: true
      },
      // AI Analysis Results
      calories: {
        type: Sequelize.FLOAT,
        allowNull: true
      },
      protein_grams: {
        type: Sequelize.FLOAT,
        allowNull: true
      },
      carbs_grams: {
        type: Sequelize.FLOAT,
        allowNull: true
      },
      fat_grams: {
        type: Sequelize.FLOAT,
        allowNull: true
      },
      fiber_grams: {
        type: Sequelize.FLOAT,
        allowNull: true
      },
      sugar_grams: {
        type: Sequelize.FLOAT,
        allowNull: true
      },
      sodium_mg: {
        type: Sequelize.FLOAT,
        allowNull: true
      },
      // AI Analysis
      ai_analysis: {
        type: Sequelize.JSONB,
        allowNull: true
      },
      ai_confidence: {
        type: Sequelize.FLOAT,
        allowNull: true
      },
      // Serving info
      serving_size: {
        type: Sequelize.STRING,
        allowNull: true
      },
      servings_count: {
        type: Sequelize.FLOAT,
        defaultValue: 1.0
      },
      // Timing
      consumed_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.NOW
      },
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
    await queryInterface.addIndex('food_logs', ['user_id']);
    await queryInterface.addIndex('food_logs', ['consumed_at']);
    await queryInterface.addIndex('food_logs', ['user_id', 'consumed_at']);
    await queryInterface.addIndex('food_logs', ['meal_type']);
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('food_logs');
  }
};
