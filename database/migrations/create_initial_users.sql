-- ============================================================================
-- Create Initial Users
-- Date: 2025-12-26
-- Purpose: Create Admin, Mitra, and Driver accounts
-- ============================================================================

-- Enable pgcrypto extension for password hashing
CREATE EXTENSION IF NOT EXISTS pgcrypto;

BEGIN;

-- ============================================================================
-- Insert users into auth.users with hashed passwords
-- ============================================================================

-- Note: Password is 'password123' for all users
-- Supabase uses bcrypt for password hashing

DO $$
DECLARE
  admin_id UUID;
  mitra_id UUID;
  driver_id UUID;
  encrypted_password TEXT;
BEGIN
  -- Generate password hash (password123)
  encrypted_password := crypt('password123', gen_salt('bf'));

  -- ========================================
  -- 1. CREATE ADMIN USER
  -- ========================================
  admin_id := gen_random_uuid();
  
  INSERT INTO auth.users (
    id,
    instance_id,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at,
    role,
    aud,
    confirmation_token
  ) VALUES (
    admin_id,
    '00000000-0000-0000-0000-000000000000',
    'admin@gmail.com',
    encrypted_password,
    NOW(),
    '{"provider":"email","providers":["email"]}',
    '{"role":"Admin","full_name":"Admin User"}',
    NOW(),
    NOW(),
    'authenticated',
    'authenticated',
    ''
  );
  -- Note: Profile will be auto-created by trigger

  RAISE NOTICE '✓ Created Admin user: admin@gmail.com';

  -- ========================================
  -- 2. CREATE MITRA USER
  -- ========================================
  mitra_id := gen_random_uuid();
  
  INSERT INTO auth.users (
    id,
    instance_id,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at,
    role,
    aud,
    confirmation_token
  ) VALUES (
    mitra_id,
    '00000000-0000-0000-0000-000000000000',
    'mitra@gmail.com',
    encrypted_password,
    NOW(),
    '{"provider":"email","providers":["email"]}',
    '{"role":"Mitra Bisnis","full_name":"Mitra User"}',
    NOW(),
    NOW(),
    'authenticated',
    'authenticated',
    ''
  );
  -- Note: Profile will be auto-created by trigger

  RAISE NOTICE '✓ Created Mitra user: mitra@gmail.com';

  -- ========================================
  -- 3. CREATE DRIVER USER
  -- ========================================
  driver_id := gen_random_uuid();
  
  INSERT INTO auth.users (
    id,
    instance_id,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at,
    role,
    aud,
    confirmation_token
  ) VALUES (
    driver_id,
    '00000000-0000-0000-0000-000000000000',
    'driver@gmail.com',
    encrypted_password,
    NOW(),
    '{"provider":"email","providers":["email"]}',
    '{"role":"Driver","full_name":"Driver User"}',
    NOW(),
    NOW(),
    'authenticated',
    'authenticated',
    ''
  );
  -- Note: Profile will be auto-created by trigger

  RAISE NOTICE '✓ Created Driver user: driver@gmail.com';
  
END $$;

-- ============================================================================
-- Verification
-- ============================================================================

SELECT 
  '✅ Users Created Successfully!' AS status;

-- Show all users with their roles
SELECT 
  u.email,
  p.full_name,
  r.name as role,
  r.id as role_id,
  p.is_active,
  u.email_confirmed_at,
  u.created_at
FROM auth.users u
JOIN public.profiles p ON u.id = p.id
JOIN public.roles r ON p.role_id = r.id
ORDER BY r.id;

COMMIT;

-- ============================================================================
-- LOGIN CREDENTIALS
-- ============================================================================

SELECT '📝 LOGIN CREDENTIALS' AS info;
SELECT 'Email: admin@gmail.com | Password: password123 | Role: Admin' AS admin;
SELECT 'Email: mitra@gmail.com | Password: password123 | Role: Mitra Bisnis' AS mitra;
SELECT 'Email: driver@gmail.com | Password: password123 | Role: Driver' AS driver;
