import { GoogleGenerativeAI } from '@google/generative-ai';
import logger from '../utils/logger.js';

class GeminiService {
  constructor() {
    if (!process.env.GEMINI_API_KEY) {
      logger.warn('GEMINI_API_KEY not found in environment variables');
      this.genAI = null;
    } else {
      this.genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
    }
  }

  /**
   * Analyze food image and return nutritional information
   * @param {Buffer} imageBuffer - Image buffer
   * @param {string} mimeType - Image MIME type
   * @returns {Promise<Object>} Nutritional analysis
   */
  async analyzeFoodImage(imageBuffer, mimeType = 'image/jpeg') {
    try {
      if (!this.genAI) {
        throw new Error('Gemini API key not configured');
      }

      // Use Gemini Pro Vision model
      const model = this.genAI.getGenerativeModel({ model: 'gemini-pro-vision' });

      const prompt = `Analyze this food image and provide detailed nutritional information.

IMPORTANT: Respond ONLY with valid JSON, no additional text.

{
  "foods": [
    {
      "name": "food item name",
      "portionSize": "estimated size (e.g., 150g, 1 cup)",
      "calories": estimated calories as number,
      "confidence": confidence level 0-1
    }
  ],
  "totalCalories": total estimated calories as number,
  "macronutrients": {
    "carbohydrates": {
      "grams": number,
      "percentage": number
    },
    "fats": {
      "grams": number,
      "percentage": number
    },
    "proteins": {
      "grams": number,
      "percentage": number
    }
  },
  "categories": {
    "fruits": {
      "grams": number,
      "percentage": number,
      "items": ["fruit names"]
    },
    "vegetables": {
      "grams": number,
      "percentage": number,
      "items": ["vegetable names"]
    },
    "grains": {
      "grams": number,
      "percentage": number,
      "items": ["grain names"]
    },
    "dairy": {
      "grams": number,
      "percentage": number,
      "items": ["dairy names"]
    },
    "meat": {
      "grams": number,
      "percentage": number,
      "items": ["meat names"]
    }
  },
  "healthScore": number 0-100,
  "suggestions": ["health suggestions"],
  "warnings": ["allergy/health warnings if any"]
}

Be as accurate as possible with portion sizes and calories. If unsure, provide ranges.`;

      const imageParts = [
        {
          inlineData: {
            data: imageBuffer.toString('base64'),
            mimeType: mimeType,
          },
        },
      ];

      const result = await model.generateContent([prompt, ...imageParts]);
      const response = await result.response;
      const text = response.text();

      logger.info('Gemini raw response received', {
        responseLength: text.length,
      });

      // Parse JSON response
      let analysisData;
      try {
        // Try to extract JSON from response
        const jsonMatch = text.match(/\{[\s\S]*\}/);
        if (jsonMatch) {
          analysisData = JSON.parse(jsonMatch[0]);
        } else {
          analysisData = JSON.parse(text);
        }
      } catch (parseError) {
        logger.error('Failed to parse Gemini response as JSON', {
          error: parseError.message,
          rawResponse: text,
        });

        // Fallback: create structured response from text
        analysisData = {
          foods: [
            {
              name: 'Various food items',
              portionSize: 'Unknown',
              calories: 0,
              confidence: 0.5,
            },
          ],
          totalCalories: 0,
          macronutrients: {
            carbohydrates: { grams: 0, percentage: 0 },
            fats: { grams: 0, percentage: 0 },
            proteins: { grams: 0, percentage: 0 },
          },
          categories: {
            fruits: { grams: 0, percentage: 0, items: [] },
            vegetables: { grams: 0, percentage: 0, items: [] },
            grains: { grams: 0, percentage: 0, items: [] },
            dairy: { grams: 0, percentage: 0, items: [] },
            meat: { grams: 0, percentage: 0, items: [] },
          },
          healthScore: 50,
          suggestions: ['Unable to analyze food accurately. Please try again with a clearer image.'],
          warnings: [],
          rawAnalysis: text,
        };
      }

      return {
        success: true,
        data: analysisData,
        rawResponse: text,
      };
    } catch (error) {
      logger.error('Error analyzing food image with Gemini', {
        error: error.message,
        stack: error.stack,
      });

      throw new Error(`Failed to analyze food image: ${error.message}`);
    }
  }

