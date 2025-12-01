'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {

    const indexStatements = [

      `CREATE INDEX IF NOT EXISTS appointments_patient_status_schedule_idx
        ON "appointments" ("patient_id", "status", "scheduled_start")`,

      `CREATE INDEX IF NOT EXISTS appointments_doctor_status_schedule_idx
        ON "appointments" ("doctor_id", "status", "scheduled_start")`,

      `CREATE INDEX IF NOT EXISTS appointments_schedule_range_idx
        ON "appointments" ("scheduled_start", "scheduled_end")`,

      `CREATE INDEX IF NOT EXISTS appointments_status_schedule_idx
        ON "appointments" ("status", "scheduled_start")`,

      `CREATE INDEX IF NOT EXISTS appointments_doctor_availability_idx
        ON "appointments" ("doctor_id", "scheduled_start", "scheduled_end", "status")`

    ];

    for (const sql of indexStatements) {
      await queryInterface.sequelize.query(sql);
    }
  },

  down: async (queryInterface, Sequelize) => {
    const names = [
      'appointments_doctor_availability_idx',
      'appointments_status_schedule_idx',
      'appointments_schedule_range_idx',
      'appointments_doctor_status_schedule_idx',
      'appointments_patient_status_schedule_idx'
    ];

    for (const name of names) {
      await queryInterface.sequelize.query(`DROP INDEX IF EXISTS ${name};`);
    }
  }
};
