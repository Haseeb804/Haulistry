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
        profile_image: Optional[str] = None,
        cnic_image: Optional[str] = None,
        license_image: Optional[str] = None,
        license_number: Optional[str] = None,
        is_verified: bool = False,
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
        self.profile_image = profile_image
        self.cnic_image = cnic_image
        self.license_image = license_image
        self.license_number = license_number
        self.is_verified = is_verified
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
            "profile_image": self.profile_image,
            "cnic_image": self.cnic_image,
            "license_image": self.license_image,
            "license_number": self.license_number,
            "user_type": UserType.PROVIDER.value,
            "is_verified": self.is_verified,
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
            profile_image=data.get("profile_image"),
            cnic_image=data.get("cnic_image"),
            license_image=data.get("license_image"),
            license_number=data.get("license_number"),
            is_verified=data.get("is_verified", False),
            rating=data.get("rating", 0.0),
            total_bookings=data.get("total_bookings", 0),
            created_at=datetime.fromisoformat(data["created_at"]) if data.get("created_at") else None,
            updated_at=datetime.fromisoformat(data["updated_at"]) if data.get("updated_at") else None,
        )
