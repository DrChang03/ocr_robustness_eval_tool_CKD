-- MedicalSnap — Supabase Schema
-- Run this in your Supabase project: Dashboard → SQL Editor → New Query

-- Create the field_test_data table
CREATE TABLE IF NOT EXISTS field_test_data (
    id              BIGSERIAL PRIMARY KEY,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    product_name    TEXT,
    ocr_raw_text    TEXT,
    detected_keywords TEXT,
    material_type   TEXT
);

-- Enable Row Level Security
ALTER TABLE field_test_data ENABLE ROW LEVEL SECURITY;

-- Allow anonymous inserts (required for the app's anon key)
CREATE POLICY "Allow anonymous inserts"
    ON field_test_data
    FOR INSERT
    TO anon
    WITH CHECK (true);

-- Optional: allow authenticated users to read all data (for research/analysis)
CREATE POLICY "Allow authenticated reads"
    ON field_test_data
    FOR SELECT
    TO authenticated
    USING (true);
