-- ============================================
-- SLEEP TRACKING TABLES - MANUAL SQL SCRIPT
-- Run this in Supabase SQL Editor
-- ============================================

-- ===========================================
-- TABLE 1: sleep_sessions
-- ===========================================
-- Stores main sleep sessions with start/end times, quality, and status
CREATE TABLE IF NOT EXISTS sleep_sessions (
  -- Primary Key
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  
  -- PATIENT LINKAGE - Links each sleep session to a patient
  patient_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
  
  -- Session Timing
  start_time TIMESTAMP NOT NULL,
  end_time TIMESTAMP,  -- NULL if session is still active
  
  -- Sleep Quality (1-5 stars, recorded at end)
  quality_rating INTEGER CHECK (quality_rating >= 1 AND quality_rating <= 5),
  
  -- Duration
  total_duration_minutes INTEGER,  -- Calculated when session ends
  
  -- Wake-up tracking
  wake_up_count INTEGER NOT NULL DEFAULT 0,
  
  -- Notes and Environment
  notes TEXT,
  environment_factors JSONB,  -- Room temperature, noise level, etc.
  
  -- Session Status
  status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'paused', 'completed')),
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ===========================================
-- TABLE 2: sleep_interruptions
-- ===========================================
-- Tracks individual wake-ups during sleep sessions
CREATE TABLE IF NOT EXISTS sleep_interruptions (
  -- Primary Key
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  
  -- Link to sleep session
  sleep_session_id UUID NOT NULL REFERENCES sleep_sessions(id) ON DELETE CASCADE ON UPDATE CASCADE,
  
  -- Interruption Timing
  pause_time TIMESTAMP NOT NULL,  -- When they woke up
  resume_time TIMESTAMP,  -- When they went back to sleep (NULL if still awake)
  duration_minutes INTEGER,  -- How long they were awake (calculated when resume_time is set)
  
  -- Interruption Details
  reason VARCHAR(100),  -- bathroom, noise, discomfort, etc.
  notes TEXT,
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ===========================================
-- INDEXES FOR PERFORMANCE
-- ===========================================

-- Sleep Sessions Indexes
CREATE INDEX IF NOT EXISTS idx_sleep_sessions_patient_id ON sleep_sessions(patient_id);
CREATE INDEX IF NOT EXISTS idx_sleep_sessions_start_time ON sleep_sessions(start_time);
CREATE INDEX IF NOT EXISTS idx_sleep_sessions_patient_start ON sleep_sessions(patient_id, start_time);
CREATE INDEX IF NOT EXISTS idx_sleep_sessions_status ON sleep_sessions(status);
CREATE INDEX IF NOT EXISTS idx_sleep_sessions_patient_status ON sleep_sessions(patient_id, status);

-- Sleep Interruptions Indexes
CREATE INDEX IF NOT EXISTS idx_sleep_interruptions_session_id ON sleep_interruptions(sleep_session_id);
CREATE INDEX IF NOT EXISTS idx_sleep_interruptions_pause_time ON sleep_interruptions(pause_time);

-- ===========================================
-- TABLE COMMENTS
-- ===========================================

COMMENT ON TABLE sleep_sessions IS 'Stores patient sleep tracking sessions with quality ratings and status';
COMMENT ON TABLE sleep_interruptions IS 'Tracks wake-ups and interruptions during sleep sessions';

-- Sleep Sessions Column Comments
COMMENT ON COLUMN sleep_sessions.patient_id IS 'Foreign key to users table - links each sleep session to a patient';
COMMENT ON COLUMN sleep_sessions.status IS 'Session status: active (sleeping), paused (woken up), or completed (ended)';
COMMENT ON COLUMN sleep_sessions.quality_rating IS 'Sleep quality rating from 1 (poor) to 5 (excellent)';
COMMENT ON COLUMN sleep_sessions.wake_up_count IS 'Number of times the patient woke up during this session';
COMMENT ON COLUMN sleep_sessions.environment_factors IS 'JSON data about sleep environment (temperature, noise, etc.)';

-- Sleep Interruptions Column Comments
COMMENT ON COLUMN sleep_interruptions.sleep_session_id IS 'Foreign key to sleep_sessions - links interruption to its session';
COMMENT ON COLUMN sleep_interruptions.pause_time IS 'When the patient woke up';
COMMENT ON COLUMN sleep_interruptions.resume_time IS 'When the patient went back to sleep';
COMMENT ON COLUMN sleep_interruptions.duration_minutes IS 'How many minutes the patient was awake';

-- ===========================================
-- AUTO-UPDATE TRIGGERS
-- ===========================================

-- Trigger function to auto-update updated_at timestamp for sleep_sessions
CREATE OR REPLACE FUNCTION update_sleep_sessions_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_sleep_sessions_updated_at
  BEFORE UPDATE ON sleep_sessions
  FOR EACH ROW
  EXECUTE FUNCTION update_sleep_sessions_updated_at();

-- Trigger function to auto-update updated_at timestamp for sleep_interruptions
CREATE OR REPLACE FUNCTION update_sleep_interruptions_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_sleep_interruptions_updated_at
  BEFORE UPDATE ON sleep_interruptions
  FOR EACH ROW
  EXECUTE FUNCTION update_sleep_interruptions_updated_at();

-- ===========================================
-- VERIFICATION QUERIES
-- ===========================================

-- Verify sleep_sessions table structure
SELECT 
  column_name, 
  data_type, 
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'sleep_sessions'
ORDER BY ordinal_position;

-- Verify sleep_interruptions table structure
SELECT 
  column_name, 
  data_type, 
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'sleep_interruptions'
ORDER BY ordinal_position;

-- Verify foreign key constraints
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
WHERE tc.table_name IN ('sleep_sessions', 'sleep_interruptions') 
  AND tc.constraint_type = 'FOREIGN KEY';

-- Verify indexes
SELECT
  tablename,
  indexname,
  indexdef
FROM pg_indexes
WHERE tablename IN ('sleep_sessions', 'sleep_interruptions')
ORDER BY tablename, indexname;

-- ===========================================
-- SAMPLE DATA VERIFICATION
-- ===========================================

-- Check if tables are empty (should return 0 rows initially)
SELECT COUNT(*) as sleep_sessions_count FROM sleep_sessions;
SELECT COUNT(*) as sleep_interruptions_count FROM sleep_interruptions;

-- ===========================================
-- EXAMPLE QUERIES (for testing after insertion)
-- ===========================================

-- Get all sleep sessions for a specific patient (replace UUID with actual patient_id)
-- SELECT * FROM sleep_sessions WHERE patient_id = 'YOUR-PATIENT-UUID' ORDER BY start_time DESC;

-- Get sleep session with all interruptions
-- SELECT 
--   s.*,
--   json_agg(i.*) as interruptions
-- FROM sleep_sessions s
-- LEFT JOIN sleep_interruptions i ON i.sleep_session_id = s.id
-- WHERE s.patient_id = 'YOUR-PATIENT-UUID'
-- GROUP BY s.id
-- ORDER BY s.start_time DESC;

-- Get sleep analytics for last 7 days
-- SELECT 
--   COUNT(*) as total_sessions,
--   AVG(total_duration_minutes) as avg_duration_minutes,
--   AVG(quality_rating) as avg_quality,
--   AVG(wake_up_count) as avg_wake_ups
-- FROM sleep_sessions
-- WHERE patient_id = 'YOUR-PATIENT-UUID'
--   AND status = 'completed'
--   AND start_time >= NOW() - INTERVAL '7 days';

-- ============================================
-- DONE! Tables created successfully
-- ============================================
