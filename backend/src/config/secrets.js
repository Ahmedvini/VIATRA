import { SecretManagerServiceClient } from '@google-cloud/secret-manager';

// Create Secret Manager client
const client = new SecretManagerServiceClient();

// Cache for secrets to avoid repeated API calls
const secretsCache = new Map();
const CACHE_TTL = 300000; // 5 minutes

// Get secret from Google Secret Manager
export const getSecret = async (secretName, projectId = null) => {
  try {
    // Check cache first
    const cached = secretsCache.get(secretName);
    if (cached && Date.now() - cached.timestamp < CACHE_TTL) {
      return cached.value;
    }
    
    // Use provided projectId or get from environment
    const gcpProjectId = projectId || process.env.GCP_PROJECT_ID;
    if (!gcpProjectId) {
      throw new Error('GCP_PROJECT_ID is required to access secrets');
    }
    
    // Construct the resource name
    const name = `projects/${gcpProjectId}/secrets/${secretName}/versions/latest`;
    
    // Access the secret version
    const [version] = await client.accessSecretVersion({ name });
    
    // Extract the payload
    const payload = version.payload.data.toString('utf8');
    
    // Cache the secret
    secretsCache.set(secretName, {
      value: payload,
      timestamp: Date.now()
    });
    
    return payload;
  } catch (error) {
    console.error(`Failed to get secret ${secretName}:`, error);
    throw new Error(`Secret ${secretName} not found or inaccessible`);
  }
};

// Get JSON secret (for structured secrets like API keys)
export const getJsonSecret = async (secretName) => {
  try {
    const secretValue = await getSecret(secretName);
    return JSON.parse(secretValue);
  } catch (error) {
    console.error(`Failed to parse JSON secret ${secretName}:`, error);
    throw new Error(`Secret ${secretName} is not valid JSON`);
  }
};

// Clear secrets cache (useful for testing or manual refresh)
export const clearSecretsCache = () => {
  secretsCache.clear();
};

// Check if running in local development
export const isLocalDevelopment = () => {
  return process.env.NODE_ENV !== 'production' || 
         process.env.LOCAL_DEVELOPMENT === 'true';
};

// Helper to get secret with fallback to environment variable
export const getSecretOrEnv = async (secretName, envVarName, projectId = null) => {
  if (isLocalDevelopment()) {
    return process.env[envVarName];
  }
  
  try {
    return await getSecret(secretName, projectId);
  } catch (error) {
    console.warn(`Failed to get secret ${secretName}, falling back to env var ${envVarName}`);
    return process.env[envVarName];
  }
};
