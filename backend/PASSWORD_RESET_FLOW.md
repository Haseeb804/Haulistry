# Password Reset Flow

## Overview
Users can reset their password if they forget it by receiving a password reset email from Firebase Authentication.

## How It Works

### Frontend Flow

1. **User Navigation**
   - User clicks "Forgot Password?" link on login screen
   - Navigates to `/forgot-password` route

2. **Email Input**
   - User enters their registered email address
   - Form validates email format

3. **Reset Request**
   - User clicks "Send Reset Link" button
   - System calls `authService.resetPassword(email)`

4. **Firebase Processing**
   - Firebase Authentication sends password reset email
   - Email contains secure reset link

5. **Success/Error Handling**
   - **Success**: Shows confirmation screen with instructions
   - **Error**: Displays error message (invalid email, user not found, etc.)

6. **Email Sent Screen**
   - Confirms email was sent
   - Shows resend button (if user didn't receive email)
   - Provides return to login option

### Reset Email Flow

1. **User Receives Email**
   - Email sent to registered address
   - Contains secure, time-limited reset link

2. **User Clicks Link**
   - Opens in browser
   - Redirects to Firebase-hosted reset page

3. **New Password Entry**
   - User enters new password
   - Confirms new password

4. **Password Updated**
   - Firebase updates password in authentication system
   - User can now login with new password

## Implementation Details

### Frontend - AuthService Method

```dart
Future<bool> resetPassword(String email) async {
  try {
    _setLoading(true);
    _setError(null);

    await _auth.sendPasswordResetEmail(email: email);

    _setLoading(false);
    return true;
  } on FirebaseAuthException catch (e) {
    _setError(_handleFirebaseError(e));
    _setLoading(false);
    return false;
  } catch (e) {
    _setError(e.toString());
    _setLoading(false);
    return false;
  }
}
```

### Frontend - Screen Implementation

**File**: `lib/screens/auth/forgot_password_screen.dart`

**Key Features**:
- Email validation
- Loading states
- Success confirmation screen
- Resend email functionality
- Error handling with user-friendly messages
- Smooth animations

### Firebase Authentication

Firebase handles all backend logic:
- ✅ Email verification
- ✅ Secure link generation
- ✅ Link expiration (default: 1 hour)
- ✅ Password strength validation
- ✅ Email delivery

## User Experience

### Step 1: Request Reset
```
┌─────────────────────────┐
│   Forgot Password?      │
│                         │
│  Enter your email to    │
│  receive reset link     │
│                         │
│  ┌───────────────────┐  │
│  │ Email Address     │  │
│  └───────────────────┘  │
│                         │
│  [Send Reset Link]      │
│                         │
│  Back to Login          │
└─────────────────────────┘
```

### Step 2: Check Email
```
┌─────────────────────────┐
│   ✉️ Check Your Email    │
│                         │
│  We've sent a password  │
│  reset link to:         │
│                         │
│  user@example.com       │
│                         │
│  Didn't receive it?     │
│  [Resend Email]         │
│                         │
│  [Back to Login]        │
└─────────────────────────┘
```

### Step 3: Email Content
```
Subject: Reset your Haulistry password

Hello,

You recently requested to reset your password for 
your Haulistry account. Click the button below to 
reset it.

[Reset Password]

This link will expire in 1 hour.

If you didn't request a password reset, you can 
safely ignore this email.
```

### Step 4: Reset Password (Firebase Page)
```
┌─────────────────────────┐
│   Reset Password        │
│                         │
│  New Password:          │
│  ┌───────────────────┐  │
│  │ ••••••••          │  │
│  └───────────────────┘  │
│                         │
│  Confirm Password:      │
│  ┌───────────────────┐  │
│  │ ••••••••          │  │
│  └───────────────────┘  │
│                         │
│  [Reset Password]       │
└─────────────────────────┘
```

## Error Handling

### Common Errors

1. **Invalid Email Format**
   ```
   ❌ Please enter a valid email address
   ```

2. **Email Not Found**
   ```
   ❌ No account found with this email address
   ```

3. **Too Many Requests**
   ```
   ❌ Too many requests. Please try again later
   ```

4. **Network Error**
   ```
   ❌ Network error. Please check your connection
   ```

### Error Messages Handled

```dart
String _handleFirebaseError(FirebaseAuthException e) {
  switch (e.code) {
    case 'user-not-found':
      return 'No account found with this email';
    case 'invalid-email':
      return 'Invalid email address';
    case 'too-many-requests':
      return 'Too many attempts. Please try again later';
    default:
      return 'Failed to send reset email. Please try again';
  }
}
```

## Security Features

### Firebase Built-in Security

1. **Link Expiration**
   - Reset links expire after 1 hour
   - Prevents unauthorized access

2. **One-Time Use**
   - Each link can only be used once
   - Automatically invalidated after use

3. **Secure Token**
   - Cryptographically secure tokens
   - Cannot be guessed or brute-forced

4. **Rate Limiting**
   - Limits requests per IP
   - Prevents abuse

### Best Practices Implemented

✅ Email validation before sending
✅ Clear user feedback
✅ Resend functionality (with rate limiting)
✅ Error message sanitization
✅ No password exposure in UI
✅ Secure HTTPS communication

## Customization Options

### Email Template (Firebase Console)

1. Navigate to: Firebase Console → Authentication → Templates
2. Select: Password reset email
3. Customize:
   - Sender name
   - Subject line
   - Email content
   - Button text
   - Reply-to address

### Link Behavior

Configure in Firebase Console:
- Link expiration time
- Redirect URL after reset
- Continue URL behavior

## Testing

### Test Scenarios

1. **Valid Email**
   ```
   Input: registered@example.com
   Expected: Success message, email sent
   ```

2. **Unregistered Email**
   ```
   Input: notregistered@example.com
   Expected: Error message (user not found)
   ```

3. **Invalid Format**
   ```
   Input: notanemail
   Expected: Validation error
   ```

4. **Network Offline**
   ```
   Expected: Network error message
   ```

5. **Resend Email**
   ```
   Expected: New email sent, success message
   ```

## Future Enhancements

### Planned Features

1. **Custom Reset Page**
   - Host own password reset page
   - Match app branding
   - Better mobile experience

2. **SMS Reset Option**
   - Send reset code via SMS
   - Alternative to email

3. **Security Questions**
   - Additional verification step
   - Enhanced security

4. **Password Strength Indicator**
   - Visual feedback on password strength
   - Requirements checklist

5. **Recent Login Detection**
   - Alert if reset requested from unusual location
   - Require additional verification

## Troubleshooting

### Issue: Email not received

**Solutions**:
1. Check spam/junk folder
2. Verify email address is correct
3. Use resend button
4. Wait a few minutes (delivery delay)
5. Check email server settings

### Issue: Reset link expired

**Solutions**:
1. Request new reset email
2. Link valid for 1 hour only
3. Check timestamp on email

### Issue: Error after clicking link

**Solutions**:
1. Ensure link wasn't already used
2. Request new reset email
3. Clear browser cache
4. Try different browser

## API Reference

### AuthService Method

```dart
/// Send password reset email to user
///
/// @param email User's registered email address
/// @returns Future<bool> true if email sent successfully
Future<bool> resetPassword(String email)
```

**Parameters**:
- `email`: String - Valid email address

**Returns**:
- `true`: Email sent successfully
- `false`: Failed to send email (check errorMessage)

**Side Effects**:
- Sets loading state
- Updates error message on failure
- Triggers Firebase password reset flow

## Integration Points

### With Firebase Authentication
- Uses `sendPasswordResetEmail()` method
- Leverages Firebase email templates
- Relies on Firebase security features

### With Frontend Routing
- Route: `/forgot-password`
- Navigates from login screen
- Returns to login after completion

### With User Flow
1. Login screen → Forgot password link
2. Forgot password screen → Enter email
3. Success screen → Check email
4. Email link → Firebase reset page
5. Password reset → Login screen

## Compliance

### Data Privacy
- No password stored in plaintext
- Email only used for authentication
- Reset links are one-time use
- Minimal data exposure

### GDPR Compliance
- User initiated process
- Clear purpose communication
- Secure data handling
- Time-limited access

## Metrics to Track

### Success Metrics
- Password reset completion rate
- Email delivery rate
- Time to complete reset
- User satisfaction

### Error Metrics
- Failed attempts
- Invalid email submissions
- Link expiration rate
- Support tickets related to reset
