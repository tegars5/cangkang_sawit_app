-- Task 1: Verify and Insert Roles Data
-- This ensures roles table has correct data with IDs 1, 2, 3

-- Clear existing roles and reset sequence
TRUNCATE TABLE public.roles RESTART IDENTITY CASCADE;

-- Insert the 3 required roles with specific IDs
INSERT INTO public.roles (id, name) VALUES 
  (1, 'Admin'),
  (2, 'Mitra Bisnis'),
  (3, 'Driver')
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;

-- Set the sequence to continue from 4
SELECT setval('roles_id_seq', 4, false);

-- Verify the data
SELECT id, name, created_at FROM public.roles ORDER BY id;
