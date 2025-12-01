'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {

    const indexStatements = [

      `CREATE INDEX IF NOT EXISTS idx_doctors_specialty_city 
        ON "doctors" ("specialty", "office_city")`,

      `CREATE INDEX IF NOT EXISTS idx_doctors_specialty 
        ON "doctors" ("specialty")`,

      `CREATE INDEX IF NOT EXISTS idx_doctors_city_state
        ON "doctors" ("office_city", "office_state")`,

      `CREATE INDEX IF NOT EXISTS idx_doctors_consultation_fee
        ON "doctors" ("consultation_fee")`,

      `CREATE INDEX IF NOT EXISTS idx_doctors_accepting_patients
        ON "doctors" ("is_accepting_patients")`,

      `CREATE INDEX IF NOT EXISTS idx_doctors_accepting_created
        ON "doctors" ("is_accepting_patients", "created_at")`,

      `CREATE INDEX IF NOT EXISTS idx_doctors_zip_code
        ON "doctors" ("office_zip_code")`,

      `CREATE INDEX IF NOT EXISTS idx_doctors_created_at
        ON "doctors" ("created_at")`,

      `CREATE INDEX IF NOT EXISTS idx_doctors_telehealth_accepting
        ON "doctors" ("telehealth_enabled", "is_accepting_patients")`,

      // JSONB GIN index (most sensitive one)
      `CREATE INDEX IF NOT EXISTS idx_doctors_languages_spoken
        ON "doctors" USING GIN ((languages_spoken::jsonb))`
    ];

    for (const sql of indexStatements) {
      await queryInterface.sequelize.query(sql);
    }
  },

  down: async (queryInterface) => {
    const names = [
      'idx_doctors_specialty_city',
      'idx_doctors_specialty',
      'idx_doctors_city_state',
      'idx_doctors_consultation_fee',
      'idx_doctors_accepting_patients',
      'idx_doctors_accepting_created',
      'idx_doctors_zip_code',
      'idx_doctors_created_at',
      'idx_doctors_telehealth_accepting',
      'idx_doctors_languages_spoken'
    ];

    for (const name of names) {
      await queryInterface.sequelize.query(`DROP INDEX IF EXISTS ${name};`);
    }
  }
};
