"""
User Models for Neo4j Database
"""

from enum import Enum
from datetime import datetime
from typing import Optional


class UserType(str, Enum):
    """User type enumeration"""
    SEEKER = "seeker"
    PROVIDER = "provider"


class SeekerNode:
    """
    Seeker user node model for Neo4j
    
    Represents a service seeker in the graph database
    """
    
    def __init__(
        self,
        uid: str,
        email: str,
        full_name: str,
        phone: str,
        profile_image: Optional[str] = None,
        address: Optional[str] = None,
        bio: Optional[str] = None,
        gender: Optional[str] = None,
        date_of_birth: Optional[str] = None,
        service_categories: Optional[str] = None,
        category_details: Optional[str] = None,
        service_requirements: Optional[str] = None,
        primary_purpose: Optional[str] = None,
        urgency: Optional[str] = None,
        preferences_notes: Optional[str] = None,
        created_at: Optional[datetime] = None,
        updated_at: Optional[datetime] = None,
    ):
        self.uid = uid
        self.email = email
        self.full_name = full_name
        self.phone = phone
        self.profile_image = profile_image
        self.address = address
        self.bio = bio
        self.gender = gender
        self.date_of_birth = date_of_birth
        self.service_categories = service_categories
        self.category_details = category_details
        self.service_requirements = service_requirements
        self.primary_purpose = primary_purpose
        self.urgency = urgency
        self.preferences_notes = preferences_notes
        self.created_at = created_at or datetime.utcnow()
        self.updated_at = updated_at or datetime.utcnow()
    
    def to_dict(self):
        """Convert to dictionary for Neo4j"""
        return {
            "uid": self.uid,
            "email": self.email,
            "full_name": self.full_name,
            "phone": self.phone,
            "profile_image": self.profile_image,
            "address": self.address,
            "bio": self.bio,
            "gender": self.gender,
            "date_of_birth": self.date_of_birth,
            "service_categories": self.service_categories,
            "category_details": self.category_details,
            "service_requirements": self.service_requirements,
            "primary_purpose": self.primary_purpose,
            "urgency": self.urgency,
            "preferences_notes": self.preferences_notes,
            "user_type": UserType.SEEKER.value,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }
    
    @classmethod
    def from_dict(cls, data: dict):
        """Create instance from dictionary"""
        return cls(
            uid=data.get("uid"),
            email=data.get("email"),
            full_name=data.get("full_name"),
            phone=data.get("phone"),
            profile_image=data.get("profile_image"),
            address=data.get("address"),
            bio=data.get("bio"),
            gender=data.get("gender"),
            date_of_birth=data.get("date_of_birth"),
            service_categories=data.get("service_categories"),
            category_details=data.get("category_details"),
            service_requirements=data.get("service_requirements"),
            primary_purpose=data.get("primary_purpose"),
            urgency=data.get("urgency"),
            preferences_notes=data.get("preferences_notes"),
            created_at=datetime.fromisoformat(data["created_at"]) if data.get("created_at") else None,
            updated_at=datetime.fromisoformat(data["updated_at"]) if data.get("updated_at") else None,
        )


