import FoodLog from '../models/FoodLog.js';
import geminiService from '../services/gemini/geminiService.js';
import { uploadToStorage } from '../services/storage.js';
import logger from '../config/logger.js';
import { Op } from 'sequelize';

/**
 * Analyze food image and create log entry
 */
export const analyzeFoodImage = async (req, res) => {
  try {
    const { meal_type, consumed_at, servings_count } = req.body;
    const userId = req.user.id;

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No image file provided'
      });
    }

    logger.info(`Analyzing food image for user ${userId}`);

    // Upload image to storage
    const imageUrl = await uploadToStorage(req.file, 'food-images');

    // Analyze image with Gemini AI
    const analysis = await geminiService.analyzeFoodImage(req.file.buffer);

    // Create food log entry
    const foodLog = await FoodLog.create({
      userId,
      mealType: meal_type || 'snack',
      foodName: analysis.foodName,
      description: analysis.description,
      imageUrl,
      calories: analysis.nutrition.calories,
      proteinGrams: analysis.nutrition.protein,
      carbsGrams: analysis.nutrition.carbs,
      fatGrams: analysis.nutrition.fat,
      fiberGrams: analysis.nutrition.fiber,
      sugarGrams: analysis.nutrition.sugar,
      sodiumMg: analysis.nutrition.sodium,
      aiAnalysis: analysis,
      aiConfidence: analysis.confidence,
      servingSize: analysis.servingSize,
      servingsCount: servings_count || 1.0,
      consumedAt: consumed_at || new Date()
    });

    logger.info(`Food log created: ${foodLog.id}`);

    res.status(201).json({
      success: true,
      message: 'Food analyzed and logged successfully',
      data: foodLog
    });
  } catch (error) {
    logger.error('Error analyzing food image:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to analyze food image',
      error: error.message
    });
  }
};

/**
 * Get food logs for user
 */
export const getFoodLogs = async (req, res) => {
  try {
    const userId = req.user.id;
    const { start_date, end_date, meal_type, limit = 50, offset = 0 } = req.query;

    const where = { userId };

    // Date range filter
    if (start_date || end_date) {
      where.consumedAt = {};
      if (start_date) where.consumedAt[Op.gte] = new Date(start_date);
      if (end_date) where.consumedAt[Op.lte] = new Date(end_date);
    }

    // Meal type filter
    if (meal_type) {
      where.mealType = meal_type;
    }

    const foodLogs = await FoodLog.findAll({
      where,
      order: [['consumedAt', 'DESC']],
      limit: parseInt(limit),
      offset: parseInt(offset)
    });

    const total = await FoodLog.count({ where });

    res.json({
      success: true,
      data: foodLogs,
      pagination: {
        total,
        limit: parseInt(limit),
        offset: parseInt(offset),
        hasMore: offset + foodLogs.length < total
      }
    });
  } catch (error) {
    logger.error('Error fetching food logs:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch food logs',
      error: error.message
    });
  }
};

/**
 * Get single food log by ID
 */
export const getFoodLogById = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const foodLog = await FoodLog.findOne({
      where: { id, userId }
    });

    if (!foodLog) {
      return res.status(404).json({
        success: false,
        message: 'Food log not found'
      });
    }

    res.json({
      success: true,
      data: foodLog
    });
  } catch (error) {
    logger.error('Error fetching food log:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch food log',
      error: error.message
    });
  }
};

/**
 * Update food log
 */
export const updateFoodLog = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;
    const updates = req.body;

    const foodLog = await FoodLog.findOne({
      where: { id, userId }
    });

    if (!foodLog) {
      return res.status(404).json({
        success: false,
        message: 'Food log not found'
      });
    }

    // Update allowed fields
    const allowedUpdates = [
      'mealType', 'foodName', 'description', 'servingsCount',
      'consumedAt', 'calories', 'proteinGrams', 'carbsGrams',
      'fatGrams', 'fiberGrams', 'sugarGrams', 'sodiumMg'
    ];

    allowedUpdates.forEach(field => {
      if (updates[field] !== undefined) {
        foodLog[field] = updates[field];
      }
    });

    await foodLog.save();

    logger.info(`Food log updated: ${id}`);

    res.json({
      success: true,
      message: 'Food log updated successfully',
      data: foodLog
    });
  } catch (error) {
    logger.error('Error updating food log:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update food log',
      error: error.message
    });
  }
};

/**
 * Delete food log
 */
export const deleteFoodLog = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const foodLog = await FoodLog.findOne({
      where: { id, userId }
    });

    if (!foodLog) {
      return res.status(404).json({
        success: false,
        message: 'Food log not found'
      });
    }

    await foodLog.destroy();

    logger.info(`Food log deleted: ${id}`);

    res.json({
      success: true,
      message: 'Food log deleted successfully'
    });
  } catch (error) {
    logger.error('Error deleting food log:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete food log',
      error: error.message
    });
  }
};

/**
 * Get nutrition summary for date range
 */
export const getNutritionSummary = async (req, res) => {
  try {
    const userId = req.user.id;
    const { start_date, end_date } = req.query;

    if (!start_date || !end_date) {
      return res.status(400).json({
        success: false,
        message: 'start_date and end_date are required'
      });
    }

    const foodLogs = await FoodLog.findAll({
      where: {
        userId,
        consumedAt: {
          [Op.gte]: new Date(start_date),
          [Op.lte]: new Date(end_date)
        }
      }
    });

    // Calculate totals
    const summary = {
      totalCalories: 0,
      totalProtein: 0,
      totalCarbs: 0,
      totalFat: 0,
      totalFiber: 0,
      totalSugar: 0,
      totalSodium: 0,
      mealBreakdown: {
        breakfast: { count: 0, calories: 0 },
        lunch: { count: 0, calories: 0 },
        dinner: { count: 0, calories: 0 },
        snack: { count: 0, calories: 0 }
      },
      dailyAverages: {}
    };

    foodLogs.forEach(log => {
      summary.totalCalories += log.calories || 0;
      summary.totalProtein += log.proteinGrams || 0;
      summary.totalCarbs += log.carbsGrams || 0;
      summary.totalFat += log.fatGrams || 0;
      summary.totalFiber += log.fiberGrams || 0;
      summary.totalSugar += log.sugarGrams || 0;
      summary.totalSodium += log.sodiumMg || 0;

      const mealType = log.mealType;
      summary.mealBreakdown[mealType].count++;
      summary.mealBreakdown[mealType].calories += log.calories || 0;
    });

    // Calculate daily averages
    const daysDiff = Math.ceil((new Date(end_date) - new Date(start_date)) / (1000 * 60 * 60 * 24)) + 1;
    summary.dailyAverages = {
      calories: Math.round(summary.totalCalories / daysDiff),
      protein: Math.round(summary.totalProtein / daysDiff),
      carbs: Math.round(summary.totalCarbs / daysDiff),
      fat: Math.round(summary.totalFat / daysDiff)
    };

    res.json({
      success: true,
      data: {
        summary,
        totalLogs: foodLogs.length,
        dateRange: { start_date, end_date, days: daysDiff }
      }
    });
  } catch (error) {
    logger.error('Error calculating nutrition summary:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to calculate nutrition summary',
      error: error.message
    });
  }
};
