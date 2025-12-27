-- Check test users saja
SELECT 
  p.email,
  p.full_name,
  p.role_id,
  r.name as role_name,
  p.is_active
FROM public.profiles p
LEFT JOIN public.roles r ON p.role_id = r.id
WHERE p.email IN ('admin@gmail.com', 'driver@gmail.com', 'mitra@gmail.com')
ORDER BY p.email;