class ProviderNode:
    """
    Provider user node model for Neo4j
    
    Represents a service provider in the graph database
    """
    
    def __init__(
        self,
        uid: str,
        email: str,
        full_name: str,
        phone: str,
        business_name: Optional[str] = None,
        business_type: Optional[str] = None,
        service_type: Optional[str] = None,
        cnic_number: Optional[str] = None,
        address: Optional[str] = None,
        city: Optional[str] = None,
        province: Optional[str] = None,
        years_experience: Optional[int] = None,
        description: Optional[str] = None,
        # Document Images (Base64 URLs)
        profile_image: Optional[str] = None,
        cnic_front_image: Optional[str] = None,
        cnic_back_image: Optional[str] = None,
        license_image: Optional[str] = None,
        license_number: Optional[str] = None,
        # Verification Status
        is_verified: bool = False,
        documents_uploaded: bool = False,
        verification_status: str = "pending",  # pending, approved, rejected
        # Rating & Stats
        rating: float = 0.0,
        total_bookings: int = 0,
        created_at: Optional[datetime] = None,
        updated_at: Optional[datetime] = None,
    ):
        self.uid = uid
        self.email = email
        self.full_name = full_name
        self.phone = phone
        self.business_name = business_name
        self.business_type = business_type
        self.service_type = service_type
        self.cnic_number = cnic_number
        self.address = address
        self.city = city
        self.province = province
        self.years_experience = years_experience
        self.description = description
        # Document images
        self.profile_image = profile_image
        self.cnic_front_image = cnic_front_image
        self.cnic_back_image = cnic_back_image
        self.license_image = license_image
        self.license_number = license_number
        # Verification
        self.is_verified = is_verified
        self.documents_uploaded = documents_uploaded
        self.verification_status = verification_status
        # Stats
        self.rating = rating
        self.total_bookings = total_bookings
        self.created_at = created_at or datetime.utcnow()
        self.updated_at = updated_at or datetime.utcnow()
    
    def to_dict(self):
        """Convert to dictionary for Neo4j"""
        return {
            "uid": self.uid,
            "email": self.email,
            "full_name": self.full_name,
            "phone": self.phone,
            "business_name": self.business_name,
            "business_type": self.business_type,
            "service_type": self.service_type,
            "cnic_number": self.cnic_number,
            "address": self.address,
            "city": self.city,
            "province": self.province,
            "years_experience": self.years_experience,
            "description": self.description,
            # Document images (Base64 URLs)
            "profile_image": self.profile_image,
            "cnic_front_image": self.cnic_front_image,
            "cnic_back_image": self.cnic_back_image,
            "license_image": self.license_image,
            "license_number": self.license_number,
            # Verification
            "user_type": UserType.PROVIDER.value,
            "is_verified": self.is_verified,
            "documents_uploaded": self.documents_uploaded,
            "verification_status": self.verification_status,
            # Stats
            "rating": self.rating,
            "total_bookings": self.total_bookings,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }
    
    @classmethod
    def from_dict(cls, data: dict):
        """Create instance from dictionary"""
        return cls(
            uid=data.get("uid"),
            email=data.get("email"),
            full_name=data.get("full_name"),
            phone=data.get("phone"),
            business_name=data.get("business_name"),
            business_type=data.get("business_type"),
            service_type=data.get("service_type"),
            cnic_number=data.get("cnic_number"),
            address=data.get("address"),
            city=data.get("city"),
            province=data.get("province"),
            years_experience=data.get("years_experience"),
            description=data.get("description"),
            # Document images
            profile_image=data.get("profile_image"),
            cnic_front_image=data.get("cnic_front_image"),
            cnic_back_image=data.get("cnic_back_image"),
            license_image=data.get("license_image"),
            license_number=data.get("license_number"),
            # Verification
            is_verified=data.get("is_verified", False),
            documents_uploaded=data.get("documents_uploaded", False),
            verification_status=data.get("verification_status", "pending"),
            # Stats
            rating=data.get("rating", 0.0),
            total_bookings=data.get("total_bookings", 0),
            created_at=datetime.fromisoformat(data["created_at"]) if data.get("created_at") else None,
            updated_at=datetime.fromisoformat(data["updated_at"]) if data.get("updated_at") else None,
        )


