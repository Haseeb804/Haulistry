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
    # Document images (Base64 URLs)
    profile_image: Optional[str] = None
    cnic_front_image: Optional[str] = None
    cnic_back_image: Optional[str] = None
    license_image: Optional[str] = None
    license_number: Optional[str] = None
    # Verification
    is_verified: bool = False
    documents_uploaded: bool = False
    verification_status: str = "pending"
    # Stats
    rating: Optional[float] = None
    total_bookings: int = 0


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
    # Document images (Base64 URLs)
    profile_image: Optional[str] = None
    cnic_front_image: Optional[str] = None
    cnic_back_image: Optional[str] = None
    license_image: Optional[str] = None
    license_number: Optional[str] = None
    # Vehicles (JSON string of vehicle array)
    vehicles: Optional[str] = None


@strawberry.input
class VehicleOnboardingInput:
    """Input for vehicle during onboarding process"""
    type: str  # Harvester, Tractor, Crane, Loader riksha
    number: str  # Registration number
    model: str
    image: str  # Base64 image


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


# ==================== VEHICLE & SERVICE TYPES ====================

@strawberry.type
class Vehicle:
    """Vehicle type for GraphQL"""
    vehicle_id: str
    provider_uid: str
    name: str
    vehicle_type: str
    make: Optional[str] = None
    model: str
    year: Optional[int] = None
    registration_number: str
    capacity: Optional[str] = None
    condition: str = "Good"
    # Images (Base64 URLs)
    vehicle_image: Optional[str] = None
    additional_images: Optional[str] = None
    # Insurance & Availability
    has_insurance: bool = False
    insurance_expiry: Optional[str] = None
    is_available: bool = True
    # Location
    city: Optional[str] = None
    province: Optional[str] = None
    # Pricing
    price_per_hour: Optional[float] = None
    price_per_day: Optional[float] = None
    description: Optional[str] = None
    # Metadata
    created_at: str
    updated_at: str


@strawberry.type
@strawberry.type
class Service:
    """Service type for GraphQL"""
    service_id: str
    vehicle_id: str
    provider_uid: str
    service_name: str
    service_category: str
    # Pricing
    price_per_hour: Optional[float] = None
    price_per_day: Optional[float] = None
    price_per_service: Optional[float] = None
    # Details
    description: Optional[str] = None
    service_area: Optional[str] = None
    min_booking_duration: Optional[str] = None
    # Location (Google Maps Integration)
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    full_address: Optional[str] = None
    city: Optional[str] = None
    province: Optional[str] = None
    # Images (Base64 encoded)
    service_images: Optional[str] = None  # JSON string array of base64 images
    # Availability
    is_active: bool = True
    available_days: Optional[str] = None
    available_hours: Optional[str] = None
    # Requirements
    operator_included: bool = True
    fuel_included: bool = False
    transportation_included: bool = False
    # Stats
    total_bookings: int = 0
    rating: float = 0.0
    # Metadata
    created_at: str
    updated_at: str


@strawberry.input
class AddVehicleInput:
    """Input for adding a new vehicle"""
    provider_uid: str
    name: str
    vehicle_type: str
    make: str
    model: str
    year: int
    registration_number: str
    capacity: Optional[str] = None
    condition: str = "Good"
    # Images (Base64 URLs)
    vehicle_image: Optional[str] = None
    additional_images: Optional[str] = None
    # Insurance
    has_insurance: bool = False
    insurance_expiry: Optional[str] = None
    is_available: bool = True
    # Location
    city: Optional[str] = None
    province: Optional[str] = None
    # Pricing
    price_per_hour: Optional[float] = None
    price_per_day: Optional[float] = None
    description: Optional[str] = None


@strawberry.input
class UpdateVehicleInput:
    """Input for updating vehicle"""
    vehicle_id: str
    name: Optional[str] = None
    vehicle_type: Optional[str] = None
    make: Optional[str] = None
    model: Optional[str] = None
    year: Optional[int] = None
    registration_number: Optional[str] = None
    capacity: Optional[str] = None
    condition: Optional[str] = None
    # Images
    vehicle_image: Optional[str] = None
    additional_images: Optional[str] = None
    # Insurance
    has_insurance: Optional[bool] = None
    insurance_expiry: Optional[str] = None
    is_available: Optional[bool] = None
    # Location
    city: Optional[str] = None
    province: Optional[str] = None
    # Pricing
    price_per_hour: Optional[float] = None
    price_per_day: Optional[float] = None
    description: Optional[str] = None


@strawberry.input
class AddServiceInput:
    """Input for adding a new service"""
    vehicle_id: str
    provider_uid: str
    service_name: str
    service_category: str
    # Pricing
    price_per_hour: Optional[float] = None
    price_per_day: Optional[float] = None
    price_per_service: Optional[float] = None
    # Details
    description: Optional[str] = None
    service_area: Optional[str] = None
    min_booking_duration: Optional[str] = None
    # Location (Google Maps Integration)
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    full_address: Optional[str] = None
    city: Optional[str] = None
    province: Optional[str] = None
    # Images (Base64 encoded)
    service_images: Optional[str] = None  # JSON string array of base64 images
    # Availability
    is_active: bool = True
    available_days: Optional[str] = None
    available_hours: Optional[str] = None
    # Requirements
    operator_included: bool = True
    fuel_included: bool = False
    transportation_included: bool = False


@strawberry.input
class UpdateServiceInput:
    """Input for updating service"""
    service_id: str
    service_name: Optional[str] = None
    service_category: Optional[str] = None
    # Pricing
    price_per_hour: Optional[float] = None
    price_per_day: Optional[float] = None
    price_per_service: Optional[float] = None
    # Details
    description: Optional[str] = None
    service_area: Optional[str] = None
    min_booking_duration: Optional[str] = None
    # Location (Google Maps Integration)
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    full_address: Optional[str] = None
    city: Optional[str] = None
    province: Optional[str] = None
    # Images (Base64 encoded)
    service_images: Optional[str] = None  # JSON string array of base64 images
    # Availability
    is_active: Optional[bool] = None
    available_days: Optional[str] = None
    available_hours: Optional[str] = None
    # Requirements
    operator_included: Optional[bool] = None
    fuel_included: Optional[bool] = None
    transportation_included: Optional[bool] = None


@strawberry.type
class VehicleResponse:
    """Response type for vehicle operations"""
    success: bool
    message: str
    vehicle: Optional[Vehicle] = None


@strawberry.type
class ServiceResponse:
    """Response type for service operations"""
    success: bool
    message: str
    service: Optional[Service] = None


@strawberry.type
class GenericResponse:
    """Generic response for delete operations"""
    success: bool
    message: str
