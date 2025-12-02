// Script to list all available Gemini models
import { GoogleGenerativeAI } from '@google/generative-ai';
import dotenv from 'dotenv';

dotenv.config();

async function listModels() {
  const apiKey = process.env.GEMINI_API_KEY;
  
  if (!apiKey) {
    console.error('❌ GEMINI_API_KEY not found in environment variables');
    process.exit(1);
  }

  console.log('🔍 Checking available Gemini models...\n');

  const genAI = new GoogleGenerativeAI(apiKey);

  try {
    // List all models
    const models = await genAI.listModels();
    
    console.log('✅ Available Models:\n');
    
    for await (const model of models) {
      console.log('📦 Model:', model.name);
      console.log('   Display Name:', model.displayName);
      console.log('   Description:', model.description);
      console.log('   Supported Methods:', model.supportedGenerationMethods.join(', '));
      console.log('   Input Token Limit:', model.inputTokenLimit);
      console.log('   Output Token Limit:', model.outputTokenLimit);
      console.log('');
    }

    // Filter for vision-capable models
    console.log('\n🎨 Vision-Capable Models (support generateContent with images):');
    console.log('─'.repeat(70));
    
    for await (const model of models) {
      if (model.supportedGenerationMethods.includes('generateContent')) {
        console.log(`✓ ${model.name}`);
        console.log(`  ${model.displayName} - ${model.description}`);
      }
    }

  } catch (error) {
    console.error('❌ Error listing models:', error.message);
    console.error('Full error:', error);
  }
}

listModels();
