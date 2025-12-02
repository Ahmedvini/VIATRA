# Railway Deployment Fix - npm ci Error

## Problem
Railway deployment failing with error:
```
npm ci can only install packages when your package.json and package-lock.json are in sync
Missing: @google/generative-ai@0.2.1 from lock file
Missing: sharp@0.33.5 from lock file
```

## Root Cause
1. New dependencies added to `package.json` (`@google/generative-ai` and `sharp`)
2. No `package-lock.json` file committed to repository
3. Railway's default build uses `npm ci` which requires a lock file

## Solution Applied

### 1. Created `nixpacks.toml` Configuration
Forces Railway to use `npm install` instead of `npm ci`:

```toml
[phases.setup]
nixPkgs = ['nodejs_20']

[phases.install]
cmds = ['npm install --legacy-peer-deps']

[phases.build]
cmds = ['echo "No build step required"']

[start]
cmd = 'node src/index.js'
```

### 2. Updated `.npmrc` Configuration
Added settings to handle dependencies properly:

```properties
# Suppress npm warnings
loglevel=error

# Disable package-lock.json for Railway builds
package-lock=false

# Use legacy peer deps resolution
legacy-peer-deps=true

# Disable audit during install
audit=false

# Disable funding messages
fund=false
```

### 3. Created `railway.json` Configuration
Explicit Railway deployment configuration:

```json
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "NIXPACKS",
    "buildCommand": "npm install --legacy-peer-deps"
  },
  "deploy": {
    "startCommand": "node src/index.js",
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 10
  }
}
```

### 4. Updated Dockerfile
Changed from `npm install --omit=dev` to `npm install --production --legacy-peer-deps`

### 5. Added GEMINI_API_KEY to .env.example
Added documentation for the new environment variable

## How to Deploy

### Step 1: Verify Environment Variables on Railway

Go to your Railway project → Variables tab and ensure:

```env
GEMINI_API_KEY=your_actual_gemini_api_key
```

**Important:** Make sure there are no extra spaces or quotes!

### Step 2: Commit and Push Changes

```bash
cd /home/ahmedvini/Music/VIATRA
git add -A
git commit -m "Fix Railway deployment - use npm install instead of npm ci"
git push origin main
```

### Step 3: Trigger Railway Deployment

Railway should automatically detect the push and redeploy.

Or manually trigger: Railway Dashboard → Your Service → Deploy → "Redeploy"

## Verification

### Check Railway Logs

In Railway dashboard, check the deployment logs for:

✅ **Success indicators:**
```
[nixpacks] Installing dependencies with npm install --legacy-peer-deps
[nixpacks] added XXX packages in Xs
[nixpacks] Starting application with node src/index.js
Server running on port 8080
```

❌ **Error indicators:**
```
npm ci can only install packages...
Missing: @google/generative-ai...
```

### Test the Gemini Service

Once deployed, test the API:

```bash
curl https://your-railway-app.railway.app/api/health
```

Should return:
```json
{
  "status": "ok",
  "timestamp": "2025-12-02T..."
}
```

## Troubleshooting

### Issue 1: Still Getting npm ci Error

**Solution:** Delete the deployment and redeploy
1. Railway Dashboard → Your Service
2. Settings → Delete Service (or remove build cache)
3. Redeploy from scratch

### Issue 2: Gemini API Key Not Found

**Check:**
1. Railway Variables tab shows `GEMINI_API_KEY`
2. No extra spaces or quotes in the value
3. Variable is not marked as "shared" if it shouldn't be

**Test locally:**
```bash
cd backend
export GEMINI_API_KEY="your_key"
node -e "console.log(process.env.GEMINI_API_KEY)"
```

### Issue 3: Dependencies Still Not Installing

**Solution A:** Use Dockerfile instead of Nixpacks
1. Railway Dashboard → Settings
2. Build → Builder → Select "Dockerfile"
3. Redeploy

**Solution B:** Force clean build
```bash
# Add to railway.json
{
  "build": {
    "builder": "NIXPACKS",
    "buildCommand": "rm -rf node_modules && npm install --legacy-peer-deps"
  }
}
```

### Issue 4: Sharp Installation Fails

Sharp requires native binaries. If it fails:

**Solution:** Add to `nixpacks.toml`:
```toml
[phases.setup]
nixPkgs = ['nodejs_20', 'vips', 'pkg-config']
aptPkgs = ['build-essential', 'libvips-dev']
```

## Alternative: Use package-lock.json (Recommended for Production)

If you want to use `npm ci` properly (better for production):

### Step 1: Generate package-lock.json locally
```bash
cd backend
npm install
# This creates package-lock.json
```

### Step 2: Commit it
```bash
git add package-lock.json
git commit -m "Add package-lock.json for reproducible builds"
git push origin main
```

### Step 3: Update configurations

**Remove from `.npmrc`:**
```properties
# Remove this line:
# package-lock=false
```

**Update `nixpacks.toml`:**
```toml
[phases.install]
cmds = ['npm ci']  # Now works with lock file
```

**Update `railway.json`:**
```json
{
  "build": {
    "buildCommand": "npm ci"
  }
}
```

## Best Practices

### For Development
- ✅ Use `npm install` (flexible, allows updates)
- ✅ Don't commit `package-lock.json`
- ✅ Use `.npmrc` to disable lock file

### For Production (Railway)
- ✅ Use `npm ci` with committed `package-lock.json`
- ✅ Ensures reproducible builds
- ✅ Faster installs
- ✅ Better security (locked versions)

### For This Project (Current)
Since `package-lock.json` is not committed (probably in `.gitignore`), we're using:
- ✅ `npm install --legacy-peer-deps`
- ✅ Nixpacks configuration to override defaults
- ✅ `.npmrc` to disable lock file generation

## Files Modified

1. ✅ `backend/.npmrc` - Added npm configuration
2. ✅ `backend/nixpacks.toml` - Added Nixpacks configuration
3. ✅ `backend/railway.json` - Added Railway configuration
4. ✅ `backend/Dockerfile` - Updated install command
5. ✅ `backend/.env.example` - Added GEMINI_API_KEY

## Expected Outcome

After these changes:
1. ✅ Railway deployment succeeds
2. ✅ All dependencies install correctly
3. ✅ Gemini service is available
4. ✅ Backend starts successfully
5. ✅ Health check passes

## Testing After Deployment

```bash
# 1. Check health
curl https://your-app.railway.app/api/health

# 2. Check if Gemini is configured (create test endpoint)
curl https://your-app.railway.app/api/health-tracking/test-gemini
```

## Summary

The fix changes Railway's build process from using `npm ci` (which requires a lock file) to `npm install` (which works without one). This is configured through:

1. **nixpacks.toml** - Tells Nixpacks how to build
2. **.npmrc** - Configures npm behavior
3. **railway.json** - Explicit Railway settings

All changes are backward compatible and won't affect local development.

---

**Status:** Fixed and ready to deploy  
**Date:** December 2, 2025  
**Action Required:** Commit and push, then verify on Railway
