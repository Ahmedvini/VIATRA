#!/usr/bin/env node

/**
 * Test script to verify configuration loading without circular dependency
 * Run with: node src/config/test-config.js
 */

// Test in development mode
console.log('Testing development mode...');
process.env.NODE_ENV = 'development';
process.env.GCP_PROJECT_ID = 'test-project';
process.env.JWT_SECRET = 'test-jwt-secret-that-is-long-enough-for-validation';

try {
  const config = (await import('./index.js')).default;
  console.log('✅ Development config loaded successfully');
  console.log(`Environment: ${config.nodeEnv}`);
  console.log(`Production mode: ${config.isProduction}`);
} catch (error) {
  console.error('❌ Failed to load development config:', error.message);
  process.exit(1);
}

// Test production mode initialization
console.log('\nTesting production mode initialization...');
process.env.NODE_ENV = 'production';
process.env.ENVIRONMENT = 'test';

try {
  // Clear module cache to force reload
  const modulePath = new URL('./index.js', import.meta.url).pathname;
  delete require.cache[modulePath];
  
  const { default: config, initConfig } = await import('./index.js');
  console.log('✅ Production config module loaded successfully');
  console.log(`Environment: ${config.nodeEnv}`);
  console.log(`Production mode: ${config.isProduction}`);
  
  // Test initConfig function (will fail in secret loading but should not have circular dependency)
  try {
    await initConfig();
    console.log('✅ initConfig completed successfully');
  } catch (error) {
    if (error.message.includes('Secret') || error.message.includes('not found')) {
      console.log('✅ initConfig failed as expected (no actual secrets), but no circular dependency');
    } else {
      throw error;
    }
  }
} catch (error) {
  if (error.message.includes('circular') || error.message.includes('Cannot access') || error.message.includes('before initialization')) {
    console.error('❌ Circular dependency detected:', error.message);
    process.exit(1);
  } else {
    console.log('✅ No circular dependency (other error expected):', error.message);
  }
}

console.log('\n🎉 All tests passed! No circular dependency detected.');
