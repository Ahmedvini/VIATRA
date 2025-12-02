-- ============================================
-- FOOD TRACKING TABLE - MANUAL SQL SCRIPT
-- Run this in Supabase SQL Editor
-- ============================================

-- Create the food_logs table with all fields and patient linkage
CREATE TABLE IF NOT EXISTS food_logs (
  -- Primary Key
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  
  -- PATIENT LINKAGE - Links each food log to a patient
  patient_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
  
  -- Food Information
  meal_type VARCHAR(20) NOT NULL CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack')),
  food_name VARCHAR(255) NOT NULL,
  description TEXT,
  image_url VARCHAR(255),
  
  -- Nutritional Information (from AI analysis)
  calories FLOAT,
  protein_grams FLOAT,
  carbs_grams FLOAT,
  fat_grams FLOAT,
  fiber_grams FLOAT,
  sugar_grams FLOAT,
  sodium_mg FLOAT,
  
  -- AI Analysis Results
  ai_analysis JSONB,
  ai_confidence FLOAT,
  
  -- Serving Information
  serving_size VARCHAR(255),
  servings_count FLOAT DEFAULT 1.0,
  
  -- Timestamps
  consumed_at TIMESTAMP NOT NULL DEFAULT NOW(),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Create indexes for fast queries
CREATE INDEX IF NOT EXISTS idx_food_logs_patient_id ON food_logs(patient_id);
CREATE INDEX IF NOT EXISTS idx_food_logs_consumed_at ON food_logs(consumed_at);
CREATE INDEX IF NOT EXISTS idx_food_logs_patient_consumed ON food_logs(patient_id, consumed_at);
CREATE INDEX IF NOT EXISTS idx_food_logs_meal_type ON food_logs(meal_type);

-- Add comment to table
COMMENT ON TABLE food_logs IS 'Stores patient food tracking logs with AI-analyzed nutrition data';

-- Add comments to important columns
COMMENT ON COLUMN food_logs.patient_id IS 'Foreign key to users table - links each food log to a patient';
COMMENT ON COLUMN food_logs.meal_type IS 'Type of meal: breakfast, lunch, dinner, or snack';
COMMENT ON COLUMN food_logs.ai_analysis IS 'Full JSON response from Gemini AI analysis';
COMMENT ON COLUMN food_logs.ai_confidence IS 'AI confidence score between 0 and 1';

-- Create trigger to auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_food_logs_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_food_logs_updated_at
  BEFORE UPDATE ON food_logs
  FOR EACH ROW
  EXECUTE FUNCTION update_food_logs_updated_at();

-- Verify the table was created
SELECT 
  column_name, 
  data_type, 
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'food_logs'
ORDER BY ordinal_position;

-- Verify foreign key constraint
SELECT
  tc.constraint_name,
  tc.table_name,
  kcu.column_name,
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
WHERE tc.table_name = 'food_logs' AND tc.constraint_type = 'FOREIGN KEY';

-- Verify indexes
SELECT
  indexname,
  indexdef
FROM pg_indexes
WHERE tablename = 'food_logs';

-- Success message
DO $$
BEGIN
  RAISE NOTICE '✅ food_logs table created successfully!';
  RAISE NOTICE '✅ Patient linkage: patient_id → users.id';
  RAISE NOTICE '✅ 20 fields created';
  RAISE NOTICE '✅ 4 indexes created';
  RAISE NOTICE '✅ Auto-update trigger created';
  RAISE NOTICE '🎉 Food tracking feature is ready to use!';
END $$;
