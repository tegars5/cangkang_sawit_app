-- Task 2: Create Trigger for Auto Profile Creation
-- This ensures profiles are automatically created when new users register

-- Drop existing trigger and function if they exist
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;

-- Create function to handle new user creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  user_role_id INTEGER;
BEGIN
  -- Determine role based on email pattern
  -- Default to Mitra Bisnis (role_id = 2) if no pattern matches
  IF NEW.email LIKE '%admin%' THEN
    user_role_id := 1; -- Admin
  ELSIF NEW.email LIKE '%driver%' THEN
    user_role_id := 3; -- Driver
  ELSE
    user_role_id := 2; -- Mitra Bisnis (default)
  END IF;

  -- Insert profile with determined role
  INSERT INTO public.profiles (
    id,
    email,
    full_name,
    role_id,
    is_active,
    created_at,
    updated_at
  )
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'User'),
    user_role_id,
    true,
    NOW(),
    NOW()
  );

  RETURN NEW;
END;
$$;

-- Create trigger that fires after user creation
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON public.profiles TO authenticated;

-- Verify trigger exists
SELECT 
  trigger_name,
  event_manipulation,
  event_object_table,
  action_statement
FROM information_schema.triggers
WHERE trigger_name = 'on_auth_user_created';
