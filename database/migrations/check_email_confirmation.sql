-- CHECK IF USER EMAIL IS CONFIRMED
SELECT 
  id,
  email,
  email_confirmed_at,
  confirmation_token,
  created_at,
  CASE 
    WHEN email_confirmed_at IS NOT NULL THEN 'Confirmed'
    ELSE 'Not Confirmed'
  END as status
FROM auth.users
WHERE email IN ('admin@gmail.com', 'driver@gmail.com', 'mitra@gmail.com')
ORDER BY email;
