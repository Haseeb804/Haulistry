"""
Authentication API Routes
"""

from fastapi import APIRouter, HTTPException, Header, Depends
from typing import Optional
from services.auth_service import AuthService
from models.schemas import (
    SeekerRegisterRequest,
    ProviderRegisterRequest,
    LoginRequest,
    LoginResponse,
    TokenVerifyResponse,
    UserProfileResponse,
    MessageResponse,
    ErrorResponse
)

router = APIRouter(prefix="/api/auth", tags=["Authentication"])

# Initialize service
auth_service = AuthService()


async def get_token_from_header(authorization: Optional[str] = Header(None)) -> str:
    """
    Extract and verify token from Authorization header
    
    Args:
        authorization: Authorization header value
    
    Returns:
        str: Firebase ID token
    
    Raises:
        HTTPException: If token is missing or invalid
    """
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header missing")
    
    try:
        scheme, token = authorization.split()
        if scheme.lower() != "bearer":
            raise HTTPException(status_code=401, detail="Invalid authentication scheme")
        return token
    except ValueError:
        raise HTTPException(status_code=401, detail="Invalid authorization header format")


@router.post(
    "/register/seeker",
    response_model=LoginResponse,
    status_code=201,
    summary="Register a new seeker",
    description="Create a new seeker account with Firebase authentication and Neo4j storage"
)
async def register_seeker(request: SeekerRegisterRequest):
    """
    Register a new seeker user
    
    - **email**: Valid email address
    - **password**: Minimum 6 characters
    - **full_name**: User's full name
    - **phone**: Phone number with country code (e.g., +923001234567)
    """
    try:
        result = await auth_service.register_seeker(request)
        return LoginResponse(**result)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post(
    "/register/provider",
    response_model=LoginResponse,
    status_code=201,
    summary="Register a new provider",
    description="Create a new provider account with Firebase authentication and Neo4j storage"
)
async def register_provider(request: ProviderRegisterRequest):
    """
    Register a new provider user
    
    - **email**: Valid email address
    - **password**: Minimum 6 characters
    - **full_name**: Provider's full name
    - **phone**: Phone number with country code (e.g., +923001234567)
    - **business_name**: Name of the business
    - **business_type**: Type of business (e.g., heavy_machinery, transport)
    """
    try:
        result = await auth_service.register_provider(request)
        return LoginResponse(**result)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post(
    "/login",
    response_model=LoginResponse,
    summary="User login",
    description="""
    Login endpoint for both seekers and providers.
    
    **Important for Flutter Integration:**
    This endpoint returns a custom token that should be used with Firebase Authentication
    in your Flutter app using `signInWithCustomToken()`.
    
    For production use, implement proper password verification on the client side using
    Firebase Authentication SDK and send the ID token to this API for validation.
    """
)
async def login(request: LoginRequest):
    """
    Login user and get authentication token
    
    - **email**: User's email address
    - **password**: User's password
    
    Returns custom token and user data
    """
    try:
        result = await auth_service.login(request)
        return LoginResponse(**result)
    except Exception as e:
        raise HTTPException(status_code=401, detail=str(e))


@router.post(
    "/verify",
    response_model=TokenVerifyResponse,
    summary="Verify Firebase token",
    description="Verify a Firebase ID token and return user information"
)
async def verify_token(token: str = Depends(get_token_from_header)):
    """
    Verify Firebase ID token
    
    Send the Firebase ID token in the Authorization header:
    ```
    Authorization: Bearer <your_firebase_id_token>
    ```
    """
    try:
        is_valid, user_data = await auth_service.verify_firebase_token(token)
        
        if is_valid and user_data:
            return TokenVerifyResponse(
                valid=True,
                uid=user_data["uid"],
                email=user_data["email"],
                user_type=user_data.get("user_data", {}).get("user_type")
            )
        else:
            return TokenVerifyResponse(valid=False)
            
    except Exception as e:
        raise HTTPException(status_code=401, detail=f"Token verification failed: {str(e)}")


@router.get(
    "/profile",
    response_model=UserProfileResponse,
    summary="Get user profile",
    description="Get the authenticated user's profile information"
)
async def get_profile(token: str = Depends(get_token_from_header)):
    """
    Get user profile
    
    Requires valid Firebase ID token in Authorization header:
    ```
    Authorization: Bearer <your_firebase_id_token>
    ```
    """
    try:
        is_valid, user_data = await auth_service.verify_firebase_token(token)
        
        if not is_valid or not user_data:
            raise HTTPException(status_code=401, detail="Invalid token")
        
        profile = await auth_service.get_user_profile(user_data["uid"])
        
        if not profile:
            raise HTTPException(status_code=404, detail="User profile not found")
        
        return UserProfileResponse(
            uid=profile["uid"],
            email=profile["email"],
            user_type=profile["user_type"],
            profile=profile
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get(
    "/health",
    response_model=MessageResponse,
    summary="Health check",
    description="Check if the authentication service is running"
)
async def health_check():
    """
    Health check endpoint
    """
    return MessageResponse(
        message="Authentication service is running",
        success=True,
        data={"status": "healthy"}
    )


@router.post(
    "/logout",
    response_model=MessageResponse,
    summary="User logout",
    description="Logout endpoint (client-side token invalidation)"
)
async def logout(token: str = Depends(get_token_from_header)):
    """
    Logout user
    
    Note: Firebase Admin SDK doesn't provide server-side token invalidation.
    The client should remove the token from storage.
    This endpoint validates the token and confirms logout.
    """
    try:
        is_valid, user_data = await auth_service.verify_firebase_token(token)
        
        if not is_valid:
            raise HTTPException(status_code=401, detail="Invalid token")
        
        return MessageResponse(
            message="Logout successful. Remove token from client storage.",
            success=True,
            data={"uid": user_data["uid"]}
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
