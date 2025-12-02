import { DataTypes } from 'sequelize';
import { sequelize } from '../config/database.js';

const FoodLog = sequelize.define('FoodLog', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  userId: {
    type: DataTypes.UUID,
    allowNull: false,
    field: 'user_id'
  },
  mealType: {
    type: DataTypes.ENUM('breakfast', 'lunch', 'dinner', 'snack'),
    allowNull: false,
    field: 'meal_type'
  },
  foodName: {
    type: DataTypes.STRING,
    allowNull: false,
    field: 'food_name'
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  imageUrl: {
    type: DataTypes.STRING,
    allowNull: true,
    field: 'image_url'
  },
  // Nutritional information
  calories: {
    type: DataTypes.FLOAT,
    allowNull: true
  },
  proteinGrams: {
    type: DataTypes.FLOAT,
    allowNull: true,
    field: 'protein_grams'
  },
  carbsGrams: {
    type: DataTypes.FLOAT,
    allowNull: true,
    field: 'carbs_grams'
  },
  fatGrams: {
    type: DataTypes.FLOAT,
    allowNull: true,
    field: 'fat_grams'
  },
  fiberGrams: {
    type: DataTypes.FLOAT,
    allowNull: true,
    field: 'fiber_grams'
  },
  sugarGrams: {
    type: DataTypes.FLOAT,
    allowNull: true,
    field: 'sugar_grams'
  },
  sodiumMg: {
    type: DataTypes.FLOAT,
    allowNull: true,
    field: 'sodium_mg'
  },
  // AI Analysis
  aiAnalysis: {
    type: DataTypes.JSONB,
    allowNull: true,
    field: 'ai_analysis'
  },
  aiConfidence: {
    type: DataTypes.FLOAT,
    allowNull: true,
    field: 'ai_confidence'
  },
  // Serving info
  servingSize: {
    type: DataTypes.STRING,
    allowNull: true,
    field: 'serving_size'
  },
  servingsCount: {
    type: DataTypes.FLOAT,
    defaultValue: 1.0,
    field: 'servings_count'
  },
  // Timing
  consumedAt: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,
    field: 'consumed_at'
  }
}, {
  tableName: 'food_logs',
  timestamps: true,
  underscored: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at'
});

// Instance methods
FoodLog.prototype.toJSON = function() {
  const values = { ...this.get() };
  return {
    id: values.id,
    userId: values.userId,
    mealType: values.mealType,
    foodName: values.foodName,
    description: values.description,
    imageUrl: values.imageUrl,
    nutrition: {
      calories: values.calories,
      protein: values.proteinGrams,
      carbs: values.carbsGrams,
      fat: values.fatGrams,
      fiber: values.fiberGrams,
      sugar: values.sugarGrams,
      sodium: values.sodiumMg
    },
    aiAnalysis: values.aiAnalysis,
    aiConfidence: values.aiConfidence,
    servingSize: values.servingSize,
    servingsCount: values.servingsCount,
    consumedAt: values.consumedAt,
    createdAt: values.createdAt,
    updatedAt: values.updatedAt
  };
};

export default FoodLog;
