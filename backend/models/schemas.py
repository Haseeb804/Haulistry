"""
Pydantic Schemas for API Request/Response Validation
"""

from pydantic import BaseModel, EmailStr, Field, field_validator
from typing import Optional, Dict, Any
from enum import Enum


class UserTypeEnum(str, Enum):
    """User type enumeration for API"""
    SEEKER = "seeker"
    PROVIDER = "provider"


class SeekerRegisterRequest(BaseModel):
    """Request schema for seeker registration"""
    email: EmailStr = Field(..., description="User's email address")
    password: str = Field(
        ..., 
        min_length=6, 
        max_length=100,
        description="Password (minimum 6 characters, maximum 100 characters)"
    )
    full_name: str = Field(
        ..., 
        min_length=2, 
        max_length=100,
        description="User's full name (2-100 characters)"
    )
    phone: str = Field(
        ..., 
        pattern=r'^\+[1-9]\d{1,14}$',
        description="Phone number with country code (e.g., +923001234567)"
    )
    
    @field_validator('phone')
    @classmethod
    def validate_phone(cls, v):
        """Validate phone number format"""
        if not v.startswith('+'):
            raise ValueError('Phone number must start with country code (e.g., +92 for Pakistan)')
        if len(v) < 10:
            raise ValueError('Phone number is too short. Please enter a valid phone number.')
        if len(v) > 16:
            raise ValueError('Phone number is too long. Please enter a valid phone number.')
        # Check if contains only digits after +
        if not v[1:].isdigit():
            raise ValueError('Phone number must contain only digits after the + symbol.')
        return v
    
    @field_validator('full_name')
    @classmethod
    def validate_full_name(cls, v):
        """Validate full name"""
        if not v.strip():
            raise ValueError('Full name cannot be empty.')
        if len(v.strip()) < 2:
            raise ValueError('Full name must be at least 2 characters long.')
        if any(char.isdigit() for char in v):
            raise ValueError('Full name should not contain numbers.')
        return v.strip()
    
    @field_validator('password')
    @classmethod
    def validate_password(cls, v):
        """Validate password strength"""
        if len(v) < 6:
            raise ValueError('Password must be at least 6 characters long.')
        if len(v.strip()) != len(v):
            raise ValueError('Password cannot start or end with spaces.')
        # Optional: Add more password requirements
        # if not any(char.isdigit() for char in v):
        #     raise ValueError('Password must contain at least one number.')
        # if not any(char.isupper() for char in v):
        #     raise ValueError('Password must contain at least one uppercase letter.')
        return v
    
    model_config = {
        "json_schema_extra": {
            "examples": [
                {
                    "email": "john.doe@example.com",
                    "password": "SecurePass123",
                    "full_name": "John Doe",
                    "phone": "+923001234567"
                }
            ]
        }
    }


