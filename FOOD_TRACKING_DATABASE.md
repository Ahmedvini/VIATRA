# Food Tracking Database Structure - COMPLETE

## ✅ Database Tables

### **food_logs** Table
```sql
CREATE TABLE food_logs (
  -- Primary Key
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  
  -- Foreign Key to patients (users table where role='patient')
  patient_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  -- Food Information
  meal_type ENUM('breakfast', 'lunch', 'dinner', 'snack') NOT NULL,
  food_name VARCHAR(255) NOT NULL,
  description TEXT,
  image_url VARCHAR(255),
  
  -- Nutritional Information (from Gemini AI analysis)
  calories FLOAT,
  protein_grams FLOAT,
  carbs_grams FLOAT,
  fat_grams FLOAT,
  fiber_grams FLOAT,
  sugar_grams FLOAT,
  sodium_mg FLOAT,
  
  -- AI Analysis Results
  ai_analysis JSONB,           -- Full Gemini AI response
  ai_confidence FLOAT,          -- Confidence score (0-1)
  
  -- Serving Information
  serving_size VARCHAR(255),    -- e.g., "1 cup", "100g", "1 medium apple"
  servings_count FLOAT DEFAULT 1.0,
  
  -- Timestamps
  consumed_at TIMESTAMP NOT NULL DEFAULT NOW(),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  
  -- Indexes for fast queries
  INDEX idx_patient_id (patient_id),
  INDEX idx_consumed_at (consumed_at),
  INDEX idx_patient_consumed (patient_id, consumed_at),
  INDEX idx_meal_type (meal_type)
);
```

## 🔗 Relationships

```
users (patients)
  └── has many → food_logs
       └── foreign key: patient_id → users.id
```

## 📊 What Each Patient Can Track

### ✅ **Food Information:**
- **Food Name** - AI-detected food name
- **Description** - Additional details about the food
- **Image** - Photo of the food (stored in Google Cloud Storage)
- **Meal Type** - breakfast, lunch, dinner, or snack
- **Consumed At** - When the food was eaten

### ✅ **Nutritional Data (AI-Analyzed):**
- **Calories** - Total energy
- **Protein** - Grams of protein
- **Carbs** - Grams of carbohydrates
- **Fat** - Grams of fat
- **Fiber** - Grams of fiber
- **Sugar** - Grams of sugar
- **Sodium** - Milligrams of sodium

### ✅ **AI Analysis:**
- **Full AI Response** - Complete Gemini analysis (JSONB)
- **Confidence Score** - How confident the AI is (0-1)

### ✅ **Serving Info:**
- **Serving Size** - e.g., "1 cup", "200g"
- **Servings Count** - How many servings (e.g., 1.5 servings)

## 📡 API Endpoints

### **Analyze Food Image**
```bash
POST /api/food-tracking/analyze
Authorization: Bearer <token>
Content-Type: multipart/form-data

Body:
  - image: file (required)
  - meal_type: string (breakfast|lunch|dinner|snack)
  - consumed_at: ISO datetime
  - servings_count: number

Response:
{
  "success": true,
  "message": "Food analyzed and logged successfully",
  "data": {
    "id": "uuid",
    "patientId": "uuid",
    "mealType": "lunch",
    "foodName": "Grilled Chicken Salad",
    "description": "Fresh salad with grilled chicken, mixed greens...",
    "imageUrl": "https://storage.googleapis.com/...",
    "nutrition": {
      "calories": 350,
      "protein": 35,
      "carbs": 12,
      "fat": 18,
      "fiber": 5,
      "sugar": 4,
      "sodium": 420
    },
    "aiAnalysis": { ... },
    "aiConfidence": 0.95,
    "servingSize": "1 large bowl",
    "servingsCount": 1.0,
    "consumedAt": "2025-12-02T14:30:00Z",
    "createdAt": "2025-12-02T14:35:00Z",
    "updatedAt": "2025-12-02T14:35:00Z"
  }
}
```

### **Get Food Logs**
```bash
GET /api/food-tracking?start_date=2025-12-01&end_date=2025-12-02&meal_type=lunch
Authorization: Bearer <token>

Response:
{
  "success": true,
  "data": [...food logs...],
  "pagination": {
    "total": 45,
    "limit": 50,
    "offset": 0,
    "hasMore": false
  }
}
```

### **Get Nutrition Summary**
```bash
GET /api/food-tracking/summary?start_date=2025-12-01&end_date=2025-12-07
Authorization: Bearer <token>

Response:
{
  "success": true,
  "data": {
    "summary": {
      "totalCalories": 14500,
      "totalProtein": 520,
      "totalCarbs": 1200,
      "totalFat": 450,
      "totalFiber": 180,
      "totalSugar": 120,
      "totalSodium": 9500,
      "mealBreakdown": {
        "breakfast": { "count": 7, "calories": 3200 },
        "lunch": { "count": 7, "calories": 4500 },
        "dinner": { "count": 7, "calories": 5800 },
        "snack": { "count": 10, "calories": 1000 }
      },
      "dailyAverages": {
        "calories": 2071,
        "protein": 74,
        "carbs": 171,
        "fat": 64
      }
    },
    "totalLogs": 31,
    "dateRange": {
      "start_date": "2025-12-01",
      "end_date": "2025-12-07",
      "days": 7
    }
  }
}
```

### **Update Food Log**
```bash
PUT /api/food-tracking/:id
Authorization: Bearer <token>
Content-Type: application/json

Body:
{
  "mealType": "dinner",
  "servingsCount": 1.5,
  "calories": 450
}
```

### **Delete Food Log**
```bash
DELETE /api/food-tracking/:id
Authorization: Bearer <token>
```

## 🔐 Security

- ✅ All routes require authentication
- ✅ Patients can only access their own food logs
- ✅ Foreign key with CASCADE delete (if patient deleted, their logs are deleted)
- ✅ Image uploads validated (10MB limit, images only)

## 🎯 Features Completed

✅ AI-powered food analysis with Gemini Pro Vision
✅ Image upload to Google Cloud Storage
✅ Complete CRUD operations
✅ Nutrition tracking and summaries
✅ Meal type categorization
✅ Date range filtering
✅ Patient-specific data isolation
✅ Detailed nutritional breakdown
✅ AI confidence scoring
✅ Serving size tracking

## 🚀 Ready for Production!

The food tracking feature is complete and ready to use! Each patient can:
1. Take a photo of their food
2. Get instant AI nutritional analysis
3. Track meals throughout the day
4. View nutrition summaries and trends
5. Update or delete entries as needed
