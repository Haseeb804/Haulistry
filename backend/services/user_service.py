"""
User Service
Handles user-related business logic
"""

from typing import Dict, Any, Optional, List
from repositories.user_repository import UserRepository
from models.user import UserType


class UserService:
    """Service for user-related operations"""
    
    def __init__(self):
        self.user_repo = UserRepository()
    
    async def get_user_by_uid(self, uid: str) -> Optional[Dict[str, Any]]:
        """Get user by UID"""
        user_data = self.user_repo.get_user_by_uid(uid)
        
        if user_data:
            # Add user_type to response
            if "Seeker" in user_data.get("labels", []):
                user_data["user_type"] = UserType.SEEKER.value
            elif "Provider" in user_data.get("labels", []):
                user_data["user_type"] = UserType.PROVIDER.value
            
            user_data.pop("labels", None)
        
        return user_data
    
    async def get_user_by_email(self, email: str) -> Optional[Dict[str, Any]]:
        """Get user by email"""
        user_data = self.user_repo.get_user_by_email(email)
        
        if user_data:
            # Add user_type to response
            if "Seeker" in user_data.get("labels", []):
                user_data["user_type"] = UserType.SEEKER.value
            elif "Provider" in user_data.get("labels", []):
                user_data["user_type"] = UserType.PROVIDER.value
            
            user_data.pop("labels", None)
        
        return user_data
    
    async def update_seeker_profile(self, uid: str, updates: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """Update seeker profile"""
        # Remove fields that shouldn't be updated directly
        protected_fields = ["uid", "email", "user_type", "created_at"]
        for field in protected_fields:
            updates.pop(field, None)
        
        return self.user_repo.update_seeker(uid, updates)
    
    async def update_provider_profile(self, uid: str, updates: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """Update provider profile"""
        # Remove fields that shouldn't be updated directly
        protected_fields = ["uid", "email", "user_type", "created_at", "rating", "total_bookings"]
        for field in protected_fields:
            updates.pop(field, None)
        
        return self.user_repo.update_provider(uid, updates)
    
    async def delete_user(self, uid: str) -> bool:
        """Delete user from Neo4j"""
        return self.user_repo.delete_user(uid)
    
    async def get_all_seekers(self, limit: int = 100, skip: int = 0) -> List[Dict[str, Any]]:
        """Get all seekers with pagination"""
        return self.user_repo.get_all_seekers(limit, skip)
    
    async def get_all_providers(self, limit: int = 100, skip: int = 0) -> List[Dict[str, Any]]:
        """Get all providers with pagination"""
        return self.user_repo.get_all_providers(limit, skip)
    
    async def search_providers(
        self,
        business_type: Optional[str] = None,
        min_rating: float = 0.0,
        is_verified: Optional[bool] = None,
        limit: int = 50
    ) -> List[Dict[str, Any]]:
        """Search providers with filters"""
        return self.user_repo.search_providers(
            business_type=business_type,
            min_rating=min_rating,
            is_verified=is_verified,
            limit=limit
        )
    
    async def verify_provider(self, uid: str) -> Optional[Dict[str, Any]]:
        """Mark provider as verified"""
        return self.user_repo.update_provider(uid, {"is_verified": True})
    
    async def update_provider_rating(self, uid: str, new_rating: float) -> Optional[Dict[str, Any]]:
        """Update provider rating"""
        return self.user_repo.update_provider(uid, {"rating": new_rating})
    
    async def increment_provider_bookings(self, uid: str) -> Optional[Dict[str, Any]]:
        """Increment provider's total bookings count"""
        provider = await self.get_user_by_uid(uid)
        
        if provider and provider.get("user_type") == UserType.PROVIDER.value:
            current_bookings = provider.get("total_bookings", 0)
            return self.user_repo.update_provider(uid, {"total_bookings": current_bookings + 1})
        
        return None