class ProviderRegisterRequest(BaseModel):
    """Request schema for provider registration"""
    email: EmailStr = Field(..., description="Provider's email address")
    password: str = Field(
        ..., 
        min_length=6, 
        max_length=100,
        description="Password (minimum 6 characters, maximum 100 characters)"
    )
    full_name: str = Field(
        ..., 
        min_length=2, 
        max_length=100,
        description="Provider's full name (2-100 characters)"
    )
    phone: str = Field(
        ..., 
        pattern=r'^\+[1-9]\d{1,14}$',
        description="Phone number with country code (e.g., +923001234567)"
    )
    
    # Optional business fields - can be added later in profile
    business_name: Optional[str] = Field(
        None,
        min_length=2,
        max_length=200,
        description="Business name (optional, can add later)"
    )
    business_type: Optional[str] = Field(
        None,
        description="Type of service (optional, can add later)"
    )
    service_type: Optional[str] = Field(
        None,
        description="Specific service category (optional)"
    )
    cnic_number: Optional[str] = Field(
        None,
        description="CNIC number (optional)"
    )
    address: Optional[str] = Field(
        None,
        description="Business address (optional)"
    )
    city: Optional[str] = Field(
        None,
        description="City (optional)"
    )
    province: Optional[str] = Field(
        None,
        description="Province (optional)"
    )
    years_experience: Optional[int] = Field(
        None,
        ge=0,
        le=50,
        description="Years of experience (optional)"
    )
    description: Optional[str] = Field(
        None,
        max_length=1000,
        description="Business description (optional)"
    )
    
    @field_validator('phone')
    @classmethod
    def validate_phone(cls, v):
        """Validate phone number format"""
        if not v.startswith('+'):
            raise ValueError('Phone number must start with country code (e.g., +92 for Pakistan)')
        if len(v) < 10:
            raise ValueError('Phone number is too short. Please enter a valid phone number.')
        if len(v) > 16:
            raise ValueError('Phone number is too long. Please enter a valid phone number.')
        if not v[1:].isdigit():
            raise ValueError('Phone number must contain only digits after the + symbol.')
        return v
    
    @field_validator('full_name')
    @classmethod
    def validate_full_name(cls, v):
        """Validate full name"""
        if not v.strip():
            raise ValueError('Full name cannot be empty.')
        if len(v.strip()) < 2:
            raise ValueError('Full name must be at least 2 characters long.')
        return v.strip()
    
    @field_validator('business_name')
    @classmethod
    def validate_business_name(cls, v):
        """Validate business name if provided"""
        if v is None:
            return v
        if not v.strip():
            raise ValueError('Business name cannot be empty.')
        if len(v.strip()) < 2:
            raise ValueError('Business name must be at least 2 characters long.')
        return v.strip()
    
    @field_validator('business_type')
    @classmethod
    def validate_business_type(cls, v):
        """Validate business type if provided"""
        if v is None:
            return v
        if not v.strip():
            raise ValueError('Service type cannot be empty. Please select a service.')
        
        # Allow any business type now, not just the 4 specific ones
        return v.strip().lower()
    
    @field_validator('password')
    @classmethod
    def validate_password(cls, v):
        """Validate password strength"""
        if len(v) < 6:
            raise ValueError('Password must be at least 6 characters long.')
        if len(v.strip()) != len(v):
            raise ValueError('Password cannot start or end with spaces.')
        return v
    
    model_config = {
        "json_schema_extra": {
            "examples": [
                {
                    "email": "provider@transportcompany.com",
                    "password": "SecurePass123",
                    "full_name": "Ahmed Khan",
                    "phone": "+923001234567",
                    "business_name": "Khan Transport Services",
                    "business_type": "heavy_machinery"
                }
            ]
        }
    }


class LoginRequest(BaseModel):
    """Request schema for user login"""
    email: EmailStr = Field(..., description="User's email address")
    password: str = Field(..., description="User's password")
    
    model_config = {
        "json_schema_extra": {
            "examples": [
                {
                    "email": "user@example.com",
                    "password": "securePass123"
                }
            ]
        }
    }


class LoginResponse(BaseModel):
    """Response schema for successful login"""
    uid: str = Field(..., description="Firebase user UID")
    email: str = Field(..., description="User's email address")
    custom_token: str = Field(..., description="Firebase custom token for authentication")
    user_type: UserTypeEnum = Field(..., description="Type of user (seeker or provider)")
    user_data: Dict[str, Any] = Field(..., description="User profile data from Neo4j")
    
    model_config = {
        "json_schema_extra": {
            "examples": [
                {
                    "uid": "firebase_uid_here",
                    "email": "user@example.com",
                    "custom_token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
                    "user_type": "seeker",
                    "user_data": {
                        "uid": "firebase_uid_here",
                        "email": "user@example.com",
                        "full_name": "John Doe",
                        "phone": "+923001234567"
                    }
                }
            ]
        }
    }


class TokenVerifyRequest(BaseModel):
    """Request schema for token verification"""
    token: str = Field(..., description="Firebase ID token to verify")


class TokenVerifyResponse(BaseModel):
    """Response schema for token verification"""
    valid: bool = Field(..., description="Whether token is valid")
    uid: Optional[str] = Field(None, description="User UID if token is valid")
    email: Optional[str] = Field(None, description="User email if token is valid")
    user_type: Optional[UserTypeEnum] = Field(None, description="User type if available")


class UserProfileResponse(BaseModel):
    """Response schema for user profile"""
    uid: str
    email: str
    user_type: UserTypeEnum
    profile: Dict[str, Any]


class MessageResponse(BaseModel):
    """Generic message response"""
    message: str = Field(..., description="Response message")
    success: bool = Field(default=True, description="Whether operation was successful")
    data: Optional[Dict[str, Any]] = Field(None, description="Additional data")
    
    model_config = {
        "json_schema_extra": {
            "examples": [
                {
                    "message": "Operation completed successfully",
                    "success": True,
                    "data": {"key": "value"}
                }
            ]
        }
    }


class ErrorResponse(BaseModel):
    """Error response schema"""
    detail: str = Field(..., description="Error detail message")
    error_code: Optional[str] = Field(None, description="Error code")
    
    model_config = {
        "json_schema_extra": {
            "examples": [
                {
                    "detail": "User not found",
                    "error_code": "USER_NOT_FOUND"
                }
            ]
        }
    }
