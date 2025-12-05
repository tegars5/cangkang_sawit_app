# 🧪 Complete Auth Testing Guide

## Prerequisites

Before testing, ensure:
1. ✅ SQL fix script has been run in Supabase
2. ✅ Admin user created in Supabase Dashboard
3. ✅ App code updated with latest fixes
4. ✅ App restarted (hot restart)

---

## Test Scenarios

### 1. Test Admin Login ✅

**Steps**:
1. Open app
2. Click "Login"
3. Enter credentials:
   - Email: `admin@gmail.com`
   - Password: `password123`
4. Click "Log In"

**Expected Results**:
- ✅ Loading indicator shows
- ✅ Login successful
- ✅ Profile loaded
- ✅ Redirected to Admin Dashboard
- ✅ No errors shown

**If Failed**:
- Check Supabase Dashboard → Authentication → Users
- Verify admin user exists
- Check Supabase → Table Editor → profiles
- Verify admin profile exists with role_id = 1

---

### 2. Test New User Registration (Mitra) ✅

**Steps**:
1. Open app
2. Click "Sign up"
3. Fill form:
   - Email: `testmitra@gmail.com`
   - Password: `password123`
   - Full Name: `Test Mitra`
   - Role: Select "Mitra Bisnis"
   - Phone: `08123456789` (optional)
4. Click "Lanjut"

**Expected Results**:
- ✅ "Lanjut" button is enabled
- ✅ Loading indicator shows
- ✅ Registration successful
- ✅ Profile created in database
- ✅ Success message shown
- ✅ Redirected to Mitra Dashboard

**If Failed**:
- Check console for error messages
- Verify email not already registered
- Check Supabase logs for errors

---

### 3. Test New User Registration (Driver) ✅

**Steps**:
1. Open app
2. Click "Sign up"
3. Fill form:
   - Email: `testdriver@gmail.com`
   - Password: `password123`
   - Full Name: `Test Driver`
   - Role: Select "Logistik"
   - Phone: `08123456789` (optional)
4. Click "Lanjut"

**Expected Results**:
- ✅ Registration successful
- ✅ Profile created with role_id = 3
- ✅ Redirected to Driver Dashboard

---

### 4. Test Duplicate Email Error ✅

**Steps**:
1. Try to register with existing email (e.g., `admin@gmail.com`)

**Expected Results**:
- ✅ Error shown: "Email sudah terdaftar. Silakan gunakan email lain."
- ✅ User-friendly message (not technical error)
- ✅ Form stays on screen

---

### 5. Test Validation Errors ✅

**Test 5a: Empty Email**
1. Leave email empty
2. Click "Lanjut"
3. ✅ Should show: "Email tidak boleh kosong"

**Test 5b: Invalid Email**
1. Enter: `notanemail`
2. Click "Lanjut"
3. ✅ Should show: "Email tidak valid"

**Test 5c: Short Password**
1. Enter password: `12345`
2. Click "Lanjut"
3. ✅ Should show: "Password minimal 6 karakter"

**Test 5d: Empty Full Name**
1. Leave full name empty
2. Click "Lanjut"
3. ✅ Button should be disabled OR show error

---

### 6. Test Login with Wrong Password ✅

**Steps**:
1. Enter correct email: `admin@gmail.com`
2. Enter wrong password: `wrongpassword`
3. Click "Log In"

**Expected Results**:
- ✅ Error shown: "Email atau password salah"
- ✅ User-friendly message
- ✅ Can try again

---

### 7. Test Login with Non-Existent User ✅

**Steps**:
1. Enter email: `nonexistent@gmail.com`
2. Enter any password
3. Click "Log In"

**Expected Results**:
- ✅ Error shown: "Email atau password salah"
- ✅ No technical error exposed

---

### 8. Test Profile Loading After Login ✅

**Steps**:
1. Login successfully
2. Observe console logs

**Expected Results**:
- ✅ Profile loaded successfully
- ✅ role_id is not null
- ✅ full_name is not null
- ✅ email is not null
- ✅ All fields have values

**Check in Code**:
```dart
// Should see in console:
✅ Role ID: 1, Role Name: admin
🚀 Navigating to Admin Dashboard
```

---

### 9. Test Auto-Login (Session Persistence) ✅

**Steps**:
1. Login successfully
2. Close app completely
3. Reopen app

**Expected Results**:
- ✅ Shows loading briefly
- ✅ Automatically logged in
- ✅ Redirected to correct dashboard based on role
- ✅ No need to login again

---

### 10. Test Logout ✅

**Steps**:
1. Login successfully
2. Navigate to Settings/Profile
3. Click "Logout"

**Expected Results**:
- ✅ Confirmation dialog shown
- ✅ After confirm, logged out
- ✅ Redirected to Login screen
- ✅ Session cleared

---

## Database Verification

After each test, verify in Supabase:

### Check Profiles Table
```sql
SELECT 
  p.id,
  p.email,
  p.full_name,
  p.role_id,
  r.name as role_name,
  p.phone,
  p.is_active,
  p.created_at
FROM profiles p
LEFT JOIN roles r ON p.role_id = r.id
ORDER BY p.created_at DESC
LIMIT 10;
```

**Expected**:
- ✅ All new users appear
- ✅ role_id is set correctly (1, 2, or 3)
- ✅ full_name is not null
- ✅ email is not null
- ✅ is_active = true

### Check Auth Users
```sql
SELECT 
  id,
  email,
  created_at,
  confirmed_at
FROM auth.users
ORDER BY created_at DESC
LIMIT 10;
```

**Expected**:
- ✅ Auth user created
- ✅ confirmed_at is set (auto-confirmed)
- ✅ ID matches profile ID

---

## Troubleshooting

### Issue: "Gagal memuat profil pengguna"

**Causes**:
1. Profile not created in database
2. role_id is null
3. Network error

**Solutions**:
1. Check Supabase → profiles table
2. Run SQL fix script
3. Verify network connection
4. Check console for detailed error

### Issue: "Duplicate key violates unique constraint"

**Causes**:
1. Trying to insert profile with existing ID
2. Email already registered

**Solutions**:
1. ✅ Fixed in code (checks existing profile first)
2. Use different email
3. Delete old test users

### Issue: "Tombol Lanjut tidak aktif"

**Causes**:
1. Form validation failing
2. Required fields empty

**Solutions**:
1. Fill all required fields
2. Ensure email is valid format
3. Ensure password is 6+ characters
4. Select a role

### Issue: "role_id is null"

**Causes**:
1. Role not mapped correctly
2. Database default not set

**Solutions**:
1. ✅ Fixed in code (sets roleId explicitly)
2. Run SQL fix script
3. Check role mapping in RegistrationController

---

## Success Criteria

All tests should pass:
- ✅ Admin can login
- ✅ New users can register (Mitra & Driver)
- ✅ Duplicate email shows error
- ✅ Validation works
- ✅ Wrong password shows error
- ✅ Profile loads successfully
- ✅ No null fields
- ✅ Auto-login works
- ✅ Logout works
- ✅ Database records correct

---

## Next Steps After Testing

If all tests pass:
1. ✅ Auth system is working correctly
2. ✅ Can proceed with feature development
3. ✅ Can deploy to production

If tests fail:
1. Check console logs
2. Check Supabase logs
3. Verify SQL script ran successfully
4. Contact support with error details
