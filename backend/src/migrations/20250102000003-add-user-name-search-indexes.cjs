'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {

    const indexStatements = [

      `CREATE INDEX IF NOT EXISTS users_first_name_idx
        ON "users" ("first_name")`,

      `CREATE INDEX IF NOT EXISTS users_last_name_idx
        ON "users" ("last_name")`,

      `CREATE INDEX IF NOT EXISTS users_full_name_idx
        ON "users" ("first_name", "last_name")`,

      `CREATE INDEX IF NOT EXISTS users_role_first_name_idx
        ON "users" ("role", "first_name")`,

      `CREATE INDEX IF NOT EXISTS users_role_last_name_idx
        ON "users" ("role", "last_name")`

    ];

    for (const sql of indexStatements) {
      await queryInterface.sequelize.query(sql);
    }
  },

  down: async (queryInterface, Sequelize) => {
    const names = [
      'users_role_last_name_idx',
      'users_role_first_name_idx',
      'users_full_name_idx',
      'users_last_name_idx',
      'users_first_name_idx'
    ];

    for (const name of names) {
      await queryInterface.sequelize.query(`DROP INDEX IF EXISTS ${name};`);
    }
  }
};
