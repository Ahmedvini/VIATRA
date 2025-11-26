/**
 * Migration to add performance indexes for appointment queries
 */
export async function up(queryInterface, Sequelize) {
  // Composite index for patient appointment queries filtered by status and sorted by date
  await queryInterface.addIndex('appointments', ['patient_id', 'status', 'scheduled_start'], {
    name: 'appointments_patient_status_schedule_idx',
    using: 'BTREE'
  });

  // Composite index for doctor appointment queries (for future Phase 2)
  await queryInterface.addIndex('appointments', ['doctor_id', 'status', 'scheduled_start'], {
    name: 'appointments_doctor_status_schedule_idx',
    using: 'BTREE'
  });

  // Composite index for availability and conflict checking queries
  await queryInterface.addIndex('appointments', ['scheduled_start', 'scheduled_end'], {
    name: 'appointments_schedule_range_idx',
    using: 'BTREE'
  });

  // Composite index for global appointment queries by status and date
  await queryInterface.addIndex('appointments', ['status', 'scheduled_start'], {
    name: 'appointments_status_schedule_idx',
    using: 'BTREE'
  });

  // Index for doctor availability queries
  await queryInterface.addIndex('appointments', ['doctor_id', 'scheduled_start', 'scheduled_end', 'status'], {
    name: 'appointments_doctor_availability_idx',
    using: 'BTREE'
  });
}

export async function down(queryInterface, Sequelize) {
  // Remove indexes in reverse order
  await queryInterface.removeIndex('appointments', 'appointments_doctor_availability_idx');
  await queryInterface.removeIndex('appointments', 'appointments_status_schedule_idx');
  await queryInterface.removeIndex('appointments', 'appointments_schedule_range_idx');
  await queryInterface.removeIndex('appointments', 'appointments_doctor_status_schedule_idx');
  await queryInterface.removeIndex('appointments', 'appointments_patient_status_schedule_idx');
}
