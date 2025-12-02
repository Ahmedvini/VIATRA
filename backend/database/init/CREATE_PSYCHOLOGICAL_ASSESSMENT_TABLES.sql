-- =================================================================
-- PSYCHOLOGICAL ASSESSMENT TABLES (PHQ-9)
-- Patient Health Questionnaire-9 for Depression Screening
-- =================================================================

-- Main assessment sessions table
CREATE TABLE IF NOT EXISTS psychological_assessments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    assessment_type VARCHAR(50) NOT NULL DEFAULT 'PHQ9', -- Future: GAD7, etc.
    assessment_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- PHQ-9 Individual Question Scores (0-3 each)
    q1_interest INTEGER CHECK (q1_interest >= 0 AND q1_interest <= 3),
    q2_feeling_down INTEGER CHECK (q2_feeling_down >= 0 AND q2_feeling_down <= 3),
    q3_sleep INTEGER CHECK (q3_sleep >= 0 AND q3_sleep <= 3),
    q4_energy INTEGER CHECK (q4_energy >= 0 AND q4_energy <= 3),
    q5_appetite INTEGER CHECK (q5_appetite >= 0 AND q5_appetite <= 3),
    q6_self_worth INTEGER CHECK (q6_self_worth >= 0 AND q6_self_worth <= 3),
    q7_concentration INTEGER CHECK (q7_concentration >= 0 AND q7_concentration <= 3),
    q8_movement INTEGER CHECK (q8_movement >= 0 AND q8_movement <= 3),
    q9_self_harm INTEGER CHECK (q9_self_harm >= 0 AND q9_self_harm <= 3),
    
    -- Calculated scores
    total_score INTEGER CHECK (total_score >= 0 AND total_score <= 27),
    severity_level VARCHAR(50), -- minimal, mild, moderate, moderately_severe, severe
    
    -- Additional context
    notes TEXT,
    difficulty_level VARCHAR(20), -- How difficult symptoms made functioning
    
    -- Tracking
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Indexes
    CONSTRAINT chk_total_score CHECK (total_score = 
        COALESCE(q1_interest, 0) + 
        COALESCE(q2_feeling_down, 0) + 
        COALESCE(q3_sleep, 0) + 
        COALESCE(q4_energy, 0) + 
        COALESCE(q5_appetite, 0) + 
        COALESCE(q6_self_worth, 0) + 
        COALESCE(q7_concentration, 0) + 
        COALESCE(q8_movement, 0) + 
        COALESCE(q9_self_harm, 0))
);

-- Indexes for performance
CREATE INDEX idx_psych_patient ON psychological_assessments(patient_id);
CREATE INDEX idx_psych_date ON psychological_assessments(assessment_date DESC);
CREATE INDEX idx_psych_severity ON psychological_assessments(severity_level);
CREATE INDEX idx_psych_type ON psychological_assessments(assessment_type);

-- Function to calculate severity level based on PHQ-9 score
CREATE OR REPLACE FUNCTION calculate_phq9_severity(score INTEGER)
RETURNS VARCHAR(50) AS $$
BEGIN
    IF score <= 4 THEN
        RETURN 'minimal';
    ELSIF score <= 9 THEN
        RETURN 'mild';
    ELSIF score <= 14 THEN
        RETURN 'moderate';
    ELSIF score <= 19 THEN
        RETURN 'moderately_severe';
    ELSE
        RETURN 'severe';
    END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Trigger to auto-update severity level and updated_at
CREATE OR REPLACE FUNCTION update_psychological_assessment()
RETURNS TRIGGER AS $$
BEGIN
    -- Calculate total score
    NEW.total_score := 
        COALESCE(NEW.q1_interest, 0) + 
        COALESCE(NEW.q2_feeling_down, 0) + 
        COALESCE(NEW.q3_sleep, 0) + 
        COALESCE(NEW.q4_energy, 0) + 
        COALESCE(NEW.q5_appetite, 0) + 
        COALESCE(NEW.q6_self_worth, 0) + 
        COALESCE(NEW.q7_concentration, 0) + 
        COALESCE(NEW.q8_movement, 0) + 
        COALESCE(NEW.q9_self_harm, 0);
    
    -- Calculate severity level
    NEW.severity_level := calculate_phq9_severity(NEW.total_score);
    
    -- Update timestamp
    NEW.updated_at := CURRENT_TIMESTAMP;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_psychological_assessment
    BEFORE INSERT OR UPDATE ON psychological_assessments
    FOR EACH ROW
    EXECUTE FUNCTION update_psychological_assessment();

-- Analytics view for tracking progress over time
CREATE OR REPLACE VIEW psychological_assessment_trends AS
SELECT 
    patient_id,
    assessment_type,
    DATE_TRUNC('week', assessment_date) as week,
    DATE_TRUNC('month', assessment_date) as month,
    AVG(total_score) as avg_score,
    MIN(total_score) as min_score,
    MAX(total_score) as max_score,
    COUNT(*) as assessment_count,
    MODE() WITHIN GROUP (ORDER BY severity_level) as most_common_severity
FROM psychological_assessments
GROUP BY patient_id, assessment_type, week, month;

-- Comments
COMMENT ON TABLE psychological_assessments IS 'Patient Health Questionnaire-9 (PHQ-9) depression screening assessments';
COMMENT ON COLUMN psychological_assessments.q1_interest IS 'Little interest or pleasure in doing things (0-3)';
COMMENT ON COLUMN psychological_assessments.q2_feeling_down IS 'Feeling down, depressed, or hopeless (0-3)';
COMMENT ON COLUMN psychological_assessments.q3_sleep IS 'Trouble falling/staying asleep or sleeping too much (0-3)';
COMMENT ON COLUMN psychological_assessments.q4_energy IS 'Feeling tired or having little energy (0-3)';
COMMENT ON COLUMN psychological_assessments.q5_appetite IS 'Poor appetite or overeating (0-3)';
COMMENT ON COLUMN psychological_assessments.q6_self_worth IS 'Feeling bad about yourself or that you are a failure (0-3)';
COMMENT ON COLUMN psychological_assessments.q7_concentration IS 'Trouble concentrating on things (0-3)';
COMMENT ON COLUMN psychological_assessments.q8_movement IS 'Moving/speaking slowly or being fidgety/restless (0-3)';
COMMENT ON COLUMN psychological_assessments.q9_self_harm IS 'Thoughts of being better off dead or hurting yourself (0-3)';
COMMENT ON COLUMN psychological_assessments.total_score IS 'Total PHQ-9 score (0-27)';
COMMENT ON COLUMN psychological_assessments.severity_level IS 'Depression severity: minimal(0-4), mild(5-9), moderate(10-14), moderately_severe(15-19), severe(20-27)';
