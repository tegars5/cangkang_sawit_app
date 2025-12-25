# Manual Testing Checklist for Cangkang Sawit App

**Project**: Cangkang Sawit App  
**Test Date**: December 22, 2025  
**Tester**: ********\_********  
**Device/Platform**: ********\_********  
**OS Version**: ********\_********  
**App Version**: 1.0.0+1

---

## Prerequisites

- [ ] App installed on test device
- [ ] Test credentials available (admin, mitra, driver)
- [ ] Internet connection available
- [ ] Location services enabled
- [ ] Camera permission available

---

## Test Credentials

### Admin Account

- Email: admin@example.com
- Password: admin123

### Mitra Account

- Email: mitra@example.com
- Password: password123

### Driver Account

- Email: driver@example.com
- Password: password123

---

## 1. Authentication Flow

### 1.1 Login Functionality

- [ ] App launches successfully without crashes
- [ ] Login screen displays correctly
- [ ] Email field accepts valid email format
- [ ] Password field masks characters
- [ ] "Show password" toggle works correctly
- [ ] Login with valid credentials succeeds
- [ ] Login with invalid credentials shows appropriate error
- [ ] Login with empty fields shows validation errors
- [ ] Remember me functionality works (if implemented)
- [ ] Forgot password link navigates to correct screen

**Status**: ⬜ Pass | ⬜ Fail | ⬜ Blocked  
**Notes**: ************************\_************************

### 1.2 Registration Functionality

- [ ] Registration screen accessible from login
- [ ] All required fields are present (name, email, password, role)
- [ ] Email validation works correctly
- [ ] Password strength indicator works (if implemented)
- [ ] Password confirmation validation works
- [ ] Role selection (Mitra/Driver) works correctly
- [ ] Registration with valid data succeeds
- [ ] Registration with duplicate email shows error
- [ ] Registration with invalid data shows appropriate errors
- [ ] After registration, user redirects to appropriate dashboard

**Status**: ⬜ Pass | ⬜ Fail | ⬜ Blocked  
**Notes**: ************************\_************************

### 1.3 Forgot Password

- [ ] Forgot password screen accessible
- [ ] Email input accepts valid email
- [ ] Password reset email sent successfully
- [ ] Appropriate success message displayed
- [ ] Error handling for non-existent email

**Status**: ⬜ Pass | ⬜ Fail | ⬜ Blocked  
**Notes**: ************************\_************************

### 1.4 Logout Functionality

- [ ] Logout button/option is visible
- [ ] Logout confirmation dialog appears (if implemented)
- [ ] After logout, user redirects to login screen
- [ ] Cannot access protected screens after logout
- [ ] Session data cleared after logout

**Status**: ⬜ Pass | ⬜ Fail | ⬜ Blocked  
**Notes**: ************************\_************************

---

## 2. Mitra Order Creation Flow

### 2.1 Product Catalog

- [ ] Mitra can access product catalog
- [ ] Products load successfully
- [ ] Product images display correctly
- [ ] Product details (name, price, stock) are visible
- [ ] Search functionality works
- [ ] Filter by category works (if implemented)
- [ ] Sort options work (if implemented)
- [ ] Product details page shows complete information

**Status**: ⬜ Pass | ⬜ Fail | ⬜ Blocked  
**Notes**: ************************\_************************

### 2.2 Cart Management

- [ ] Add to cart button works
- [ ] Cart icon shows item count
- [ ] Cart page displays added items
- [ ] Quantity can be increased/decreased
- [ ] Remove item from cart works
- [ ] Cart subtotal calculates correctly
- [ ] Clear cart functionality works
- [ ] Cart persists after app restart (if implemented)

**Status**: ⬜ Pass | ⬜ Fail | ⬜ Blocked  
**Notes**: ************************\_************************

### 2.3 Checkout Process

- [ ] Checkout button is accessible
- [ ] Delivery address form displays
- [ ] Address validation works correctly
- [ ] Location picker works (if implemented)
- [ ] Order summary shows correct items and prices
- [ ] Delivery fee calculated correctly (if applicable)
- [ ] Total amount is correct
- [ ] Place order button works
- [ ] Order confirmation message appears
- [ ] Order number generated

**Status**: ⬜ Pass | ⬜ Fail | ⬜ Blocked  
**Notes**: ************************\_************************

### 2.4 Order Tracking

