-- TEST DIRECT QUERY - Bypass Supabase Auth
-- This will tell us if the problem is auth or database

-- Test 1: Can we query profiles directly?
SELECT 
  id,
  email,
  full_name,
  role_id
FROM public.profiles
WHERE email = 'admin@gmail.com';

-- Test 2: Can we query with role join?
SELECT 
  p.id,
  p.email,
  p.full_name,
  p.role_id,
  r.name as role_name
FROM public.profiles p
LEFT JOIN public.roles r ON p.role_id = r.id
WHERE p.email = 'admin@gmail.com';

-- Test 3: Check auth.users (if we have permission)
SELECT 
  id,
  email,
  created_at
FROM auth.users
WHERE email = 'admin@gmail.com';
