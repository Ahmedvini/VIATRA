'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.addColumn('users', 'fcm_token', {
      type: Sequelize.TEXT,
      allowNull: true,
      after: 'profile_image'
    });

    // Add index on fcm_token for efficient lookups when sending push notifications
    await queryInterface.addIndex('users', ['fcm_token'], {
      name: 'idx_users_fcm_token',
      where: {
        fcm_token: {
          [Sequelize.Op.ne]: null
        }
      }
    });
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.removeIndex('users', 'idx_users_fcm_token');
    await queryInterface.removeColumn('users', 'fcm_token');
  }
};
