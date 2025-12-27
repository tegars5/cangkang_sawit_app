-- CHECK ALL ACTIVE TRIGGERS AND FUNCTIONS
-- See if there's something we missed

-- 1. Check ALL triggers on auth.users
SELECT 
  trigger_schema,
  trigger_name,
  event_object_schema,
  event_object_table,
  action_statement,
  action_timing,
  event_manipulation
FROM information_schema.triggers
WHERE event_object_table = 'users'
  AND event_object_schema = 'auth'
ORDER BY trigger_name;

-- 2. Check ALL functions in public schema
SELECT 
  routine_schema,
  routine_name,
  routine_type,
  data_type
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name LIKE '%user%'
  OR routine_name LIKE '%profile%'
  OR routine_name LIKE '%auth%'
ORDER BY routine_name;

-- 3. Check Postgres extensions
SELECT 
  extname,
  extversion
FROM pg_extension
ORDER BY extname;
