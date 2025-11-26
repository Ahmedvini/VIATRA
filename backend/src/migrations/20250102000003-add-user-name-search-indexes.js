/**
 * Migration to add performance indexes for doctor name search
 * Supports free-text search on doctor names (first_name, last_name)
 */
export async function up(queryInterface, Sequelize) {
  // Index on first_name for name-based doctor search
  await queryInterface.addIndex('users', ['first_name'], {
    name: 'users_first_name_idx',
    using: 'BTREE'
  });

  // Index on last_name for name-based doctor search
  await queryInterface.addIndex('users', ['last_name'], {
    name: 'users_last_name_idx',
    using: 'BTREE'
  });

  // Composite index on first_name + last_name for full name searches
  await queryInterface.addIndex('users', ['first_name', 'last_name'], {
    name: 'users_full_name_idx',
    using: 'BTREE'
  });

  // Composite index on role + first_name for doctor-specific name searches
  await queryInterface.addIndex('users', ['role', 'first_name'], {
    name: 'users_role_first_name_idx',
    using: 'BTREE'
  });

  // Composite index on role + last_name for doctor-specific name searches
  await queryInterface.addIndex('users', ['role', 'last_name'], {
    name: 'users_role_last_name_idx',
    using: 'BTREE'
  });
}

export async function down(queryInterface, Sequelize) {
  // Remove indexes in reverse order
  await queryInterface.removeIndex('users', 'users_role_last_name_idx');
  await queryInterface.removeIndex('users', 'users_role_first_name_idx');
  await queryInterface.removeIndex('users', 'users_full_name_idx');
  await queryInterface.removeIndex('users', 'users_last_name_idx');
  await queryInterface.removeIndex('users', 'users_first_name_idx');
}
