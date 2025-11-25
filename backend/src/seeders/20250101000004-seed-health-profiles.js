'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.bulkInsert('health_profiles', [
      {
        id: '88c2d3e4-f5a6-b789-0123-456789efghij',
        patient_id: '44e1f2a3-b4c5-d678-9012-3456789abcde', // Sarah Davis
        blood_type: 'A+',
        height: 165.00, // 165 cm
        weight: 60.50,  // 60.5 kg
        allergies: [
          {
            allergen: 'Penicillin',
            severity: 'moderate',
            notes: 'Causes rash',
            date_added: new Date()
          },
          {
            allergen: 'Shellfish',
            severity: 'mild',
            notes: 'Mild digestive upset',
            date_added: new Date()
          }
        ],
        chronic_conditions: [
          {
            condition: 'Mild Asthma',
            diagnosed_date: '2018-03-15',
            status: 'controlled',
            medications: ['Albuterol inhaler']
          }
        ],
        current_medications: [
          {
            name: 'Albuterol Inhaler',
            dosage: '90 mcg',
            frequency: 'As needed',
            start_date: '2018-03-15'
          }
        ],
        family_history: {
          mother: ['Diabetes Type 2', 'Hypertension'],
          father: ['Heart Disease'],
          siblings: ['None']
        },
        lifestyle: {
          smoking: 'never',
          alcohol: 'occasionally',
          exercise_frequency: 'regularly',
          diet: 'vegetarian'
        },
        emergency_contact_name: 'Jennifer Davis',
        emergency_contact_phone: '+1617555-0201',
        emergency_contact_relationship: 'sister',
        preferred_pharmacy: 'CVS Pharmacy - Boston Commons',
        insurance_provider: 'Blue Cross Blue Shield',
        insurance_id: 'BCBS123456789',
        notes: 'Patient is very health-conscious and exercises regularly.',
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        id: '99d3e4f5-a6b7-c890-1234-56789fghijkl',
        patient_id: '55f1a2b3-c4d5-e678-9012-3456789bcdef', // Robert Wilson
        blood_type: 'O-',
        height: 180.00, // 180 cm
        weight: 85.20,  // 85.2 kg
        allergies: [],
        chronic_conditions: [
          {
            condition: 'Hypertension',
            diagnosed_date: '2020-08-10',
            status: 'controlled',
            medications: ['Lisinopril']
          }
        ],
        current_medications: [
          {
            name: 'Lisinopril',
            dosage: '10mg',
            frequency: 'Once daily',
            start_date: '2020-08-10'
          }
        ],
        family_history: {
          mother: ['Hypertension', 'Osteoporosis'],
          father: ['Heart Disease', 'Diabetes Type 2'],
          siblings: ['Hypertension']
        },
        lifestyle: {
          smoking: 'former',
          alcohol: 'moderate',
          exercise_frequency: 'occasionally',
          diet: 'low_sodium'
        },
        emergency_contact_name: 'Mary Wilson',
        emergency_contact_phone: '+1415555-0202',
        emergency_contact_relationship: 'spouse',
        preferred_pharmacy: 'Walgreens - Castro Street',
        insurance_provider: 'Kaiser Permanente',
        insurance_id: 'KP987654321',
        notes: 'Patient quit smoking 2 years ago. Regular blood pressure monitoring.',
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        id: 'aae4f5a6-b7c8-d901-2345-6789ghijklmn',
        patient_id: '66a2b3c4-d5e6-f789-0123-456789cdefgh', // Lisa Anderson
        blood_type: 'B+',
        height: 158.00, // 158 cm
        weight: 52.30,  // 52.3 kg
        allergies: [
          {
            allergen: 'Latex',
            severity: 'moderate',
            notes: 'Contact dermatitis',
            date_added: new Date()
          }
        ],
        chronic_conditions: [],
        current_medications: [
          {
            name: 'Birth Control Pills',
            dosage: 'Standard dose',
            frequency: 'Daily',
            start_date: '2019-01-01'
          }
        ],
        family_history: {
          mother: ['Breast Cancer'],
          father: ['None significant'],
          siblings: ['None']
        },
        lifestyle: {
          smoking: 'never',
          alcohol: 'rarely',
          exercise_frequency: 'regularly',
          diet: 'balanced'
        },
        emergency_contact_name: 'Michael Anderson',
        emergency_contact_phone: '+1212555-0203',
        emergency_contact_relationship: 'father',
        preferred_pharmacy: 'Duane Reade - Upper West Side',
        insurance_provider: 'Aetna',
        insurance_id: 'AET456789123',
        notes: 'Family history of breast cancer - regular screening recommended.',
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        id: 'bbf5a6b7-c8d9-e012-3456-789hijklmnop',
        patient_id: '77b2c3d4-e5f6-a789-0123-456789defghi', // James Miller
        blood_type: 'AB+',
        height: 175.00, // 175 cm
        weight: 78.90,  // 78.9 kg
        allergies: [
          {
            allergen: 'Aspirin',
            severity: 'severe',
            notes: 'Gastrointestinal bleeding risk',
            date_added: new Date()
          }
        ],
        chronic_conditions: [
          {
            condition: 'Type 2 Diabetes',
            diagnosed_date: '2019-05-20',
            status: 'controlled',
            medications: ['Metformin']
          }
        ],
        current_medications: [
          {
            name: 'Metformin',
            dosage: '500mg',
            frequency: 'Twice daily',
            start_date: '2019-05-20'
          }
        ],
        family_history: {
          mother: ['Diabetes Type 2'],
          father: ['Heart Disease', 'Stroke'],
          siblings: ['Diabetes Type 2']
        },
        lifestyle: {
          smoking: 'never',
          alcohol: 'moderate',
          exercise_frequency: 'occasionally',
          diet: 'diabetic'
        },
        emergency_contact_name: 'Susan Miller',
        emergency_contact_phone: '+1773555-0204',
        emergency_contact_relationship: 'ex-spouse',
        preferred_pharmacy: 'Walgreens - Lincoln Park',
        insurance_provider: 'United Healthcare',
        insurance_id: 'UHC789123456',
        notes: 'Diabetes well-controlled with medication and diet. Regular A1C monitoring.',
        created_at: new Date(),
        updated_at: new Date()
      }
    ], {});
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.bulkDelete('health_profiles', null, {});
  }
};
