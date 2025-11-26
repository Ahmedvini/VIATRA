'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Add composite index on specialty and city for common search patterns
    await queryInterface.addIndex('doctors', ['specialty', 'office_city'], {
      name: 'idx_doctors_specialty_city',
      using: 'BTREE'
    });

    // Add index on specialty alone for specialty-only searches
    await queryInterface.addIndex('doctors', ['specialty'], {
      name: 'idx_doctors_specialty',
      using: 'BTREE'
    });

    // Add composite index on city and state for location searches
    await queryInterface.addIndex('doctors', ['office_city', 'office_state'], {
      name: 'idx_doctors_city_state',
      using: 'BTREE'
    });

    // Add index on consultation fee for price range queries
    await queryInterface.addIndex('doctors', ['consultation_fee'], {
      name: 'idx_doctors_consultation_fee',
      using: 'BTREE'
    });

    // Add index on is_accepting_patients for availability filtering
    await queryInterface.addIndex('doctors', ['is_accepting_patients'], {
      name: 'idx_doctors_accepting_patients',
      using: 'BTREE'
    });

    // Add composite index on accepting patients and created_at for sorting
    await queryInterface.addIndex('doctors', ['is_accepting_patients', 'created_at'], {
      name: 'idx_doctors_accepting_created',
      using: 'BTREE'
    });

    // Add index on office zip code for location-based searches
    await queryInterface.addIndex('doctors', ['office_zip_code'], {
      name: 'idx_doctors_zip_code',
      using: 'BTREE'
    });

    // Add GIN index on languages_spoken JSONB field for array containment queries
    await queryInterface.sequelize.query(
      'CREATE INDEX idx_doctors_languages_spoken ON doctors USING GIN (languages_spoken);'
    );

    // Add index on created_at for default sorting
    await queryInterface.addIndex('doctors', ['created_at'], {
      name: 'idx_doctors_created_at',
      using: 'BTREE'
    });

    // Add composite index on telehealth_enabled and accepting patients
    await queryInterface.addIndex('doctors', ['telehealth_enabled', 'is_accepting_patients'], {
      name: 'idx_doctors_telehealth_accepting',
      using: 'BTREE'
    });
  },

  down: async (queryInterface, Sequelize) => {
    // Remove all indexes in reverse order
    await queryInterface.removeIndex('doctors', 'idx_doctors_telehealth_accepting');
    await queryInterface.removeIndex('doctors', 'idx_doctors_created_at');
    await queryInterface.sequelize.query('DROP INDEX IF EXISTS idx_doctors_languages_spoken;');
    await queryInterface.removeIndex('doctors', 'idx_doctors_zip_code');
    await queryInterface.removeIndex('doctors', 'idx_doctors_accepting_created');
    await queryInterface.removeIndex('doctors', 'idx_doctors_accepting_patients');
    await queryInterface.removeIndex('doctors', 'idx_doctors_consultation_fee');
    await queryInterface.removeIndex('doctors', 'idx_doctors_city_state');
    await queryInterface.removeIndex('doctors', 'idx_doctors_specialty');
    await queryInterface.removeIndex('doctors', 'idx_doctors_specialty_city');
  }
};
