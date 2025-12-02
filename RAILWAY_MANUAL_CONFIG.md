# 🚨 URGENT: Railway Dashboard Manual Configuration Required

## Problem
Railway is using **Railpack** auto-detection which forces `npm ci`, ignoring our configurations.

## Solution
Manually configure Railway to use the **Dockerfile** builder instead.

---

## 📋 Step-by-Step Instructions

### 1. Go to Railway Dashboard
1. Open your Railway project: https://railway.app/project/your-project-id
2. Click on the **viatra-backend** service

### 2. Change Build Settings
1. Click on **"Settings"** tab (left sidebar)
2. Scroll to **"Build"** section
3. Click **"Configure"** or **"Custom Build Command"**

### 3. Set Builder to Dockerfile

**Option A: Via Settings UI**
- In the Build section, look for **"Builder"** or **"Build Method"**
- Change from "Auto-detect" or "Railpack" to **"Dockerfile"**
- Set Dockerfile path to: `backend/Dockerfile`
- Or just: `Dockerfile` (if Railway auto-detects the backend folder)

**Option B: Via Root Directory Setting**
- Set **"Root Directory"** to: `backend`
- This tells Railway to build from the backend directory
- Railway will then find and use the `Dockerfile` in that directory

### 4. Remove Custom Install Command (if present)
- In Build settings, if there's a custom "Install Command", **remove it**
- The Dockerfile will handle all installations

### 5. Verify Start Command
- In **"Deploy"** section
- **Start Command** should be: `node src/index.js`
- Or remove it (let Railway use Dockerfile's CMD)

---

## 🎯 Expected Configuration

After making changes, your Railway settings should show:

```
Build:
  Builder: Dockerfile
  Dockerfile Path: backend/Dockerfile (or just Dockerfile)
  Root Directory: backend (optional, helps Railway find files)
  
Deploy:
  Start Command: node src/index.js (or default from Dockerfile)
  Restart Policy: On Failure
  Max Retries: 10
```

---

## 📸 Visual Guide (Based on Your Screenshot)

From your screenshot, I can see:

**Current Settings (INCORRECT):**
- Builder: Railpack (auto-detected)
- Install: `npm ci` ❌
- Build: `npm run build --workspace=viatra-backend`

**Target Settings (CORRECT):**
- Builder: **Dockerfile**
- Root Directory: **backend**
- Dockerfile Path: **Dockerfile** (or backend/Dockerfile)
- Build command: (not needed, Dockerfile handles it)
- Start command: **npm run start --workspace=viatra-backend** OR **node src/index.js**

---

## 🔧 Alternative: Use Railway CLI

If the UI is confusing, use Railway CLI:

```bash
# Install Railway CLI (if not installed)
npm install -g railway

# Login
railway login

# Link to your project
railway link

# Deploy from backend directory
cd /home/ahmedvini/Music/VIATRA/backend
railway up --dockerfile Dockerfile
```

---

## ⚙️ Settings Location in Railway Dashboard

1. **Main Dashboard** → Click your project
2. **Service View** → Click "viatra-backend" service
3. **Left Sidebar** → Click "Settings"
4. **Build Section** → Look for:
   - "Builder" dropdown
   - "Root Directory" input
   - "Dockerfile Path" input
   - "Build Command" input (remove if present)

---

## ✅ Verification After Changes

After you make the changes and trigger a new deployment:

### 1. Check Build Logs
You should see:
```
✓ Using Dockerfile builder
✓ Building from backend/Dockerfile
✓ Step 1/15 : FROM node:20-alpine AS builder
✓ npm install --production --legacy-peer-deps
✓ Successfully installed @google/generative-ai
✓ Successfully installed sharp
✓ Build complete
```

### 2. What You Should NOT See
```
❌ Using Railpack
❌ npm ci
❌ Missing @google/generative-ai from lock file
```

---

## 🎬 Quick Actions

**After updating Railway settings:**
1. Click **"Deploy"** or **"Redeploy"** button
2. Watch the build logs
3. Verify it uses Dockerfile
4. Confirm npm install succeeds
5. Test the health endpoint

**If it still fails:**
1. Double-check "Builder" is set to "Dockerfile"
2. Verify "Root Directory" is "backend"
3. Try **"Clear Cache and Redeploy"**

---

## 📞 Current Status

- [x] Updated `railway.json` to use Dockerfile
- [x] Committed and pushed to GitHub
- [ ] **YOU NEED TO**: Manually configure Railway dashboard
- [ ] **YOU NEED TO**: Trigger new deployment
- [ ] **YOU NEED TO**: Verify deployment succeeds

---

## 💡 Why This Is Necessary

Railway's Railpack auto-detection is **overriding** our configuration files:
- It ignores `railway.json` when in auto-detect mode
- It forces `npm ci` which requires synced lock file
- We need to explicitly tell Railway: "Use Dockerfile, not Railpack!"

By setting the builder to "Dockerfile", Railway will:
✅ Use our Dockerfile
✅ Run `npm install --legacy-peer-deps` (from Dockerfile)
✅ Skip `npm ci` entirely
✅ Install all dependencies correctly

---

## 🚀 Expected Result

After following these steps:
1. Railway will use the Dockerfile ✅
2. npm install will succeed ✅
3. All dependencies will be installed ✅
4. Backend will deploy successfully ✅
5. Health endpoint will respond ✅

---

## 📝 Quick Reference

**What to change in Railway Dashboard:**

```
Settings → Build:
  ✓ Builder: Dockerfile
  ✓ Root Directory: backend
  ✓ Dockerfile Path: Dockerfile
  
Settings → Deploy:
  ✓ Start Command: node src/index.js
```

Then click **"Deploy"** or **"Redeploy"**!

---

## ⏱️ Estimated Time

- **Time to make changes**: 2-3 minutes
- **Deployment time**: 3-5 minutes
- **Total**: ~5-8 minutes to successful deployment

**Let's get this deployed!** 🚀