- [ ] Mitra can view their orders list
- [ ] Order status displayed correctly
- [ ] Order details accessible by tapping order
- [ ] Order details show complete information
- [ ] Track delivery button visible for shipped orders
- [ ] Real-time tracking opens correctly
- [ ] Can view order history

**Status**: ⬜ Pass | ⬜ Fail | ⬜ Blocked  
**Notes**: ************************\_************************

---

## 3. Admin Order Management Flow

### 3.1 Dashboard

- [ ] Admin dashboard loads successfully
- [ ] Dashboard statistics display correctly
  - [ ] Total orders
  - [ ] Pending orders
  - [ ] Active shipments
  - [ ] Revenue statistics
- [ ] Charts/graphs display correctly (if implemented)
- [ ] Recent activities show
- [ ] Navigation menu accessible

**Status**: ⬜ Pass | ⬜ Fail | ⬜ Blocked  
**Notes**: ************************\_************************

### 3.2 Order Management

- [ ] Admin can view all orders
- [ ] Orders list loads successfully
- [ ] Filter by status works (Pending, Confirmed, Shipped, Completed, Cancelled)
- [ ] Search orders functionality works
- [ ] Order details accessible
- [ ] Admin can update order status
- [ ] Status change confirmation dialog appears (if implemented)
- [ ] Status updates successfully
- [ ] Order history shows status changes

**Status**: ⬜ Pass | ⬜ Fail | ⬜ Blocked  
**Notes**: ************************\_************************

### 3.3 Driver Assignment

- [ ] Admin can view list of available drivers
- [ ] Driver status (Active/Inactive) visible
- [ ] Admin can assign driver to order/shipment
- [ ] Driver selection dialog works
- [ ] Assignment confirmation works
- [ ] Driver receives notification (if implemented)
- [ ] Assigned orders visible in driver dashboard

**Status**: ⬜ Pass | ⬜ Fail | ⬜ Blocked  
**Notes**: ************************\_************************

### 3.4 Product Management

- [ ] Admin can view all products
- [ ] Add new product works
- [ ] Edit product works
- [ ] Delete product works (with confirmation)
- [ ] Product stock updates correctly
- [ ] Product images upload successfully
- [ ] Product status (active/inactive) toggle works

**Status**: ⬜ Pass | ⬜ Fail | ⬜ Blocked  
**Notes**: ************************\_************************

### 3.5 User Management

- [ ] Admin can view all users
- [ ] Filter users by role (Admin, Mitra, Driver)
- [ ] View user details
- [ ] Update user status (activate/deactivate)
- [ ] View user activity/history

**Status**: ⬜ Pass | ⬜ Fail | ⬜ Blocked  
**Notes**: ************************\_************************

---

## 4. Driver Delivery Flow

### 4.1 Driver Dashboard

- [ ] Driver dashboard loads successfully
- [ ] Assigned deliveries visible
- [ ] Today's deliveries section works
- [ ] Pending deliveries section works
- [ ] Completed deliveries section works
- [ ] Delivery statistics display correctly
- [ ] Navigation between tabs works

**Status**: ⬜ Pass | ⬜ Fail | ⬜ Blocked  
**Notes**: ************************\_************************

### 4.2 Delivery Tasks

- [ ] Driver can view delivery task details
- [ ] Customer information visible
- [ ] Delivery address visible
- [ ] Pickup address visible
- [ ] Delivery instructions visible
- [ ] Contact customer button works (call/WhatsApp)
- [ ] Navigate button opens map/navigation

**Status**: ⬜ Pass | ⬜ Fail | ⬜ Blocked  
**Notes**: ************************\_************************

### 4.3 Delivery Status Updates

- [ ] Mark as Picked Up button works
- [ ] Pickup confirmation dialog appears
- [ ] Status updates successfully
- [ ] In-Transit status reflects correctly
- [ ] Mark as Delivered button works
- [ ] Delivery confirmation screen appears

**Status**: ⬜ Pass | ⬜ Fail | ⬜ Blocked  
**Notes**: ************************\_************************

### 4.4 Proof of Delivery

- [ ] Camera option works for POD photo
- [ ] Gallery option works for POD photo
- [ ] Photo preview displays
- [ ] Recipient name input works
- [ ] Signature pad works (if implemented)
- [ ] Submit proof of delivery works
- [ ] POD uploaded successfully
- [ ] Delivery marked as completed