class VehicleNode:
    """
    Vehicle node model for Neo4j
    
    Represents a vehicle/equipment owned by a provider
    """
    
    def __init__(
        self,
        vehicle_id: str,
        provider_uid: str,
        name: str,
        vehicle_type: str,  # Harvester, Tractor, Crane, etc.
        make: str,
        model: str,
        year: int,
        registration_number: str,
        capacity: Optional[str] = None,  # e.g., "500 HP", "10 tons"
        condition: str = "Good",  # Excellent, Good, Fair, Average
        # Vehicle Images (Base64 URLs)
        vehicle_image: Optional[str] = None,  # Main vehicle image
        additional_images: Optional[str] = None,  # JSON array of Base64 images
        # Insurance and Availability
        has_insurance: bool = False,
        insurance_expiry: Optional[str] = None,
        is_available: bool = True,
        # Location
        city: Optional[str] = None,
        province: Optional[str] = None,
        # Pricing
        price_per_hour: Optional[float] = None,
        price_per_day: Optional[float] = None,
        # Description
        description: Optional[str] = None,
        # Metadata
        created_at: Optional[datetime] = None,
        updated_at: Optional[datetime] = None,
    ):
        self.vehicle_id = vehicle_id
        self.provider_uid = provider_uid
        self.name = name
        self.vehicle_type = vehicle_type
        self.make = make
        self.model = model
        self.year = year
        self.registration_number = registration_number
        self.capacity = capacity
        self.condition = condition
        # Images
        self.vehicle_image = vehicle_image
        self.additional_images = additional_images
        # Insurance
        self.has_insurance = has_insurance
        self.insurance_expiry = insurance_expiry
        self.is_available = is_available
        # Location
        self.city = city
        self.province = province
        # Pricing
        self.price_per_hour = price_per_hour
        self.price_per_day = price_per_day
        # Description
        self.description = description
        # Metadata
        self.created_at = created_at or datetime.utcnow()
        self.updated_at = updated_at or datetime.utcnow()
    
    def to_dict(self):
        """Convert instance to dictionary"""
        return {
            "vehicle_id": self.vehicle_id,
            "provider_uid": self.provider_uid,
            "name": self.name,
            "vehicle_type": self.vehicle_type,
            "make": self.make,
            "model": self.model,
            "year": self.year,
            "registration_number": self.registration_number,
            "capacity": self.capacity,
            "condition": self.condition,
            # Images
            "vehicle_image": self.vehicle_image,
            "additional_images": self.additional_images,
            # Insurance
            "has_insurance": self.has_insurance,
            "insurance_expiry": self.insurance_expiry,
            "is_available": self.is_available,
            # Location
            "city": self.city,
            "province": self.province,
            # Pricing
            "price_per_hour": self.price_per_hour,
            "price_per_day": self.price_per_day,
            # Description
            "description": self.description,
            # Metadata
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }
    
    @classmethod
    def from_dict(cls, data: dict):
        """Create instance from dictionary"""
        return cls(
            vehicle_id=data.get("vehicle_id"),
            provider_uid=data.get("provider_uid"),
            name=data.get("name"),
            vehicle_type=data.get("vehicle_type"),
            make=data.get("make"),
            model=data.get("model"),
            year=data.get("year"),
            registration_number=data.get("registration_number"),
            capacity=data.get("capacity"),
            condition=data.get("condition", "Good"),
            # Images
            vehicle_image=data.get("vehicle_image"),
            additional_images=data.get("additional_images"),
            # Insurance
            has_insurance=data.get("has_insurance", False),
            insurance_expiry=data.get("insurance_expiry"),
            is_available=data.get("is_available", True),
            # Location
            city=data.get("city"),
            province=data.get("province"),
            # Pricing
            price_per_hour=data.get("price_per_hour"),
            price_per_day=data.get("price_per_day"),
            # Description
            description=data.get("description"),
            # Metadata
            created_at=datetime.fromisoformat(data["created_at"]) if data.get("created_at") else None,
            updated_at=datetime.fromisoformat(data["updated_at"]) if data.get("updated_at") else None,
        )


