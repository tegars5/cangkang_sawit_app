-- Test getUserProfile query
-- Copy paste query ini ke Supabase SQL Editor

SELECT 
  p.*,
  r.id as "roles.id",
  r.name as "roles.name",
  r.created_at as "roles.created_at"
FROM profiles p
LEFT JOIN roles r ON p.role_id = r.id
WHERE p.email = 'admin@fujiyama.com';

-- Expected result:
-- Should return 1 row with:
-- - All profile columns (id, email, full_name, role_id, etc.)
-- - roles.id = 1
-- - roles.name = 'Admin'
-- - roles.created_at = timestamp

-- If this works, then the problem is in the app code, not database
