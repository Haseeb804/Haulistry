"""
GraphQL Queries for Haulistry
"""
import strawberry
from typing import Optional, List, Union
from .types import User, Seeker, Provider, Vehicle, Service
from services.user_service import UserService
from strawberry.types import Info


@strawberry.type
class Query:
    @strawberry.field
    async def me(self, info: Info) -> Optional[Union[Seeker, Provider]]:
        """
        Get current authenticated user's profile
        
        Requires: Authorization header with valid Firebase token
        
        Returns:
            User object (Seeker or Provider) or None
        """
        try:
            # Get authorization header from context
            request = info.context.get("request")
            if not request:
                raise Exception("Request context not available")
            
            auth_header = request.headers.get("Authorization")
            if not auth_header or not auth_header.startswith("Bearer "):
                raise Exception("Authorization token required")
            
            token = auth_header.replace("Bearer ", "")
            
            # Verify token and get user
            from services.auth_service import AuthService
            auth_service = AuthService()
            user_data = await auth_service.verify_firebase_token(token)
            
            # Return appropriate user type
            if user_data['user_type'] == 'provider':
                return Provider(
                    uid=user_data['uid'],
                    email=user_data['email'],
                    full_name=user_data['full_name'],
                    phone=user_data['phone'],
                    user_type=user_data['user_type'],
                    business_name=user_data['business_name'],
                    business_type=user_data['business_type'],
                    description=user_data.get('description'),
                    location=user_data.get('location'),
                    rating=user_data.get('rating'),
                    total_bookings=user_data.get('total_bookings', 0),
                    is_verified=user_data.get('is_verified', False),
                    created_at=user_data['created_at'],
                    updated_at=user_data['updated_at']
                )
            else:
                return Seeker(
                    uid=user_data['uid'],
                    email=user_data['email'],
                    full_name=user_data['full_name'],
                    phone=user_data['phone'],
                    user_type=user_data['user_type'],
                    created_at=user_data['created_at'],
                    updated_at=user_data['updated_at']
                )
                
        except Exception as e:
            raise Exception(f"Authentication failed: {str(e)}")

    @strawberry.field
    async def user(self, uid: str) -> Optional[Union[Seeker, Provider]]:
        """
        Get user by UID
        
        Args:
            uid: User's unique identifier
            
        Returns:
            User object or None
        """
        try:
            user_service = UserService()
            user_data = await user_service.get_user_by_uid(uid)
            
            if not user_data:
                return None
            
            # Return appropriate user type
            if user_data['user_type'] == 'provider':
                return Provider(
                    uid=user_data['uid'],
                    email=user_data['email'],
                    full_name=user_data['full_name'],
                    phone=user_data['phone'],
                    user_type=user_data['user_type'],
                    business_name=user_data.get('business_name'),
                    business_type=user_data.get('business_type'),
                    service_type=user_data.get('service_type'),
                    cnic_number=user_data.get('cnic_number'),
                    address=user_data.get('address'),
                    city=user_data.get('city'),
                    province=user_data.get('province'),
                    years_experience=user_data.get('years_experience'),
                    description=user_data.get('description'),
                    # Document images
                    profile_image=user_data.get('profile_image'),
                    cnic_front_image=user_data.get('cnic_front_image'),
                    cnic_back_image=user_data.get('cnic_back_image'),
                    license_image=user_data.get('license_image'),
                    license_number=user_data.get('license_number'),
                    # Verification
                    is_verified=user_data.get('is_verified', False),
                    documents_uploaded=user_data.get('documents_uploaded', False),
                    verification_status=user_data.get('verification_status', 'pending'),
                    # Stats
                    rating=user_data.get('rating'),
                    total_bookings=user_data.get('total_bookings', 0),
                    created_at=user_data['created_at'],
                    updated_at=user_data['updated_at']
                )
            else:
                return Seeker(
                    uid=user_data['uid'],
                    email=user_data['email'],
                    full_name=user_data['full_name'],
                    phone=user_data['phone'],
                    user_type=user_data['user_type'],
                    profile_image=user_data.get('profile_image'),
                    address=user_data.get('address'),
                    bio=user_data.get('bio'),
                    gender=user_data.get('gender'),
                    date_of_birth=user_data.get('date_of_birth'),
                    service_categories=user_data.get('service_categories'),
                    category_details=user_data.get('category_details'),
                    service_requirements=user_data.get('service_requirements'),
                    primary_purpose=user_data.get('primary_purpose'),
                    urgency=user_data.get('urgency'),
                    preferences_notes=user_data.get('preferences_notes'),
                    created_at=user_data['created_at'],
                    updated_at=user_data['updated_at']
                )
                
        except Exception as e:
            raise Exception(f"Failed to fetch user: {str(e)}")

    @strawberry.field
    async def providers(
        self, 
        business_type: Optional[str] = None,
        location: Optional[str] = None,
        min_rating: Optional[float] = None,
        limit: int = 10,
        skip: int = 0
    ) -> List[Provider]:
        """
        Search for service providers
        
        Args:
            business_type: Filter by business type (harvester, sand_truck, brick_truck, crane)
            location: Filter by location
            min_rating: Minimum rating filter
            limit: Number of results to return (default: 10)
            skip: Number of results to skip for pagination (default: 0)
            
        Returns:
            List of Provider objects
        """
        try:
            user_service = UserService()
            
            # Build search filters
            filters = {}
            if business_type:
                filters['business_type'] = business_type
            if location:
                filters['location'] = location
            if min_rating:
                filters['min_rating'] = min_rating
            
            providers_data = user_service.search_providers(
                filters=filters,
                limit=limit,
                skip=skip
            )
            
            # Convert to Provider objects
            providers = []
            for provider_data in providers_data:
                providers.append(Provider(
                    uid=provider_data['uid'],
                    email=provider_data['email'],
                    full_name=provider_data['full_name'],
                    phone=provider_data['phone'],
                    user_type=provider_data['user_type'],
                    business_name=provider_data['business_name'],
                    business_type=provider_data['business_type'],
                    description=provider_data.get('description'),
                    location=provider_data.get('location'),
                    rating=provider_data.get('rating'),
                    total_bookings=provider_data.get('total_bookings', 0),
                    is_verified=provider_data.get('is_verified', False),
                    created_at=provider_data['created_at'],
                    updated_at=provider_data['updated_at']
                ))
            
            return providers
            
        except Exception as e:
            raise Exception(f"Failed to search providers: {str(e)}")

    @strawberry.field
    async def business_types(self) -> List[str]:
        """
        Get available business types
        
        Returns:
            List of supported business types
        """
        return [
            "harvester",
            "sand_truck",
            "brick_truck",
            "crane"
        ]

    @strawberry.field
    async def similar_seekers(self, uid: str, limit: int = 10) -> List[Seeker]:
        """
        Get seekers with similar preferences to the given seeker
        
        Args:
            uid: Seeker UID to find similar users for
            limit: Maximum number of similar seekers to return (default: 10)
            
        Returns:
            List of similar Seeker objects ordered by similarity score
        """
        try:
            print(f"\n{'='*60}")
            print(f"🔍 FINDING SIMILAR SEEKERS")
            print(f"   For UID: {uid}")
            print(f"   Limit: {limit}")
            print(f"{'='*60}\n")
            
            from repositories.user_repository import UserRepository
            user_repo = UserRepository()
            
            similar_seekers_data = user_repo.get_similar_seekers(uid, limit)
            
            if not similar_seekers_data:
                print(f"ℹ️ No similar seekers found\n")
                return []
            
            seekers = []
            for seeker_data in similar_seekers_data:
                print(f"   ✓ Found: {seeker_data['name']} (score: {seeker_data['similarity_score']})")
                seekers.append(Seeker(
                    uid=seeker_data['uid'],
                    email=seeker_data['email'],
                    full_name=seeker_data['name'],
                    phone='',  # Don't expose phone to other users
                    user_type='seeker',
                    service_categories=seeker_data.get('categories'),
                    primary_purpose=seeker_data.get('purpose'),
                    address=seeker_data.get('address'),
                    created_at='',
                    updated_at=''
                ))
            
            print(f"\n✅ Found {len(seekers)} similar seekers\n")
            return seekers
            
        except Exception as e:
            print(f"❌ Error finding similar seekers: {str(e)}\n")
            raise Exception(f"Failed to find similar seekers: {str(e)}")
    
    # ==================== VEHICLE QUERIES ====================
    
    @strawberry.field
    async def provider_vehicles(self, provider_uid: str) -> List['Vehicle']:
        """
        Get all vehicles owned by a specific provider
        
        Args:
            provider_uid: The provider's UID
            
        Returns:
            List of Vehicle objects
        """
        print(f"\n{'='*60}")
        print(f"🚗 PROVIDER_VEHICLES QUERY CALLED")
        print(f"   Provider UID: {provider_uid}")
        print(f"{'='*60}\n")
        
        try:
            from repositories.user_repository import UserRepository
            from .types import Vehicle
            
            user_repo = UserRepository()
            vehicles = user_repo.get_provider_vehicles(provider_uid)
            
            print(f"✅ Found {len(vehicles)} vehicles\n")
            
            return [Vehicle(**vehicle) for vehicle in vehicles]
            
        except Exception as e:
            print(f"❌ Error fetching vehicles: {str(e)}\n")
            raise Exception(f"Failed to fetch vehicles: {str(e)}")
    
    @strawberry.field
    async def vehicle_by_id(self, vehicle_id: str) -> Optional['Vehicle']:
        """
        Get a specific vehicle by ID
        
        Args:
            vehicle_id: The vehicle's ID
            
        Returns:
            Vehicle object or None if not found
        """
        print(f"\n{'='*60}")
        print(f"🔍 VEHICLE_BY_ID QUERY CALLED")
        print(f"   Vehicle ID: {vehicle_id}")
        print(f"{'='*60}\n")
        
        try:
            from repositories.user_repository import UserRepository
            from .types import Vehicle
            
            user_repo = UserRepository()
            vehicle = user_repo.get_vehicle_by_id(vehicle_id)
            
            if vehicle:
                print(f"✅ Vehicle found: {vehicle['name']}\n")
                return Vehicle(**vehicle)
            
            print(f"⚠️  Vehicle not found\n")
            return None
            
        except Exception as e:
            print(f"❌ Error fetching vehicle: {str(e)}\n")
            raise Exception(f"Failed to fetch vehicle: {str(e)}")
    
    # ==================== SERVICE QUERIES ====================
    
    @strawberry.field
    async def vehicle_services(self, vehicle_id: str) -> List['Service']:
        """
        Get all services provided by a specific vehicle
        
        Args:
            vehicle_id: The vehicle's ID
            
        Returns:
            List of Service objects
        """
        print(f"\n{'='*60}")
        print(f"🛠️  VEHICLE_SERVICES QUERY CALLED")
        print(f"   Vehicle ID: {vehicle_id}")
        print(f"{'='*60}\n")
        
        try:
            from repositories.user_repository import UserRepository
            from .types import Service
            
            user_repo = UserRepository()
            services = user_repo.get_vehicle_services(vehicle_id)
            
            print(f"✅ Found {len(services)} services\n")
            
            return [Service(**service) for service in services]
            
        except Exception as e:
            print(f"❌ Error fetching services: {str(e)}\n")
            raise Exception(f"Failed to fetch services: {str(e)}")
    
    @strawberry.field
    async def provider_services(self, provider_uid: str) -> List['Service']:
        """
        Get all services offered by a provider (across all vehicles)
        
        Args:
            provider_uid: The provider's UID
            
        Returns:
            List of Service objects
        """
        print(f"\n{'='*60}")
        print(f"🔧 PROVIDER_SERVICES QUERY CALLED")
        print(f"   Provider UID: {provider_uid}")
        print(f"{'='*60}\n")
        
        try:
            from repositories.user_repository import UserRepository
            from .types import Service
            
            user_repo = UserRepository()
            services = user_repo.get_provider_services(provider_uid)
            
            print(f"✅ Found {len(services)} services\n")
            
            return [Service(**service) for service in services]
            
        except Exception as e:
            print(f"❌ Error fetching services: {str(e)}\n")
            raise Exception(f"Failed to fetch services: {str(e)}")
    
    @strawberry.field
    async def service_by_id(self, service_id: str) -> Optional['Service']:
        """
        Get a specific service by ID
        
        Args:
            service_id: The service's ID
            
        Returns:
            Service object or None if not found
        """
        print(f"\n{'='*60}")
        print(f"🔍 SERVICE_BY_ID QUERY CALLED")
        print(f"   Service ID: {service_id}")
        print(f"{'='*60}\n")
        
        try:
            from repositories.user_repository import UserRepository
            from .types import Service
            
            user_repo = UserRepository()
            service = user_repo.get_service_by_id(service_id)
            
            if service:
                print(f"✅ Service found: {service['service_name']}\n")
                return Service(**service)
            
            print(f"⚠️  Service not found\n")
            return None
            
        except Exception as e:
            print(f"❌ Error fetching service: {str(e)}\n")
            raise Exception(f"Failed to fetch service: {str(e)}")

