-- Fix profiles table structure for registration
-- Run this SQL in Supabase Console → SQL Editor

-- First, check current structure
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'profiles';

-- Add missing columns to profiles table
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS role TEXT,
ADD COLUMN IF NOT EXISTS full_name TEXT,
ADD COLUMN IF NOT EXISTS phone TEXT,
ADD COLUMN IF NOT EXISTS address TEXT,
ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- Create index for better performance
CREATE INDEX IF NOT EXISTS idx_profiles_role ON profiles(role);
CREATE INDEX IF NOT EXISTS idx_profiles_email ON profiles(email);

-- Set default role for existing users if needed
UPDATE profiles SET role = 'mitra_bisnis' WHERE role IS NULL;

-- Update timestamps for existing records
UPDATE profiles SET 
    created_at = NOW(),
    updated_at = NOW()
WHERE created_at IS NULL;

-- Verify the table structure
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'profiles'
ORDER BY ordinal_position;