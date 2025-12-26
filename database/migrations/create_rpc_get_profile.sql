-- Create RPC function to get user profile safely
-- This bypasses RLS issues by using security definer

CREATE OR REPLACE FUNCTION get_user_profile(user_id uuid)
RETURNS TABLE (
  role_id integer,
  full_name text,
  email text
)
LANGUAGE plpgsql
SECURITY DEFINER -- This runs with the function owner's permissions
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.role_id,
    p.full_name,
    p.email
  FROM profiles p
  WHERE p.id = user_id;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION get_user_profile(uuid) TO authenticated;

-- Test the function (replace with actual user ID)
-- SELECT * FROM get_user_profile('your-user-id-here');