  /**
   * Generate sleep quality insights
   * @param {Object} sleepData - Sleep session data
   * @returns {Promise<Object>} Sleep insights
   */
  async generateSleepInsights(sleepData) {
    try {
      if (!this.genAI) {
        throw new Error('Gemini API key not configured');
      }

      const model = this.genAI.getGenerativeModel({ model: 'gemini-pro' });

      const prompt = `Analyze this sleep data and provide insights:

Sleep Duration: ${sleepData.durationHours} hours
Interruptions: ${sleepData.interruptions} times
Quality Rating: ${sleepData.qualityRating}/5
Sleep Pattern (last 7 days): ${JSON.stringify(sleepData.recentPattern)}

Provide response in JSON format:
{
  "quality": "Excellent/Good/Fair/Poor",
  "insights": ["key insight 1", "key insight 2"],
  "recommendations": ["recommendation 1", "recommendation 2"],
  "concerns": ["concern 1", "concern 2"] or [],
  "score": number 0-100
}`;

      const result = await model.generateContent(prompt);
      const response = await result.response;
      const text = response.text();

      let insightsData;
      try {
        const jsonMatch = text.match(/\{[\s\S]*\}/);
        insightsData = JSON.parse(jsonMatch ? jsonMatch[0] : text);
      } catch (parseError) {
        logger.error('Failed to parse sleep insights', {
          error: parseError.message,
        });

        insightsData = {
          quality: 'Unknown',
          insights: ['Unable to generate insights at this time.'],
          recommendations: ['Try to maintain a consistent sleep schedule.'],
          concerns: [],
          score: 50,
        };
      }

      return {
        success: true,
        data: insightsData,
      };
    } catch (error) {
      logger.error('Error generating sleep insights', {
        error: error.message,
      });

      throw new Error(`Failed to generate sleep insights: ${error.message}`);
    }
  }

  /**
   * Generate health dashboard insights
   * @param {Object} healthData - Compiled health data
   * @returns {Promise<Object>} Dashboard insights
   */
  async generateDashboardInsights(healthData) {
    try {
      if (!this.genAI) {
        throw new Error('Gemini API key not configured');
      }

      const model = this.genAI.getGenerativeModel({ model: 'gemini-pro' });

      const prompt = `Analyze this patient's health data and provide insights:

Recent Food Logs: ${JSON.stringify(healthData.foodLogs)}
Recent Sleep Logs: ${JSON.stringify(healthData.sleepLogs)}
Weight Data: ${JSON.stringify(healthData.weightData)}
Water Intake: ${healthData.averageWaterIntake} ml/day
Allergies: ${healthData.allergies.join(', ') || 'None'}
Chronic Diseases: ${healthData.chronicDiseases.join(', ') || 'None'}

Provide comprehensive health insights in JSON format:
{
  "overallHealth": "Excellent/Good/Fair/Needs Attention",
  "score": number 0-100,
  "strengths": ["strength 1", "strength 2"],
  "improvements": ["area to improve 1", "area to improve 2"],
  "recommendations": ["actionable recommendation 1", "actionable recommendation 2"],
  "warnings": ["warning 1"] or [],
  "trends": {
    "nutrition": "improving/stable/declining",
    "sleep": "improving/stable/declining",
    "hydration": "good/moderate/poor"
  }
}`;

      const result = await model.generateContent(prompt);
      const response = await result.response;
      const text = response.text();

      let insightsData;
      try {
        const jsonMatch = text.match(/\{[\s\S]*\}/);
        insightsData = JSON.parse(jsonMatch ? jsonMatch[0] : text);
      } catch (parseError) {
        logger.error('Failed to parse dashboard insights', {
          error: parseError.message,
        });

        insightsData = {
          overallHealth: 'Good',
          score: 70,
          strengths: ['Maintaining health tracking'],
          improvements: ['Continue monitoring'],
          recommendations: ['Keep up the good work with health tracking'],
          warnings: [],
          trends: {
            nutrition: 'stable',
            sleep: 'stable',
            hydration: 'moderate',
          },
        };
      }

      return {
        success: true,
        data: insightsData,
      };
    } catch (error) {
      logger.error('Error generating dashboard insights', {
        error: error.message,
      });

      throw new Error(`Failed to generate dashboard insights: ${error.message}`);
    }
  }
}

export default new GeminiService();
