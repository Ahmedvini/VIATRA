import { Model } from 'sequelize';

export default (sequelize, DataTypes) => {
  class FoodLog extends Model {
    static associate(models) {
      // FoodLog belongs to User (patient)
      FoodLog.belongsTo(models.User, { 
        foreignKey: 'patient_id',
        as: 'patient'
      });
    }
    
    // Instance method for JSON serialization
    toJSON() {
      const values = { ...this.get() };
      return {
        id: values.id,
        patientId: values.patient_id,
        mealType: values.meal_type,
        foodName: values.food_name,
        description: values.description,
        imageUrl: values.image_url,
        nutrition: {
          calories: values.calories,
          protein: values.protein_grams,
          carbs: values.carbs_grams,
          fat: values.fat_grams,
          fiber: values.fiber_grams,
          sugar: values.sugar_grams,
          sodium: values.sodium_mg
        },
        aiAnalysis: values.ai_analysis,
        aiConfidence: values.ai_confidence,
        servingSize: values.serving_size,
        servingsCount: values.servings_count,
        consumedAt: values.consumed_at,
        createdAt: values.created_at,
        updatedAt: values.updated_at
      };
    }
  }

  FoodLog.init({
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    patient_id: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'users',
        key: 'id'
      }
    },
    meal_type: {
      type: DataTypes.ENUM('breakfast', 'lunch', 'dinner', 'snack'),
      allowNull: false
    },
    food_name: {
      type: DataTypes.STRING,
      allowNull: false
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    image_url: {
      type: DataTypes.STRING,
      allowNull: true
    },
    // Nutritional information
    calories: {
      type: DataTypes.FLOAT,
      allowNull: true
    },
    protein_grams: {
      type: DataTypes.FLOAT,
      allowNull: true
    },
    carbs_grams: {
      type: DataTypes.FLOAT,
      allowNull: true
    },
    fat_grams: {
      type: DataTypes.FLOAT,
      allowNull: true
    },
    fiber_grams: {
      type: DataTypes.FLOAT,
      allowNull: true
    },
    sugar_grams: {
      type: DataTypes.FLOAT,
      allowNull: true
    },
    sodium_mg: {
      type: DataTypes.FLOAT,
      allowNull: true
    },
    // AI Analysis
    ai_analysis: {
      type: DataTypes.JSONB,
      allowNull: true
    },
    ai_confidence: {
      type: DataTypes.FLOAT,
      allowNull: true
    },
    // Serving info
    serving_size: {
      type: DataTypes.STRING,
      allowNull: true
    },
    servings_count: {
      type: DataTypes.FLOAT,
      defaultValue: 1.0
    },
    // Timing
    consumed_at: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: DataTypes.NOW
    }
  }, {
    sequelize,
    modelName: 'FoodLog',
    tableName: 'food_logs',
    timestamps: true,
    underscored: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at'
  });

  return FoodLog;
};
