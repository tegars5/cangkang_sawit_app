-- FIX TRIGGER - Trigger causing "Database error querying schema"
-- The issue is trigger tries to run during login, but might have permission issues

-- Drop the problematic trigger first
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;

-- Create a simpler, safer trigger
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
  user_role_id INTEGER;
BEGIN
  -- Only run for NEW inserts, not for login
  IF TG_OP = 'INSERT' THEN
    -- Determine role based on email
    IF NEW.email LIKE '%admin%' THEN
      user_role_id := 1;
    ELSIF NEW.email LIKE '%driver%' THEN
      user_role_id := 3;
    ELSE
      user_role_id := 2;
    END IF;

    -- Insert profile only if it doesn't exist
    INSERT INTO public.profiles (
      id, email, full_name, role_id, is_active, created_at, updated_at
    )
    VALUES (
      NEW.id,
      NEW.email,
      COALESCE(NEW.raw_user_meta_data->>'full_name', 'User'),
      user_role_id,
      true,
      NOW(),
      NOW()
    )
    ON CONFLICT (id) DO NOTHING;
  END IF;

  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  -- Don't let trigger errors block auth operations
  RAISE WARNING 'Profile creation failed: %', SQLERRM;
  RETURN NEW;
END;
$$;

-- Create trigger that only fires on INSERT, not on every auth operation
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- Verify trigger is created
SELECT 
  trigger_name, 
  event_manipulation,
  event_object_table,
  action_timing
FROM information_schema.triggers
WHERE trigger_name = 'on_auth_user_created';
