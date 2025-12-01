# Mobile App API Configuration Guide

## Current Status

The mobile app has been configured to read the backend API URL from the `.env` file, but you need to provide your Railway backend URL.

## Steps to Complete Setup

### 1. Get Your Railway Backend URL

1. Go to your Railway dashboard: https://railway.app/dashboard
2. Open your backend project/service
3. Go to the "Settings" tab
4. Find the "Public Networking" section
5. Copy the domain URL (it should look like: `https://your-app-name.up.railway.app`)

### 2. Update the .env File

Open `/home/ahmedvini/Music/VIATRA/mobile/.env` and replace `YOUR_RAILWAY_URL` with your actual Railway URL:

```bash
# Before:
API_BASE_URL=https://YOUR_RAILWAY_URL/api/v1
WS_BASE_URL=wss://YOUR_RAILWAY_URL

# After (example):
API_BASE_URL=https://viatra-backend-production.up.railway.app/api/v1
WS_BASE_URL=wss://viatra-backend-production.up.railway.app
```

**Important Notes:**
- Keep `/api/v1` at the end of API_BASE_URL
- Use `https://` for API_BASE_URL (secure HTTP)
- Use `wss://` for WS_BASE_URL (secure WebSocket)
- Do NOT include a trailing slash after your domain

### 3. Rebuild the Flutter App

After updating the `.env` file, you need to rebuild the app:

```bash
cd /home/ahmedvini/Music/VIATRA/mobile

# Stop any running Flutter app
# Then clean and rebuild:
flutter clean
flutter pub get
flutter run
```

### 4. Verify the Connection

When the app starts, check the debug console for:

```
[INFO] Environment configuration loaded
[INFO] API Base URL: https://your-railway-url.up.railway.app/api/v1
```

### 5. Test Registration Flow

Try to register a new user:

1. Open the registration screen
2. Fill in Basic Info (email, password, full name)
3. Click "Next" - should proceed to Professional Info
4. Fill in Professional Info (specialty, bio)
5. Click "Next" - should proceed to Address Info
6. Fill in Address Info (city, state, address)
7. Click "Next" - should proceed to Document Upload
8. Upload one document (license or certificate)
9. Click "Submit" - should register the user

### Troubleshooting

#### Issue: "Failed to load .env file"
- **Solution**: Make sure the `.env` file exists in `/home/ahmedvini/Music/VIATRA/mobile/`
- Run: `ls -la /home/ahmedvini/Music/VIATRA/mobile/.env`

#### Issue: Still connecting to localhost
- **Solution**: 
  1. Verify you updated the `.env` file correctly
  2. Run `flutter clean` and rebuild
  3. Check that the app is reading the new URL by adding debug logging

#### Issue: Connection timeout or network error
- **Solution**:
  1. Verify your Railway backend is running: `curl https://your-railway-url.up.railway.app/health`
  2. Check Railway logs for any errors
  3. Verify the URL is correct (no typos, trailing slashes)

#### Issue: CORS errors
- **Solution**: The backend CORS configuration needs to allow your mobile app. This is typically not an issue for mobile apps, but if you see CORS errors, check the backend's CORS settings.

## Backend API Endpoints

Your backend should expose these endpoints:

- **Health Check**: `GET /health`
- **Register**: `POST /api/v1/auth/register`
- **Login**: `POST /api/v1/auth/login`
- **Verify Email**: `POST /api/v1/auth/verify-email`
- **Upload**: `POST /api/v1/upload`

## Current Configuration Files

The following files read from the `.env` file:
- `/mobile/lib/config/app_config.dart` - Main configuration
- `/mobile/lib/services/socket_service.dart` - WebSocket connection
- `/mobile/lib/services/chat_service.dart` - Chat API calls
- `/mobile/lib/main.dart` - Loads the .env file at startup

## Environment Variables

Current `.env` configuration:
```bash
API_BASE_URL=https://YOUR_RAILWAY_URL/api/v1
WS_BASE_URL=wss://YOUR_RAILWAY_URL
ENVIRONMENT=production
ENABLE_LOGGING=true
```

## Next Steps After API Connection Works

1. **Remove Debug Logging**: After confirming registration works, remove the debug print statements from `registration_provider.dart`
2. **Test All Features**: Test login, appointments, chat, etc.
3. **Configure Firebase**: Update Firebase configuration for push notifications
4. **Production Build**: Create a production build once everything works

## Quick Command Reference

```bash
# Update .env file
nano /home/ahmedvini/Music/VIATRA/mobile/.env

# Rebuild app
cd /home/ahmedvini/Music/VIATRA/mobile
flutter clean && flutter pub get && flutter run

# Check Railway backend health
curl https://your-railway-url.up.railway.app/health

# View Flutter logs
flutter logs
```

## Contact

If you encounter any issues:
1. Check the Flutter debug console for error messages
2. Check Railway logs for backend errors
3. Verify all environment variables are set correctly
4. Make sure your Railway backend is running and accessible
