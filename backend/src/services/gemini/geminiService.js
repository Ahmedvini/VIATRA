import { GoogleGenerativeAI } from '@google/generative-ai';
import logger from '../../config/logger.js';

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
        logger.warn('Gemini API key not configured - returning fallback response');
        // Return a fallback response instead of throwing error
        return {
          foodName: 'Food Item (Manual Entry Required)',
          description: 'AI analysis unavailable. Please enter details manually.',
          servingSize: '1 serving',
          nutrition: {
            calories: 0,
            protein: 0,
            carbs: 0,
            fat: 0,
            fiber: 0,
            sugar: 0,
            sodium: 0,
          },
          confidence: 0.0,
          foodItems: [],
          error: 'Gemini API key not configured'
        };
      }

      // Use Gemini 2.0 Flash model (stable, fast, supports vision)
      // Gemini 2.0 models support enhanced object detection
      const model = this.genAI.getGenerativeModel({ model: 'gemini-2.0-flash-exp' });

      const prompt = `You are a nutrition analysis AI. Analyze this food image and extract precise nutritional information for database storage.

CRITICAL INSTRUCTIONS:
1. Respond ONLY with valid JSON - no markdown, no backticks, no additional text
2. Identify ALL food items visible in the image
3. Estimate portion sizes accurately based on visual cues
4. Calculate total nutrition values by summing all food items
5. Be conservative with estimates - better to underestimate than overestimate
6. If uncertain, provide your best estimate but lower the confidence score

Required JSON Response Format:
{
  "foodName": "Brief descriptive name of the meal (e.g., 'Chicken Salad Bowl', 'Breakfast Plate')",
  "description": "Detailed description of all foods visible: list each item with estimated quantity",
  "servingSize": "Total estimated serving size (e.g., '1 large bowl', '2 cups', '350g')",
  "nutrition": {
    "calories": <number: total calories for entire meal>,
    "protein": <number: total protein in grams>,
    "carbs": <number: total carbohydrates in grams>,
    "fat": <number: total fat in grams>,
    "fiber": <number: total fiber in grams, can be 0>,
    "sugar": <number: total sugar in grams, can be 0>,
    "sodium": <number: total sodium in milligrams, can be 0>
  },
  "confidence": <number between 0 and 1: your confidence in this analysis>,
  "foodItems": [
    {
      "name": "Food item 1 name",
      "quantity": "estimated amount (e.g., '150g', '1 cup')",
      "calories": <number>
    }
  ]
}

IMPORTANT EXTRACTION RULES FOR DATABASE:
- foodName: Keep it under 100 characters, descriptive but concise
- description: Full details of what you see, list all ingredients
- servingSize: Be specific (use grams, cups, bowls, plates, etc.)
- nutrition.calories: INTEGER, total for entire meal
- nutrition.protein: DECIMAL, in grams
- nutrition.carbs: DECIMAL, in grams  
- nutrition.fat: DECIMAL, in grams
- nutrition.fiber: DECIMAL, in grams (0 if unknown)
- nutrition.sugar: DECIMAL, in grams (0 if unknown)
- nutrition.sodium: INTEGER, in milligrams (0 if unknown)
- confidence: DECIMAL between 0.0 and 1.0
- foodItems: Array of individual food components for transparency

COMMON PORTION REFERENCES:
- 1 cup = ~240ml
- 1 palm-sized protein = ~100-150g = ~150-250 calories
- 1 fist-sized carb = ~150-200g = ~150-250 calories
- 1 thumb of fat = ~15g = ~100-150 calories
- Large dinner plate = ~400-600g total
- Bowl = ~300-400g

Analyze the image now and respond with ONLY the JSON object.`;

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
        // Remove markdown code blocks if present
        let cleanedText = text.trim();
        if (cleanedText.startsWith('```json')) {
          cleanedText = cleanedText.replace(/```json\n?/g, '').replace(/```\n?/g, '');
        } else if (cleanedText.startsWith('```')) {
          cleanedText = cleanedText.replace(/```\n?/g, '');
        }

        // Try to extract JSON from response
        const jsonMatch = cleanedText.match(/\{[\s\S]*\}/);
        if (jsonMatch) {
          analysisData = JSON.parse(jsonMatch[0]);
        } else {
          analysisData = JSON.parse(cleanedText);
        }

        // Validate and normalize the response
        if (!analysisData.foodName || !analysisData.nutrition) {
          throw new Error('Invalid response format from Gemini');
        }

        // Ensure all required nutrition fields exist
        analysisData.nutrition = {
          calories: analysisData.nutrition.calories || 0,
          protein: analysisData.nutrition.protein || 0,
          carbs: analysisData.nutrition.carbs || 0,
          fat: analysisData.nutrition.fat || 0,
          fiber: analysisData.nutrition.fiber || 0,
          sugar: analysisData.nutrition.sugar || 0,
          sodium: analysisData.nutrition.sodium || 0,
        };

        // Ensure confidence is between 0 and 1
        if (!analysisData.confidence || analysisData.confidence > 1) {
          analysisData.confidence = 0.7;
        }

        logger.info('Successfully parsed Gemini response', {
          foodName: analysisData.foodName,
          calories: analysisData.nutrition.calories,
          confidence: analysisData.confidence,
        });

      } catch (parseError) {
        logger.error('Failed to parse Gemini response as JSON', {
          error: parseError.message,
          rawResponse: text.substring(0, 500),
        });

        // Fallback: create structured response from text
        analysisData = {
          foodName: 'Unknown Food',
          description: 'Unable to analyze food accurately. Please try with a clearer image.',
          servingSize: 'Unknown',
          nutrition: {
            calories: 0,
            protein: 0,
            carbs: 0,
            fat: 0,
            fiber: 0,
            sugar: 0,
            sodium: 0,
          },
          confidence: 0.3,
          foodItems: [],
          rawAnalysis: text,
        };
      }

      return analysisData;
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