**Status**: ⬜ Pass | ⬜ Fail | ⬜ Blocked  
**Notes**: ************************\_************************

---

## 5. Real-Time Tracking

### 5.1 Location Permissions

- [ ] App requests location permission appropriately
- [ ] Permission granted flow works
- [ ] Permission denied handled gracefully
- [ ] User can enable location from settings

**Status**: ⬜ Pass | ⬜ Fail | ⬜ Blocked  
**Notes**: ************************\_************************

### 5.2 Map Display

- [ ] Map loads correctly
- [ ] Driver location marker visible
- [ ] Pickup location marker visible
- [ ] Delivery location marker visible
- [ ] Route/polyline displays (if implemented)
- [ ] Map controls (zoom, pan) work correctly
- [ ] Current location button works

**Status**: ⬜ Pass | ⬜ Fail | ⬜ Blocked  
**Notes**: ************************\_************************

### 5.3 Real-Time Updates

- [ ] Driver location updates in real-time
- [ ] ETA updates dynamically
- [ ] Distance updates dynamically
- [ ] Status updates reflect immediately
- [ ] Multiple users can track simultaneously
- [ ] Updates work with app in background (if implemented)

**Status**: ⬜ Pass | ⬜ Fail | ⬜ Blocked  
**Notes**: ************************\_************************

### 5.4 Tracking for Admin/Mitra

- [ ] Admin can access tracking dashboard
- [ ] Admin can view all active deliveries on map
- [ ] Mitra can track their order
- [ ] Tracking information updates in real-time
- [ ] Driver contact information accessible
- [ ] Refresh button works

**Status**: ⬜ Pass | ⬜ Fail | ⬜ Blocked  
**Notes**: ************************\_************************

---

## 6. Error Handling

### 6.1 Network Errors

- [ ] No internet connection handled gracefully
- [ ] Appropriate error message shown
- [ ] Retry button works
- [ ] App doesn't crash on network errors
- [ ] Offline functionality works (if implemented)
- [ ] Network recovery handled smoothly

**Status**: ⬜ Pass | ⬜ Fail | ⬜ Blocked  
**Notes**: ************************\_************************

### 6.2 Validation Errors

- [ ] Email format validation works
- [ ] Password strength validation works
- [ ] Required field validation works
- [ ] Numeric field validation works
- [ ] Date field validation works
- [ ] Error messages are clear and helpful

**Status**: ⬜ Pass | ⬜ Fail | ⬜ Blocked  
**Notes**: ************************\_************************

### 6.3 Server Errors

- [ ] 404 errors handled gracefully
- [ ] 500 errors handled gracefully
- [ ] Timeout errors handled gracefully
- [ ] Authentication errors handled correctly
- [ ] Authorization errors handled correctly
- [ ] Error messages are user-friendly

**Status**: ⬜ Pass | ⬜ Fail | ⬜ Blocked  
**Notes**: ************************\_************************

---

## 7. Performance

### 7.1 App Launch

- [ ] App launches within 3 seconds
- [ ] Splash screen displays correctly
- [ ] No crashes on launch
- [ ] Smooth transition to main screen

**Status**: ⬜ Pass | ⬜ Fail | ⬜ Blocked  
**Notes**: ************************\_************************

### 7.2 Screen Navigation

- [ ] Navigation is smooth and responsive
- [ ] No lag when switching screens
- [ ] Back button works correctly
- [ ] Deep links work (if implemented)
- [ ] Navigation history maintained

**Status**: ⬜ Pass | ⬜ Fail | ⬜ Blocked  
**Notes**: ************************\_************************

### 7.3 Data Loading

- [ ] Lists load within reasonable time
- [ ] Loading indicators display correctly
- [ ] Pagination works (if implemented)
- [ ] Pull to refresh works
- [ ] Images load smoothly
- [ ] Cached data loads quickly

**Status**: ⬜ Pass | ⬜ Fail | ⬜ Blocked  
**Notes**: ************************\_************************

### 7.4 Memory Usage

- [ ] App doesn't cause device to slow down
- [ ] No memory leaks observed
- [ ] App runs smoothly with multiple features in use
- [ ] Background processes don't drain battery excessively

**Status**: ⬜ Pass | ⬜ Fail | ⬜ Blocked  
**Notes**: ************************\_************************

---

## 8. Device Testing

### 8.1 Android Testing

**Device**: ********\_******** | **OS Version**: ********\_********

