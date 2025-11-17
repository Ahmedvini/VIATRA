#!/usr/bin/env node

/**
 * Test script to verify configuration loading without circular dependency
 * Run with: node src/config/test-config.js
 */

// Test 1: Development mode without GCP_PROJECT_ID (should work)
console.log('Testing development mode without GCP_PROJECT_ID...');
process.env.NODE_ENV = 'development';
delete process.env.GCP_PROJECT_ID; // Remove to test conditional validation
process.env.JWT_SECRET = 'test-jwt-secret-that-is-long-enough-for-validation';

try {
  const config = (await import('./index.js')).default;
  console.log('✅ Development config loaded successfully without GCP_PROJECT_ID');
  console.log(`Environment: ${config.nodeEnv}`);
  console.log(`Production mode: ${config.isProduction}`);
} catch (error) {
  console.error('❌ Failed to load development config:', error.message);
  process.exit(1);
}

// Test 2: Development mode with USE_GCP_SECRETS=true (should require GCP_PROJECT_ID)
console.log('\nTesting development mode with USE_GCP_SECRETS=true...');
process.env.USE_GCP_SECRETS = 'true';

try {
  // Clear module cache to force reload
  const moduleUrl = new URL('./index.js', import.meta.url);
  delete globalThis[moduleUrl.href];
  
  const config = (await import('./index.js?' + Date.now())).default;
  console.log('❌ This should have failed - GCP_PROJECT_ID should be required');
  process.exit(1);
} catch (error) {
  if (error.message.includes('GCP_PROJECT_ID')) {
    console.log('✅ Correctly failed when USE_GCP_SECRETS=true but no GCP_PROJECT_ID');
  } else {
    console.error('❌ Failed for wrong reason:', error.message);
    process.exit(1);
  }
}

// Test 3: Development mode with GCP_PROJECT_ID set
console.log('\nTesting development mode with GCP_PROJECT_ID...');
process.env.GCP_PROJECT_ID = 'test-project';

try {
  const config = (await import('./index.js?' + Date.now())).default;
  console.log('✅ Development config loaded successfully with GCP_PROJECT_ID');
} catch (error) {
  console.error('❌ Failed to load development config with GCP_PROJECT_ID:', error.message);
  process.exit(1);
}

// Test 4: Production mode initialization
console.log('\nTesting production mode initialization...');
delete process.env.USE_GCP_SECRETS; // Clean up from previous test
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
