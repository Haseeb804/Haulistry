"""
Firebase Admin SDK Configuration
"""

import firebase_admin
from firebase_admin import credentials, auth
import os
from .settings import settings


_firebase_app = None


def initialize_firebase():
    """
    Initialize Firebase Admin SDK with service account credentials
    """
    global _firebase_app
    
    if _firebase_app is not None:
        return _firebase_app
    
    try:
        # Check if credentials file exists
        creds_path = settings.FIREBASE_CREDENTIALS_PATH
        if not os.path.exists(creds_path):
            raise FileNotFoundError(
                f"Firebase credentials file not found at {creds_path}. "
                "Please download from Firebase Console and save it."
            )
        
        # Initialize Firebase Admin SDK
        cred = credentials.Certificate(creds_path)
        _firebase_app = firebase_admin.initialize_app(cred)
        
        print(f"✅ Firebase initialized successfully")
        return _firebase_app
        
    except Exception as e:
        print(f"❌ Error initializing Firebase: {str(e)}")
        raise


def get_firebase_auth():
    """
    Get Firebase Auth instance
    """
    if _firebase_app is None:
        initialize_firebase()
    return auth


def create_user(email: str, password: str, display_name: str = None, phone: str = None):
    """
    Create a new Firebase user with email/password authentication enabled
    
    Args:
        email: User's email address
        password: User's password (will be set but user will sign in with custom token)
        display_name: User's display name (optional)
        phone: User's phone number (optional)
    
    Returns:
        UserRecord: Firebase user record
    """
    import time
    max_retries = 3
    retry_delay = 2  # seconds
    
    for attempt in range(max_retries):
        try:
            user_data = {
                "email": email,
                "password": password,
                "email_verified": True,  # Auto-verify email for better UX
                "disabled": False,  # Ensure account is enabled
            }
            
            if display_name:
                user_data["display_name"] = display_name
            if phone:
                user_data["phone_number"] = phone
            
            print(f"🔄 Creating Firebase user (attempt {attempt + 1}/{max_retries})...")
            user = auth.create_user(**user_data)
            
            print(f"✅ Firebase user created with:")
            print(f"   - UID: {user.uid}")
            print(f"   - Email: {user.email}")
            print(f"   - Email Verified: {user.email_verified}")
            print(f"   - Disabled: {user.disabled}")
            return user
            
        except Exception as e:
            error_msg = str(e)
            print(f"❌ Firebase creation attempt {attempt + 1} failed: {error_msg}")
            
            # Check if it's a network/connection issue
            if "Connection" in error_msg or "aborted" in error_msg or "timeout" in error_msg.lower():
                if attempt < max_retries - 1:
                    print(f"⏳ Retrying in {retry_delay} seconds...")
                    time.sleep(retry_delay)
                    retry_delay *= 2  # Exponential backoff
                    continue
                else:
                    raise Exception(f"Firebase connection failed after {max_retries} attempts. Please check your internet connection and try again.")
            else:
                # For other errors (email exists, invalid data, etc.), don't retry
                raise Exception(f"Failed to create Firebase user: {error_msg}")
    
    raise Exception("Failed to create Firebase user after multiple attempts")


def verify_token(id_token: str):
    """
    Verify Firebase ID token
    
    Args:
        id_token: Firebase ID token
    
    Returns:
        dict: Decoded token with user information
    """
    try:
        decoded_token = auth.verify_id_token(id_token)
        return decoded_token
    except Exception as e:
        raise Exception(f"Invalid token: {str(e)}")


def get_user_by_uid(uid: str):
    """
    Get user by Firebase UID
    
    Args:
        uid: Firebase user UID
    
    Returns:
        UserRecord: Firebase user record
    """
    try:
        user = auth.get_user(uid)
        return user
    except Exception as e:
        raise Exception(f"User not found: {str(e)}")


def get_user_by_email(email: str):
    """
    Get user by email
    
    Args:
        email: User's email address
    
    Returns:
        UserRecord: Firebase user record
    """
    try:
        user = auth.get_user_by_email(email)
        return user
    except Exception as e:
        raise Exception(f"User not found: {str(e)}")


def update_user(uid: str, **kwargs):
    """
    Update user properties
    
    Args:
        uid: Firebase user UID
        **kwargs: Properties to update
    
    Returns:
        UserRecord: Updated user record
    """
    try:
        user = auth.update_user(uid, **kwargs)
        return user
    except Exception as e:
        raise Exception(f"Failed to update user: {str(e)}")


def delete_user(uid: str):
    """
    Delete user
    
    Args:
        uid: Firebase user UID
    """
    try:
        auth.delete_user(uid)
    except Exception as e:
        raise Exception(f"Failed to delete user: {str(e)}")


def create_custom_token(uid: str, additional_claims: dict = None):
    """
    Create custom token for user with retry logic
    
    Args:
        uid: Firebase user UID
        additional_claims: Additional claims to include in token
    
    Returns:
        str: Custom token
    """
    import time
    max_retries = 3
    retry_delay = 1
    
    for attempt in range(max_retries):
        try:
            print(f"🔄 Generating custom token (attempt {attempt + 1}/{max_retries})...")
            token = auth.create_custom_token(uid, additional_claims)
            print(f"✅ Custom token generated successfully")
            return token
        except Exception as e:
            error_msg = str(e)
            print(f"❌ Token generation attempt {attempt + 1} failed: {error_msg}")
            
            if "Connection" in error_msg or "aborted" in error_msg or "timeout" in error_msg.lower():
                if attempt < max_retries - 1:
                    print(f"⏳ Retrying in {retry_delay} seconds...")
                    time.sleep(retry_delay)
                    retry_delay *= 2
                    continue
                else:
                    raise Exception(f"Failed to create custom token after {max_retries} attempts")
            else:
                raise Exception(f"Failed to create custom token: {error_msg}")
    
    raise Exception("Failed to create custom token")
