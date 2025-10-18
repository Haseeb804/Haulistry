"""
Authentication Service
Handles user authentication using Firebase and Neo4j
"""

from typing import Dict, Any, Optional, Tuple
from firebase_admin import auth as firebase_auth
from firebase_admin.exceptions import FirebaseError
from config.firebase import create_user, verify_token, get_user_by_email, create_custom_token
from repositories.user_repository import UserRepository
from models.user import UserType, SeekerNode, ProviderNode
from models.schemas import SeekerRegisterRequest, ProviderRegisterRequest, LoginRequest


class AuthService:
    """Service for handling authentication operations"""
    
    def __init__(self):
        self.user_repo = UserRepository()
    
    async def register_seeker(self, request: SeekerRegisterRequest) -> Dict[str, Any]:
        """
        Register a new seeker
        
        Args:
            request: Seeker registration data
        
        Returns:
            dict: Registration result with user data
        
        Raises:
            Exception: If registration fails with descriptive error message
        """
        print(f"\n{'='*60}")
        print(f"🔵 REGISTER SEEKER CALLED (Backend)")
        print(f"   Email: {request.email}")
        print(f"   Name: {request.full_name}")
        print(f"   Phone: {request.phone}")
        print(f"{'='*60}\n")
        
        try:
            # Validate email format is already done by Pydantic
            
            # Check if user already exists in Neo4j database
            print("📋 Checking if user exists in Neo4j...")
            if self.user_repo.user_exists(email=request.email):
                print("❌ User already exists")
                raise Exception("An account with this email already exists. Please use a different email or try logging in.")
            print("✅ Email available")
            
            # Create user in Firebase Authentication
            print("🔥 Creating Firebase user...")
            try:
                firebase_user = create_user(
                    email=request.email,
                    password=request.password,
                    display_name=request.full_name,
                    phone=request.phone
                )
                print(f"✅ Firebase user created: {firebase_user.uid}")
            except FirebaseError as fe:
                print(f"❌ Firebase error: {str(fe)}")
                error_code = fe.code if hasattr(fe, 'code') else 'unknown'
                if 'EMAIL_EXISTS' in str(fe) or 'already exists' in str(fe).lower():
                    raise Exception("This email is already registered. Please login instead.")
                elif 'INVALID_EMAIL' in str(fe):
                    raise Exception("Invalid email format. Please enter a valid email address.")
                elif 'WEAK_PASSWORD' in str(fe):
                    raise Exception("Password is too weak. Please use at least 6 characters.")
                elif 'INVALID_PHONE' in str(fe):
                    raise Exception("Invalid phone number format. Please use format: +92xxxxxxxxxx")
                else:
                    raise Exception(f"Failed to create account: {str(fe)}")
            
            # Create seeker profile in Neo4j database
            print("💾 Creating Neo4j seeker node...")
            seeker = SeekerNode(
                uid=firebase_user.uid,
                email=request.email,
                full_name=request.full_name,
                phone=request.phone
            )
            
            try:
                seeker_data = self.user_repo.create_seeker(seeker)
                print(f"✅ Neo4j node created: {seeker_data}")
                
                if not seeker_data:
                    # Rollback: delete Firebase user if database creation fails
                    print("❌ Neo4j creation returned None, rolling back Firebase user...")
                    firebase_auth.delete_user(firebase_user.uid)
                    raise Exception("Failed to create user profile. Please try again.")
                    
            except Exception as db_error:
                # Rollback: delete Firebase user if database operation fails
                print(f"❌ Neo4j error: {str(db_error)}, rolling back...")
                try:
                    firebase_auth.delete_user(firebase_user.uid)
                except:
                    pass  # If rollback fails, log it but don't block error message
                raise Exception(f"Database error: {str(db_error)}. Please try again.")
            
            # Generate custom authentication token
            print("🔑 Generating custom token...")
            try:
                custom_token = create_custom_token(
                    firebase_user.uid, 
                    {"user_type": UserType.SEEKER.value}
                )
                print("✅ Token generated successfully")
            except Exception as token_error:
                print(f"❌ Token generation error: {str(token_error)}")
                raise Exception(f"Failed to generate authentication token: {str(token_error)}")
            
            print("✅ REGISTRATION COMPLETE\n")
            print("✅ REGISTRATION COMPLETE\n")
            return {
                "token": custom_token.decode('utf-8') if isinstance(custom_token, bytes) else custom_token,
                "user": seeker_data,
                "message": "Account created successfully! Welcome to Haulistry."
            }
            
        except Exception as e:
            # Re-raise with user-friendly message
            print(f"❌ SEEKER REGISTRATION FAILED: {str(e)}\n")
            error_msg = str(e)
            if "Registration failed:" in error_msg:
                raise
            raise Exception(f"Registration failed: {error_msg}")
    
    async def register_provider(self, request: ProviderRegisterRequest) -> Dict[str, Any]:
        """
        Register a new provider
        
        Args:
            request: Provider registration data
        
        Returns:
            dict: Registration result with user data
        
        Raises:
            Exception: If registration fails with descriptive error message
        """
        try:
            # Check if user already exists in Neo4j database
            if self.user_repo.user_exists(email=request.email):
                raise Exception("An account with this email already exists. Please use a different email or try logging in.")
            
            # Business fields are now optional - validate only if provided
            if request.business_name and len(request.business_name.strip()) < 2:
                raise Exception("Business name must be at least 2 characters long.")
            
            if request.business_type and len(request.business_type.strip()) < 2:
                raise Exception("Please select a valid business type.")
            
            # Create user in Firebase Authentication
            try:
                firebase_user = create_user(
                    email=request.email,
                    password=request.password,
                    display_name=request.full_name,
                    phone=request.phone
                )
            except FirebaseError as fe:
                if 'EMAIL_EXISTS' in str(fe) or 'already exists' in str(fe).lower():
                    raise Exception("This email is already registered. Please login instead.")
                elif 'INVALID_EMAIL' in str(fe):
                    raise Exception("Invalid email format. Please enter a valid email address.")
                elif 'WEAK_PASSWORD' in str(fe):
                    raise Exception("Password is too weak. Please use at least 6 characters.")
                elif 'INVALID_PHONE' in str(fe):
                    raise Exception("Invalid phone number format. Please use format: +92xxxxxxxxxx")
                else:
                    raise Exception(f"Failed to create account: {str(fe)}")
            
            # Create provider profile in Neo4j database with optional fields
            print(f"\n📋 PROVIDER REGISTRATION DATA:")
            print(f"   Required Fields:")
            print(f"   - Email: {request.email}")
            print(f"   - Full Name: {request.full_name}")
            print(f"   - Phone: {request.phone}")
            print(f"   Optional Fields:")
            print(f"   - Business Name: {request.business_name}")
            print(f"   - Business Type: {request.business_type}")
            print(f"   - Service Type: {request.service_type}")
            print(f"   - CNIC Number: {request.cnic_number}")
            print(f"   - Address: {request.address}")
            print(f"   - City: {request.city}")
            print(f"   - Province: {request.province}")
            print(f"   - Years Experience: {request.years_experience}")
            print(f"   - Description: {request.description}\n")
            
            provider = ProviderNode(
                uid=firebase_user.uid,
                email=request.email,
                full_name=request.full_name,
                phone=request.phone,
                business_name=request.business_name.strip() if request.business_name else None,
                business_type=request.business_type.strip() if request.business_type else None,
                service_type=request.service_type,
                cnic_number=request.cnic_number,
                address=request.address,
                city=request.city,
                province=request.province,
                years_experience=request.years_experience,
                description=request.description
            )
            
            try:
                provider_data = self.user_repo.create_provider(provider)
                
                if not provider_data:
                    # Rollback: delete Firebase user if database creation fails
                    firebase_auth.delete_user(firebase_user.uid)
                    raise Exception("Failed to create provider profile. Please try again.")
                    
            except Exception as db_error:
                # Rollback: delete Firebase user if database operation fails
                try:
                    firebase_auth.delete_user(firebase_user.uid)
                except:
                    pass  # If rollback fails, log it but don't block error message
                raise Exception(f"Database error: {str(db_error)}. Please try again.")
            
            # Generate custom authentication token
            try:
                custom_token = create_custom_token(
                    firebase_user.uid,
                    {"user_type": UserType.PROVIDER.value}
                )
            except Exception as token_error:
                raise Exception(f"Failed to generate authentication token: {str(token_error)}")
            
            return {
                "token": custom_token.decode('utf-8') if isinstance(custom_token, bytes) else custom_token,
                "user": provider_data,
                "message": f"Provider account created successfully! Welcome to Haulistry, {request.business_name}."
            }
            
        except Exception as e:
            # Re-raise with user-friendly message
            error_msg = str(e)
            if "Registration failed:" in error_msg:
                raise
            raise Exception(f"Registration failed: {error_msg}")
    
    async def login(self, request: LoginRequest) -> Dict[str, Any]:
        """
        Login user
        
        Note: This endpoint verifies user exists and returns a custom token.
        The Flutter app should use Firebase Authentication directly for password verification,
        then use this endpoint to get user data and custom token.
        
        Args:
            request: Login credentials
        
        Returns:
            dict: Login result with user data and custom token
        
        Raises:
            Exception: If login fails with descriptive error message
        """
        try:
            # Validate input
            if not request.email or not request.email.strip():
                raise Exception("Email is required. Please enter your email address.")
            
            if not request.password or len(request.password) < 6:
                raise Exception("Password must be at least 6 characters long.")
            
            # Get Firebase user by email
            try:
                firebase_user = get_user_by_email(request.email.strip())
            except Exception as fe:
                # Don't reveal if email exists or not for security
                raise Exception("Invalid email or password. Please check your credentials and try again.")
            
            # Get user profile from Neo4j database
            user_data = self.user_repo.get_user_by_uid(firebase_user.uid)
            
            if not user_data:
                raise Exception("User profile not found. Please contact support if this persists.")
            
            # Determine user type from database labels
            user_type = None
            if "Seeker" in user_data.get("labels", []):
                user_type = UserType.SEEKER.value
            elif "Provider" in user_data.get("labels", []):
                user_type = UserType.PROVIDER.value
            else:
                raise Exception("Invalid user account type. Please contact support.")
            
            # Remove internal labels from user_data before returning
            user_data.pop("labels", None)
            
            # Generate custom authentication token
            try:
                custom_token = create_custom_token(
                    firebase_user.uid,
                    {"user_type": user_type}
                )
            except Exception as token_error:
                raise Exception(f"Failed to generate authentication token. Please try again.")
            
            return {
                "token": custom_token.decode('utf-8') if isinstance(custom_token, bytes) else custom_token,
                "user": user_data,
                "message": f"Welcome back! Login successful."
            }
            
        except Exception as e:
            # Re-raise with user-friendly message
            error_msg = str(e)
            if "Login failed:" in error_msg:
                raise
            raise Exception(f"Login failed: {error_msg}")
    
    async def verify_firebase_token(self, id_token: str) -> Tuple[bool, Optional[Dict[str, Any]]]:
        """
        Verify Firebase ID token
        
        Args:
            id_token: Firebase ID token from client
        
        Returns:
            tuple: (is_valid, user_data)
        """
        try:
            decoded_token = verify_token(id_token)
            
            # Get user data from Neo4j
            user_data = self.user_repo.get_user_by_uid(decoded_token["uid"])
            
            if user_data:
                # Determine user type
                if "Seeker" in user_data.get("labels", []):
                    user_data["user_type"] = UserType.SEEKER.value
                elif "Provider" in user_data.get("labels", []):
                    user_data["user_type"] = UserType.PROVIDER.value
                
                user_data.pop("labels", None)
            
            return True, {
                "uid": decoded_token["uid"],
                "email": decoded_token.get("email"),
                "user_data": user_data
            }
            
        except Exception as e:
            return False, None
    
    async def get_user_profile(self, uid: str) -> Optional[Dict[str, Any]]:
        """
        Get user profile by UID
        
        Args:
            uid: Firebase user UID
        
        Returns:
            dict: User profile data
        """
        try:
            user_data = self.user_repo.get_user_by_uid(uid)
            
            if not user_data:
                return None
            
            # Determine user type
            if "Seeker" in user_data.get("labels", []):
                user_data["user_type"] = UserType.SEEKER.value
            elif "Provider" in user_data.get("labels", []):
                user_data["user_type"] = UserType.PROVIDER.value
            
            user_data.pop("labels", None)
            
            return user_data
            
        except Exception as e:
            raise Exception(f"Failed to get user profile: {str(e)}")
