-- Quick Debug Query
-- Run this to check what getUserProfile() will return

-- Check current user session (replace with your user ID)
-- Get user ID from: SELECT id FROM auth.users WHERE email = 'admin@fujiyama.com';

-- Example query that getUserProfile() runs:
SELECT 
  p.*,
  r.id as "roles.id",
  r.name as "roles.name",
  r.created_at as "roles.created_at"
FROM profiles p
LEFT JOIN roles r ON p.role_id = r.id
WHERE p.id = 'a2991668-bd2d-4e83-0413-9c5bfb6fe8e4' -- Replace with actual user ID
LIMIT 1;

-- Check if this returns data with roles info
-- Expected: Should return 1 row with roles.id, roles.name filled

-- If roles.id is NULL, check roles table:
SELECT * FROM roles;

-- If roles table is empty, run fix_auth.sql again
