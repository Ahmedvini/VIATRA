'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    // Helper function to get future date
    const getFutureDate = (days) => {
      const date = new Date();
      date.setDate(date.getDate() + days);
      return date;
    };

    // Helper function to get past date
    const getPastDate = (days) => {
      const date = new Date();
      date.setDate(date.getDate() - days);
      return date;
    };

    await queryInterface.bulkInsert('appointments', [
      {
        id: 'cc1a2b3c-4d5e-6f78-9012-3456789abcde',
        patient_id: '44e1f2a3-b4c5-d678-9012-3456789abcde', // Sarah Davis
        doctor_id: '11b2c3d4-e5f6-7890-1234-567890abcdef',  // Dr. John Smith (Cardiology)
        appointment_type: 'telehealth',
        scheduled_start: getFutureDate(7), // 7 days from now
        scheduled_end: new Date(getFutureDate(7).getTime() + (30 * 60 * 1000)), // 30 minutes later
        actual_start: null,
        actual_end: null,
        status: 'scheduled',
        reason_for_visit: 'Follow-up consultation for chest pain evaluation',
        chief_complaint: 'Occasional chest discomfort during exercise',
        urgent: false,
        follow_up_required: false,
        follow_up_instructions: null,
        cancellation_reason: null,
        cancelled_by: null,
        cancelled_at: null,
        notes: 'Patient requested telehealth due to work schedule',
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        id: 'dd2b3c4d-5e6f-7890-1234-56789bcdefgh',
        patient_id: '55f1a2b3-c4d5-e678-9012-3456789bcdef', // Robert Wilson
        doctor_id: '11b2c3d4-e5f6-7890-1234-567890abcdef',  // Dr. John Smith (Cardiology)
        appointment_type: 'in_person',
        scheduled_start: getPastDate(5), // 5 days ago
        scheduled_end: new Date(getPastDate(5).getTime() + (45 * 60 * 1000)), // 45 minutes later
        actual_start: getPastDate(5),
        actual_end: new Date(getPastDate(5).getTime() + (40 * 60 * 1000)), // Actually 40 minutes
        status: 'completed',
        reason_for_visit: 'Hypertension management and medication review',
        chief_complaint: 'Blood pressure control assessment',
        urgent: false,
        follow_up_required: true,
        follow_up_instructions: 'Continue current medication. Return in 3 months for follow-up.',
        cancellation_reason: null,
        cancelled_by: null,
        cancelled_at: null,
        notes: 'Blood pressure well controlled. Patient compliant with medications.',
        created_at: getPastDate(10),
        updated_at: getPastDate(5)
      },
      {
        id: 'ee3c4d5e-6f78-9012-3456-789cdefghijk',
        patient_id: '66a2b3c4-d5e6-f789-0123-456789cdefgh', // Lisa Anderson
        doctor_id: '22c2d3e4-f5a6-7890-1234-567890bcdefg',  // Dr. Emily Johnson (Pediatrics)
        appointment_type: 'telehealth',
        scheduled_start: getFutureDate(3), // 3 days from now
        scheduled_end: new Date(getFutureDate(3).getTime() + (20 * 60 * 1000)), // 20 minutes later
        actual_start: null,
        actual_end: null,
        status: 'confirmed',
        reason_for_visit: 'General wellness consultation and health screening',
        chief_complaint: 'Routine health check-up',
        urgent: false,
        follow_up_required: false,
        follow_up_instructions: null,
        cancellation_reason: null,
        cancelled_by: null,
        cancelled_at: null,
        notes: 'Annual wellness visit for young adult',
        created_at: getPastDate(2),
        updated_at: getPastDate(1)
      },
      {
        id: 'ff4d5e6f-7890-1234-5678-9abcdefghijk',
        patient_id: '77b2c3d4-e5f6-a789-0123-456789defghi', // James Miller
        doctor_id: '33d2e3f4-a5b6-7890-1234-567890cdefgh',  // Dr. Michael Brown (Dermatology)
        appointment_type: 'in_person',
        scheduled_start: getFutureDate(14), // 14 days from now
        scheduled_end: new Date(getFutureDate(14).getTime() + (30 * 60 * 1000)), // 30 minutes later
        actual_start: null,
        actual_end: null,
        status: 'scheduled',
        reason_for_visit: 'Skin mole examination and annual dermatology screening',
        chief_complaint: 'New mole on back, annual skin check',
        urgent: false,
        follow_up_required: false,
        follow_up_instructions: null,
        cancellation_reason: null,
        cancelled_by: null,
        cancelled_at: null,
        notes: 'Patient has family history of melanoma - high priority screening',
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        id: 'aa5e6f78-9012-3456-7890-abcdefghijkl',
        patient_id: '44e1f2a3-b4c5-d678-9012-3456789abcde', // Sarah Davis
        doctor_id: '22c2d3e4-f5a6-7890-1234-567890bcdefg',  // Dr. Emily Johnson (Pediatrics)
        appointment_type: 'phone',
        scheduled_start: getPastDate(15), // 15 days ago
        scheduled_end: new Date(getPastDate(15).getTime() + (15 * 60 * 1000)), // 15 minutes later
        actual_start: null,
        actual_end: null,
        status: 'cancelled',
        reason_for_visit: 'Asthma inhaler refill consultation',
        chief_complaint: 'Need prescription renewal for asthma inhaler',
        urgent: false,
        follow_up_required: false,
        follow_up_instructions: null,
        cancellation_reason: 'Patient scheduling conflict',
        cancelled_by: 'patient',
        cancelled_at: getPastDate(16),
        notes: 'Rescheduled for later date',
        created_at: getPastDate(20),
        updated_at: getPastDate(16)
      },
      {
        id: 'bb6f7890-1234-5678-9012-bcdefghijklm',
        patient_id: '55f1a2b3-c4d5-e678-9012-3456789bcdef', // Robert Wilson
        doctor_id: '33d2e3f4-a5b6-7890-1234-567890cdefgh',  // Dr. Michael Brown (Dermatology)
        appointment_type: 'in_person',
        scheduled_start: getFutureDate(21), // 21 days from now
        scheduled_end: new Date(getFutureDate(21).getTime() + (45 * 60 * 1000)), // 45 minutes later
        actual_start: null,
        actual_end: null,
        status: 'scheduled',
        reason_for_visit: 'Suspicious skin lesion evaluation',
        chief_complaint: 'Dark spot on shoulder that has changed in appearance',
        urgent: true,
        follow_up_required: false,
        follow_up_instructions: null,
        cancellation_reason: null,
        cancelled_by: null,
        cancelled_at: null,
        notes: 'Urgent referral from primary care physician',
        created_at: new Date(),
        updated_at: new Date()
      }
    ], {});
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.bulkDelete('appointments', null, {});
  }
};