class ServiceNode:
    """
    Service node model for Neo4j
    
    Represents a service offered by a provider for a specific vehicle
    """
    
    def __init__(
        self,
        service_id: str,
        vehicle_id: str,
        provider_uid: str,
        service_name: str,
        service_category: str,  # Heavy Machinery, Transport, Construction, etc.
        # Pricing
        price_per_hour: Optional[float] = None,
        price_per_day: Optional[float] = None,
        price_per_service: Optional[float] = None,
        # Service Details
        description: Optional[str] = None,
        service_area: Optional[str] = None,  # Cities/regions served
        min_booking_duration: Optional[str] = None,  # e.g., "4 hours", "1 day"
        # Images
        service_images: Optional[str] = None,  # JSON string array of base64 images
        # Availability
        is_active: bool = True,
        available_days: Optional[str] = None,  # JSON array of days
        available_hours: Optional[str] = None,  # e.g., "9 AM - 6 PM"
        # Requirements
        operator_included: bool = True,
        fuel_included: bool = False,
        transportation_included: bool = False,
        # Stats
        total_bookings: int = 0,
        rating: float = 0.0,
        # Metadata
        created_at: Optional[datetime] = None,
        updated_at: Optional[datetime] = None,
    ):
        self.service_id = service_id
        self.vehicle_id = vehicle_id
        self.provider_uid = provider_uid
        self.service_name = service_name
        self.service_category = service_category
        # Pricing
        self.price_per_hour = price_per_hour
        self.price_per_day = price_per_day
        self.price_per_service = price_per_service
        # Service Details
        self.description = description
        self.service_area = service_area
        self.min_booking_duration = min_booking_duration
        # Images
        self.service_images = service_images
        # Availability
        self.is_active = is_active
        self.available_days = available_days
        self.available_hours = available_hours
        # Requirements
        self.operator_included = operator_included
        self.fuel_included = fuel_included
        self.transportation_included = transportation_included
        # Stats
        self.total_bookings = total_bookings
        self.rating = rating
        # Metadata
        self.created_at = created_at or datetime.utcnow()
        self.updated_at = updated_at or datetime.utcnow()
    
    def to_dict(self):
        """Convert instance to dictionary"""
        return {
            "service_id": self.service_id,
            "vehicle_id": self.vehicle_id,
            "provider_uid": self.provider_uid,
            "service_name": self.service_name,
            "service_category": self.service_category,
            # Pricing
            "price_per_hour": self.price_per_hour,
            "price_per_day": self.price_per_day,
            "price_per_service": self.price_per_service,
            # Service Details
            "description": self.description,
            "service_area": self.service_area,
            "min_booking_duration": self.min_booking_duration,
            # Images
            "service_images": self.service_images,
            # Availability
            "is_active": self.is_active,
            "available_days": self.available_days,
            "available_hours": self.available_hours,
            # Requirements
            "operator_included": self.operator_included,
            "fuel_included": self.fuel_included,
            "transportation_included": self.transportation_included,
            # Stats
            "total_bookings": self.total_bookings,
            "rating": self.rating,
            # Metadata
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }
    
    @classmethod
    def from_dict(cls, data: dict):
        """Create instance from dictionary"""
        return cls(
            service_id=data.get("service_id"),
            vehicle_id=data.get("vehicle_id"),
            provider_uid=data.get("provider_uid"),
            service_name=data.get("service_name"),
            service_category=data.get("service_category"),
            # Pricing
            price_per_hour=data.get("price_per_hour"),
            price_per_day=data.get("price_per_day"),
            price_per_service=data.get("price_per_service"),
            # Service Details
            description=data.get("description"),
            service_area=data.get("service_area"),
            min_booking_duration=data.get("min_booking_duration"),
            # Images
            service_images=data.get("service_images"),
            # Availability
            is_active=data.get("is_active", True),
            available_days=data.get("available_days"),
            available_hours=data.get("available_hours"),
            # Requirements
            operator_included=data.get("operator_included", True),
            fuel_included=data.get("fuel_included", False),
            transportation_included=data.get("transportation_included", False),
            # Stats
            total_bookings=data.get("total_bookings", 0),
            rating=data.get("rating", 0.0),
            # Metadata
            created_at=datetime.fromisoformat(data["created_at"]) if data.get("created_at") else None,
            updated_at=datetime.fromisoformat(data["updated_at"]) if data.get("updated_at") else None,
        )
