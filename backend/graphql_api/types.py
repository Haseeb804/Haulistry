"""
GraphQL Types for Haulistry
"""
import strawberry
from typing import Optional
from datetime import datetime


@strawberry.type
class User:
    """Base User type for GraphQL"""
    uid: str
    email: str
    full_name: str
    phone: str
    user_type: str
    created_at: str
    updated_at: str


@strawberry.type
class Seeker(User):
    """Seeker user type - someone looking to book services"""
    profile_image: Optional[str] = None
    address: Optional[str] = None
    bio: Optional[str] = None
    gender: Optional[str] = None
    date_of_birth: Optional[str] = None
    service_categories: Optional[str] = None  # JSON string of list
    category_details: Optional[str] = None  # JSON string of map
    service_requirements: Optional[str] = None  # JSON string of map
    primary_purpose: Optional[str] = None
    urgency: Optional[str] = None
    preferences_notes: Optional[str] = None


@strawberry.type
class Provider(User):
    """Provider user type - someone offering services"""
    business_name: Optional[str] = None
    business_type: Optional[str] = None
    service_type: Optional[str] = None
    cnic_number: Optional[str] = None
    address: Optional[str] = None
    city: Optional[str] = None
    province: Optional[str] = None
    years_experience: Optional[int] = None
    description: Optional[str] = None
    rating: Optional[float] = None
    total_bookings: int = 0
    is_verified: bool = False


@strawberry.type
class AuthResponse:
    """Authentication response"""
    success: bool
    message: str
    token: Optional[str] = None
    user: Optional[User] = None


@strawberry.type
class SeekerAuthResponse:
    """Seeker authentication response"""
    success: bool
    message: str
    token: Optional[str] = None
    user: Optional[Seeker] = None


@strawberry.type
class ProviderAuthResponse:
    """Provider authentication response"""
    success: bool
    message: str
    token: Optional[str] = None
    user: Optional[Provider] = None


@strawberry.type
class ErrorResponse:
    """Error response type"""
    success: bool = False
    message: str
    code: Optional[str] = None


@strawberry.input
class SeekerRegisterInput:
    """Input for seeker registration"""
    email: str
    password: str
    full_name: str
    phone: str


@strawberry.input
class ProviderRegisterInput:
    """Input for provider registration"""
    email: str
    password: str
    full_name: str
    phone: str
    business_name: Optional[str] = None
    business_type: Optional[str] = None
    service_type: Optional[str] = None
    cnic_number: Optional[str] = None
    address: Optional[str] = None
    city: Optional[str] = None
    province: Optional[str] = None
    years_experience: Optional[int] = None
    description: Optional[str] = None


@strawberry.input
class UpdateProviderProfileInput:
    """Input for updating provider business profile"""
    uid: str
    business_name: Optional[str] = None
    business_type: Optional[str] = None
    service_type: Optional[str] = None
    cnic_number: Optional[str] = None
    address: Optional[str] = None
    city: Optional[str] = None
    province: Optional[str] = None
    years_experience: Optional[int] = None
    description: Optional[str] = None


@strawberry.input
class UpdateSeekerProfileInput:
    """Input for updating seeker profile"""
    uid: str
    full_name: Optional[str] = None
    phone: Optional[str] = None
    profile_image: Optional[str] = None
    address: Optional[str] = None
    bio: Optional[str] = None
    gender: Optional[str] = None
    date_of_birth: Optional[str] = None
    service_categories: Optional[str] = None  # JSON string
    category_details: Optional[str] = None  # JSON string
    service_requirements: Optional[str] = None  # JSON string
    primary_purpose: Optional[str] = None
    urgency: Optional[str] = None
    preferences_notes: Optional[str] = None


@strawberry.input
class LoginInput:
    """Input for login"""
    email: str
    password: str
    user_type: Optional[str] = None  # Optional - backend will auto-detect from Neo4j
