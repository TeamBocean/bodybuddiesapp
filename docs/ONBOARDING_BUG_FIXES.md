# Onboarding & User Creation Bug Fixes

## Summary
Fixed critical bugs in the user onboarding flow that could cause users to authenticate but not have a Firestore document created, leaving them unable to use the app.

## Bugs Fixed

### 🐛 Critical Bug #1: Synchronous User Creation
**Problem**: `setUserInfo()` was synchronous and didn't wait for Firestore operation to complete
- Used `.set()` without `await`
- Returned `true` immediately, even if Firestore write failed
- If user had poor network or closed app quickly, document never got created

**Fix**:
- Made `setUserInfo()` async with proper `await`
- Added retry logic (3 attempts with exponential backoff)
- Added verification step to confirm document was created
- Uses `SetOptions(merge: true)` to avoid overwriting existing data
- Comprehensive error logging for debugging

**Location**: `lib/services/cloud_firestore.dart`

---

### 🐛 Bug #2: No Error Handling in Onboarding
**Problem**: If user creation failed, onboarding just printed "ERROR" with no user feedback
- User would see button work but nothing happen
- No way to retry
- User gets stuck

**Fix**:
- Created new `_OnboardingButton` stateful widget
- Shows loading spinner during user creation
- Displays clear error dialog if creation fails
- Provides "Try Again" option for users
- Better input validation with helpful error messages
- Prevents multiple submissions

**Location**: `lib/pages/on_boarding_page.dart`

---

### 🐛 Bug #3: Race Conditions in Sign-In
**Problem**: Sign-in buttons had race conditions
- `setState()` called before async operations finished
- `.then()` chains instead of proper `await`
- No null safety checks on `mounted`
- Could navigate to wrong screen on slow networks

**Fix**:
- Proper async/await flow
- Added `if (!mounted) return` checks
- Wrapped in try-catch-finally for error handling
- Better logging for debugging
- Shows error messages to users if sign-in fails

**Locations**: 
- `lib/widgets/google_sign_in_btn.dart`
- `lib/widgets/apple_sign_in_btn.dart`

---

### 🐛 Bug #4: No Retry Mechanism
**Problem**: If any step failed, user had no recovery option except manual admin intervention

**Fix**:
- Automatic retry with exponential backoff (1s, 2s, 3s delays)
- User-facing retry dialog
- Detailed logging for admin monitoring
- Graceful degradation

---

## Testing Recommendations

### Test Case 1: Poor Network Conditions
1. Enable network throttling
2. Sign up with new account
3. Verify user document is created (check logs)
4. Verify retry mechanism works

### Test Case 2: App Killed During Onboarding
1. Start onboarding
2. Kill app immediately after pressing "Next"
3. Reopen app
4. Verify user either completes onboarding or gets retry option

### Test Case 3: Network Failure
1. Disable network during onboarding
2. Press "Next"
3. Verify error dialog appears
4. Enable network
5. Press "Try Again"
6. Verify user creation succeeds

### Test Case 4: Happy Path
1. Sign in with Google/Apple
2. Complete onboarding
3. Verify user document exists in Firestore
4. Verify navigation to main app works
5. Check logs for successful creation message

---

## Monitoring

### Key Log Messages to Watch For:

**Success Flow**:
```
Creating user document for [userId] (attempt 1/3)
✅ User document created successfully for [userId]
```

**Failure Flow**:
```
❌ Error creating user document (attempt 1/3): [error]
Creating user document for [userId] (attempt 2/3)
...
CRITICAL: Failed to create user document after 3 attempts
```

**Sign-In Flow**:
```
Google sign-in successful for: [email]
User document exists, navigating to main app
```
OR
```
User document does not exist, navigating to onboarding
```

---

## Migration Notes

### For Existing Users with Missing Documents
If you encounter users who authenticated but don't have Firestore documents:

1. Use the admin script:
   ```bash
   node scripts/add_user_admin.js
   ```

2. Or use Firebase Console to manually create the document

3. With these fixes, this should no longer happen for new users

### Backward Compatibility
- All changes are backward compatible
- Existing users won't be affected
- Only improves new user onboarding flow

---

## Performance Impact
- Minimal: Added ~1-2 seconds max for user creation (with retries)
- Most users will see no difference (single attempt succeeds)
- Only users with network issues will see retry delays
- Exponential backoff prevents overwhelming Firestore

---

## Future Improvements
1. Consider adding analytics to track retry rates
2. Add monitoring alerts for CRITICAL errors
3. Consider background sync for offline users
4. Add user notification if account setup is pending

---

# Booking System Bug Fixes

## Summary
Fixed critical bug in the booking conflict detection logic that allowed overlapping 45-minute sessions to be booked.

## Bugs Fixed

### 🐛 Critical Bug #5: Overlapping Bookings Allowed
**Problem**: Booking system only checked for conflicts 15 and 30 minutes BEFORE a time slot, but not AFTER
- If someone booked at 10:00, the system would block 9:30 and 9:45
- But it would NOT block 10:15 and 10:30
- This allowed multiple people to book overlapping 45-minute sessions
- Example: Conor books 10:00, but someone else could still book 10:00, 10:15, or 10:30

**Root Cause**:
The conflict detection in `bookings_page.dart` only checked:
```dart
// Old code - only checked BEFORE
isAlreadyBooked(timeSlot - 15min)
isAlreadyBooked(timeSlot - 30min)
```

**Fix**:
Now properly checks ALL conflicting time slots (both before AND after):
```dart
// New code - checks current, before, AND after
isAlreadyBooked(timeSlot)        // Current slot
isAlreadyBooked(timeSlot - 15min)  // Before
isAlreadyBooked(timeSlot - 30min)  // Before
isAlreadyBooked(timeSlot + 15min)  // After ✅ NEW
isAlreadyBooked(timeSlot + 30min)  // After ✅ NEW
```

**How it works**:
- When checking if 10:15 is available, it checks if there are bookings at:
  - 10:15 (current slot)
  - 10:00 (would conflict - blocks this slot) ✅
  - 9:45 (would conflict)
  - 10:30 (would conflict)
  - 10:45 (would conflict)
- This ensures a 45-minute session blocks all overlapping slots

**Location**: `lib/pages/bookings_page.dart` (lines 125-165)

---

## Testing Recommendations

### Test Case 1: Basic Overlap Prevention
1. Book a session at 10:00
2. Try to book at 10:15
3. Verify 10:15 is NOT available ✅
4. Try to book at 10:30
5. Verify 10:30 is NOT available ✅
6. Try to book at 10:45
7. Verify 10:45 IS available ✅

### Test Case 2: Full Session Block
1. Book a session at 14:00
2. Verify the following slots are blocked:
   - 14:00 (exact time)
   - 14:15 (conflicts with 14:00-14:45)
   - 14:30 (conflicts with 14:00-14:45)
3. Verify the following slots are available:
   - 13:30 (ends before 14:00)
   - 14:45 (starts after 14:45)

### Test Case 3: Back-to-Back Sessions
1. Book session at 10:00 (10:00-10:45)
2. Verify 10:45 is available
3. Book session at 10:45 (10:45-11:30)
4. Verify both sessions coexist properly

---

## Impact
- **High Priority**: Prevents double-booking and scheduling conflicts
- **User Impact**: Ensures trainers don't get double-booked
- **Business Impact**: Prevents service quality issues and customer complaints
