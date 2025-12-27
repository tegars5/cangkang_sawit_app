-- COMPLETELY REMOVE TRIGGER - So we can login
-- The trigger is causing "Database error querying schema"

-- Drop the trigger completely
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Drop the function too
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;

-- Verify trigger is gone
SELECT 
  trigger_name, 
  event_object_table
FROM information_schema.triggers
WHERE trigger_name = 'on_auth_user_created';

-- Should return 0 rows (trigger deleted)