- [ ] App installs successfully
- [ ] All features work as expected
- [ ] No crashes or freezes
- [ ] UI displays correctly on screen size
- [ ] Hardware back button works correctly
- [ ] App works in portrait orientation
- [ ] App works in landscape orientation (if supported)
- [ ] Notifications work (if implemented)
- [ ] App permissions work correctly

**Status**: ⬜ Pass | ⬜ Fail | ⬜ Blocked  
**Notes**: ************************\_************************

### 8.2 iOS Testing (if available)

**Device**: ********\_******** | **OS Version**: ********\_********

- [ ] App installs successfully
- [ ] All features work as expected
- [ ] No crashes or freezes
- [ ] UI displays correctly on screen size
- [ ] Swipe gestures work correctly
- [ ] App works in portrait orientation
- [ ] App works in landscape orientation (if supported)
- [ ] Notifications work (if implemented)
- [ ] App permissions work correctly

**Status**: ⬜ Pass | ⬜ Fail | ⬜ Blocked  
**Notes**: ************************\_************************

---

## 9. Security

### 9.1 Authentication Security

- [ ] Passwords are masked by default
- [ ] Session expires after timeout (if implemented)
- [ ] Can't access protected routes without authentication
- [ ] JWT tokens handled securely
- [ ] Logout clears all sensitive data

**Status**: ⬜ Pass | ⬜ Fail | ⬜ Blocked  
**Notes**: ************************\_************************

### 9.2 Data Security

- [ ] Sensitive data not visible in logs
- [ ] API keys not exposed in code
- [ ] User data encrypted in storage (if applicable)
- [ ] HTTPS used for all network requests

**Status**: ⬜ Pass | ⬜ Fail | ⬜ Blocked  
**Notes**: ************************\_************************

---

## 10. UI/UX

### 10.1 Visual Design

- [ ] UI follows consistent design system
- [ ] Colors are appropriate and accessible
- [ ] Text is readable at all sizes
- [ ] Icons are clear and meaningful
- [ ] Spacing and padding are consistent
- [ ] No UI elements overlap

**Status**: ⬜ Pass | ⬜ Fail | ⬜ Blocked  
**Notes**: ************************\_************************

### 10.2 User Experience

- [ ] Navigation is intuitive
- [ ] Actions provide immediate feedback
- [ ] Loading states are clear
- [ ] Success/error messages are helpful
- [ ] Forms are easy to complete
- [ ] Help/FAQ accessible (if implemented)

**Status**: ⬜ Pass | ⬜ Fail | ⬜ Blocked  
**Notes**: ************************\_************************

### 10.3 Accessibility

- [ ] Text size can be adjusted
- [ ] Contrast ratios are sufficient
- [ ] Interactive elements have adequate tap targets
- [ ] Screen reader support (basic)

**Status**: ⬜ Pass | ⬜ Fail | ⬜ Blocked  
**Notes**: ************************\_************************

---

## Summary

### Overall Test Results

- **Total Tests**: **\_**
- **Passed**: **\_**
- **Failed**: **\_**
- **Blocked**: **\_**
- **Pass Rate**: **\_**%

### Critical Issues Found

1. ***
2. ***
3. ***

### High Priority Issues

1. ***
2. ***
3. ***

### Medium Priority Issues

1. ***
2. ***
3. ***

### Low Priority Issues / Enhancements

1. ***
2. ***
3. ***

### Recommendations

---

---

---

### Sign-off

**Tester Name**: ********\_********  
**Signature**: ********\_********  
**Date**: ********\_********

**Reviewed By**: ********\_********  
**Signature**: ********\_********  
**Date**: ********\_********

---

## How to Use This Checklist

1. **Before Testing**:

   - Print or open this checklist digitally
   - Ensure all prerequisites are met
   - Have test credentials ready

2. **During Testing**:

   - Go through each section systematically
   - Check each item as you test it
   - Mark as Pass ✓, Fail ✗, or Blocked ⊘
   - Add detailed notes for any failures or issues
   - Take screenshots of issues when possible

3. **After Testing**:

   - Complete the summary section
   - Categorize issues by priority
   - Share results with development team
   - Schedule retesting after fixes

4. **Tips**:
   - Test on different devices/OS versions
   - Test with different network conditions
   - Test with different user roles
   - Document steps to reproduce any issues
   - Note device-specific issues clearly
