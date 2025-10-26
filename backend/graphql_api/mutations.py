"""
GraphQL Mutations for Haulistry
"""
import strawberry
from typing import Union
from .types import (
    AuthResponse, 
    ProviderAuthResponse,
    SeekerAuthResponse,
    SeekerRegisterInput, 
    ProviderRegisterInput,
    UpdateProviderProfileInput,
    UpdateSeekerProfileInput,
    LoginInput,
    ErrorResponse,
    Seeker,
    Provider,
    # Vehicle & Service types
    Vehicle,
    Service,
    AddVehicleInput,
    UpdateVehicleInput,
    AddServiceInput,
    UpdateServiceInput,
    VehicleResponse,
    ServiceResponse,
    GenericResponse,
    VehicleOnboardingInput
)
from services.auth_service import AuthService
from pydantic import ValidationError


@strawberry.type
class Mutation:
    @strawberry.mutation
    async def register_seeker(self, input: SeekerRegisterInput) -> AuthResponse:
        """
        Register a new seeker (customer looking to book services)
        
        Args:
            input: Seeker registration details
            
        Returns:
            AuthResponse with success status, message, token, and user data
        """
        print(f"\n{'='*60}")
        print(f"🔵 REGISTER_SEEKER MUTATION CALLED")
        print(f"   Email: {input.email}")
        print(f"   Full Name: {input.full_name}")
        print(f"   Phone: {input.phone}")
        print(f"{'='*60}\n")
        
        try:
            auth_service = AuthService()
            
            # Create Pydantic model from GraphQL input
            from models.schemas import SeekerRegisterRequest
            
            seeker_request = SeekerRegisterRequest(
                email=input.email,
                password=input.password,
                full_name=input.full_name,
                phone=input.phone
            )
            
            print(f"✅ Pydantic model created successfully")
            result = await auth_service.register_seeker(seeker_request)
            print(f"✅ Auth service returned: {result.keys()}")
            
            # Create User object from result
            user = Seeker(
                uid=result['user']['uid'],
                email=result['user']['email'],
                full_name=result['user']['full_name'],
                phone=result['user']['phone'],
                user_type=result['user']['user_type'],
                created_at=result['user']['created_at'],
                updated_at=result['user']['updated_at']
            )
            
            print(f"✅ Seeker GraphQL type created successfully")
            
            return AuthResponse(
                success=True,
                message="Seeker registered successfully! You can now log in.",
                token=result['token'],
                user=user
            )
            
        except ValidationError as e:
            error_messages = []
            for error in e.errors():
                field = error['loc'][0] if error['loc'] else 'field'
                msg = error['msg']
                error_messages.append(f"{field}: {msg}")
            
            return AuthResponse(
                success=False,
                message=f"Validation error: {'; '.join(error_messages)}",
                token=None,
                user=None
            )
            
        except Exception as e:
            return AuthResponse(
                success=False,
                message=str(e),
                token=None,
                user=None
            )

    @strawberry.mutation
    async def register_provider(self, input: ProviderRegisterInput) -> ProviderAuthResponse:
        """
        Register a new provider (service provider offering vehicles/equipment)
        
        Args:
            input: Provider registration details
            
        Returns:
            ProviderAuthResponse with success status, message, token, and user data
        """
        try:
            auth_service = AuthService()
            
            # Create Pydantic model from GraphQL input
            from models.schemas import ProviderRegisterRequest
            
            provider_request = ProviderRegisterRequest(
                email=input.email,
                password=input.password,
                full_name=input.full_name,
                phone=input.phone,
                business_name=input.business_name,
                business_type=input.business_type,
                service_type=input.service_type,
                cnic_number=input.cnic_number,
                address=input.address,
                city=input.city,
                province=input.province,
                years_experience=input.years_experience,
                description=input.description
            )
            
            result = await auth_service.register_provider(provider_request)
            
            # Create Provider object from result
            user = Provider(
                uid=result['user']['uid'],
                email=result['user']['email'],
                full_name=result['user']['full_name'],
                phone=result['user']['phone'],
                user_type=result['user']['user_type'],
                business_name=result['user'].get('business_name'),
                business_type=result['user'].get('business_type'),
                service_type=result['user'].get('service_type'),
                cnic_number=result['user'].get('cnic_number'),
                address=result['user'].get('address'),
                city=result['user'].get('city'),
                province=result['user'].get('province'),
                years_experience=result['user'].get('years_experience'),
                description=result['user'].get('description'),
                # Document images (initially None)
                profile_image=result['user'].get('profile_image'),
                cnic_front_image=result['user'].get('cnic_front_image'),
                cnic_back_image=result['user'].get('cnic_back_image'),
                license_image=result['user'].get('license_image'),
                license_number=result['user'].get('license_number'),
                # Verification (initially False/pending)
                is_verified=result['user'].get('is_verified', False),
                documents_uploaded=result['user'].get('documents_uploaded', False),
                verification_status=result['user'].get('verification_status', 'pending'),
                # Stats
                rating=result['user'].get('rating'),
                total_bookings=result['user'].get('total_bookings', 0),
                created_at=result['user']['created_at'],
                updated_at=result['user']['updated_at']
            )
            
            return ProviderAuthResponse(
                success=True,
                message="Provider registered successfully! You can now log in.",
                token=result['token'],
                user=user
            )
            
        except ValidationError as e:
            error_messages = []
            for error in e.errors():
                field = error['loc'][0] if error['loc'] else 'field'
                msg = error['msg']
                error_messages.append(f"{field}: {msg}")
            
            return ProviderAuthResponse(
                success=False,
                message=f"Validation error: {'; '.join(error_messages)}",
                token=None,
                user=None
            )
            
        except Exception as e:
            return ProviderAuthResponse(
                success=False,
                message=str(e),
                token=None,
                user=None
            )

    @strawberry.mutation
    async def login(self, input: LoginInput) -> Union[SeekerAuthResponse, ProviderAuthResponse]:
        """
        Login user (seeker or provider)
        
        Args:
            input: Login credentials with user type
            
        Returns:
            SeekerAuthResponse or ProviderAuthResponse based on user type
        """
        try:
            auth_service = AuthService()
            
            # Create Pydantic model from GraphQL input
            from models.schemas import LoginRequest
            
            login_request = LoginRequest(
                email=input.email,
                password=input.password,
                user_type=input.user_type
            )
            
            result = await auth_service.login(login_request)
            
            # Return appropriate response based on user type
            if result['user']['user_type'] == 'provider':
                user = Provider(
                    uid=result['user']['uid'],
                    email=result['user']['email'],
                    full_name=result['user']['full_name'],
                    phone=result['user']['phone'],
                    user_type=result['user']['user_type'],
                    business_name=result['user'].get('business_name'),
                    business_type=result['user'].get('business_type'),
                    service_type=result['user'].get('service_type'),
                    cnic_number=result['user'].get('cnic_number'),
                    address=result['user'].get('address'),
                    city=result['user'].get('city'),
                    province=result['user'].get('province'),
                    years_experience=result['user'].get('years_experience'),
                    description=result['user'].get('description'),
                    # Document images
                    profile_image=result['user'].get('profile_image'),
                    cnic_front_image=result['user'].get('cnic_front_image'),
                    cnic_back_image=result['user'].get('cnic_back_image'),
                    license_image=result['user'].get('license_image'),
                    license_number=result['user'].get('license_number'),
                    # Verification
                    is_verified=result['user'].get('is_verified', False),
                    documents_uploaded=result['user'].get('documents_uploaded', False),
                    verification_status=result['user'].get('verification_status', 'pending'),
                    # Stats
                    rating=result['user'].get('rating'),
                    total_bookings=result['user'].get('total_bookings', 0),
                    created_at=result['user']['created_at'],
                    updated_at=result['user']['updated_at']
                )
                
                return ProviderAuthResponse(
                    success=True,
                    message="Login successful! Welcome back.",
                    token=result['token'],
                    user=user
                )
            else:
                user = Seeker(
                    uid=result['user']['uid'],
                    email=result['user']['email'],
                    full_name=result['user']['full_name'],
                    phone=result['user']['phone'],
                    user_type=result['user']['user_type'],
                    profile_image=result['user'].get('profile_image'),
                    address=result['user'].get('address'),
                    bio=result['user'].get('bio'),
                    gender=result['user'].get('gender'),
                    date_of_birth=result['user'].get('date_of_birth'),
                    service_categories=result['user'].get('service_categories'),
                    category_details=result['user'].get('category_details'),
                    service_requirements=result['user'].get('service_requirements'),
                    primary_purpose=result['user'].get('primary_purpose'),
                    urgency=result['user'].get('urgency'),
                    preferences_notes=result['user'].get('preferences_notes'),
                    created_at=result['user']['created_at'],
                    updated_at=result['user']['updated_at']
                )
                
                return SeekerAuthResponse(
                    success=True,
                    message="Login successful! Welcome back.",
                    token=result['token'],
                    user=user
                )
            
        except Exception as e:
            # Return error response - default to SeekerAuthResponse if user_type unknown
            return SeekerAuthResponse(
                success=False,
                message=str(e),
                token=None,
                user=None
            )

    @strawberry.mutation
    async def update_provider_profile(self, input: UpdateProviderProfileInput) -> ProviderAuthResponse:
        """
        Update provider business profile with optional fields
        
        Args:
            input: Provider profile update details
            
        Returns:
            ProviderAuthResponse with updated user data
        """
        print(f"\n{'='*60}")
        print(f"🔵 UPDATE_PROVIDER_PROFILE MUTATION CALLED")
        print(f"   UID: {input.uid}")
        print(f"   Business Name: {input.business_name}")
        print(f"   Business Type: {input.business_type}")
        print(f"   Service Type: {input.service_type}")
        print(f"   CNIC: {input.cnic_number}")
        print(f"   Address: {input.address}")
        print(f"   City: {input.city}")
        print(f"   Province: {input.province}")
        print(f"   Years Experience: {input.years_experience}")
        print(f"   Description: {input.description}")
        print(f"{'='*60}\n")
        
        try:
            from repositories.user_repository import UserRepository
            
            user_repo = UserRepository()
            
            # Build update data dictionary
            update_data = {}
            if input.business_name is not None:
                update_data['business_name'] = input.business_name
            if input.business_type is not None:
                update_data['business_type'] = input.business_type
            if input.service_type is not None:
                update_data['service_type'] = input.service_type
            if input.cnic_number is not None:
                update_data['cnic_number'] = input.cnic_number
            if input.address is not None:
                update_data['address'] = input.address
            if input.city is not None:
                update_data['city'] = input.city
            if input.province is not None:
                update_data['province'] = input.province
            if input.years_experience is not None:
                update_data['years_experience'] = input.years_experience
            if input.description is not None:
                update_data['description'] = input.description
            # Document images
            if input.profile_image is not None:
                update_data['profile_image'] = input.profile_image
            if input.cnic_front_image is not None:
                update_data['cnic_front_image'] = input.cnic_front_image
            if input.cnic_back_image is not None:
                update_data['cnic_back_image'] = input.cnic_back_image
            if input.license_image is not None:
                update_data['license_image'] = input.license_image
            if input.license_number is not None:
                update_data['license_number'] = input.license_number
            
            print(f"📝 Updating {len(update_data)} fields in Neo4j...")
            
            # Update provider in Neo4j
            updated_user = user_repo.update_provider_profile(input.uid, update_data)
            
            if not updated_user:
                raise Exception("Failed to update provider profile. User not found.")
            
            # Handle vehicles if provided
            if input.vehicles is not None:
                import json
                from repositories.vehicle_repository import VehicleRepository
                
                vehicle_repo = VehicleRepository()
                vehicles_data = json.loads(input.vehicles)
                
                print(f"🚗 Processing {len(vehicles_data)} vehicles...")
                
                # Get existing vehicles to check for duplicates
                existing_vehicles = user_repo.get_provider_vehicles(input.uid)
                existing_registration_numbers = [v.get('registration_number') for v in existing_vehicles]
                
                for vehicle_data in vehicles_data:
                    try:
                        registration_number = vehicle_data['number']
                        
                        # Skip if vehicle with same registration number already exists
                        if registration_number in existing_registration_numbers:
                            print(f"   ⏭️  Skipping duplicate vehicle: {vehicle_data['type']} - {registration_number}")
                            continue
                        
                        # Create vehicle in Neo4j
                        vehicle_repo.create_vehicle(
                            provider_uid=input.uid,
                            vehicle_type=vehicle_data['type'],
                            registration_number=registration_number,
                            model=vehicle_data['model'],
                            vehicle_image=vehicle_data['image']
                        )
                        print(f"   ✅ Created vehicle: {vehicle_data['type']} - {registration_number}")
                    except Exception as ve:
                        print(f"   ⚠️ Failed to create vehicle {vehicle_data.get('number', 'unknown')}: {str(ve)}")
                
                # Clean up any duplicate vehicles that might have been created
                try:
                    deleted_count = vehicle_repo.remove_duplicate_vehicles(input.uid)
                    if deleted_count > 0:
                        print(f"🧹 Cleaned up {deleted_count} duplicate vehicle(s)")
                except Exception as cleanup_error:
                    print(f"⚠️  Cleanup warning: {str(cleanup_error)}")
            
            # Check if all 4 required documents are now uploaded
            has_all_docs = all([
                updated_user.get('profile_image'),
                updated_user.get('cnic_front_image'),
                updated_user.get('cnic_back_image'),
                updated_user.get('license_image')
            ])
            
            # If all documents are uploaded, update verification status
            if has_all_docs and not updated_user.get('documents_uploaded'):
                verification_update = {
                    'documents_uploaded': True,
                    'verification_status': 'pending'
                }
                updated_user = user_repo.update_provider_profile(input.uid, verification_update)
            
            # Create Provider object from result
            user = Provider(
                uid=updated_user['uid'],
                email=updated_user['email'],
                full_name=updated_user['full_name'],
                phone=updated_user['phone'],
                user_type=updated_user['user_type'],
                business_name=updated_user.get('business_name'),
                business_type=updated_user.get('business_type'),
                service_type=updated_user.get('service_type'),
                cnic_number=updated_user.get('cnic_number'),
                address=updated_user.get('address'),
                city=updated_user.get('city'),
                province=updated_user.get('province'),
                years_experience=updated_user.get('years_experience'),
                description=updated_user.get('description'),
                # Document images
                profile_image=updated_user.get('profile_image'),
                cnic_front_image=updated_user.get('cnic_front_image'),
                cnic_back_image=updated_user.get('cnic_back_image'),
                license_image=updated_user.get('license_image'),
                license_number=updated_user.get('license_number'),
                # Verification
                is_verified=updated_user.get('is_verified', False),
                documents_uploaded=updated_user.get('documents_uploaded', False),
                verification_status=updated_user.get('verification_status', 'pending'),
                # Stats
                rating=updated_user.get('rating'),
                total_bookings=updated_user.get('total_bookings', 0),
                created_at=updated_user['created_at'],
                updated_at=updated_user['updated_at']
            )
            
            return ProviderAuthResponse(
                success=True,
                message="Provider profile updated successfully!",
                token=None,  # Token remains the same
                user=user
            )
            
        except Exception as e:
            print(f"❌ UPDATE FAILED: {str(e)}\n")
            return ProviderAuthResponse(
                success=False,
                message=str(e),
                token=None,
                user=None
            )
    
    @strawberry.mutation
    async def update_seeker_profile(self, input: UpdateSeekerProfileInput) -> SeekerAuthResponse:
        """
        Update seeker profile with optional fields
        
        Args:
            input: Update seeker profile data
            
        Returns:
            SeekerAuthResponse: Updated seeker profile
        """
        try:
            print(f"\n{'='*60}")
            print(f"🔵 UPDATE_SEEKER_PROFILE MUTATION CALLED")
            print(f"   UID: {input.uid}")
            print(f"   Full Name: {input.full_name}")
            print(f"   Phone: {input.phone}")
            print(f"   Profile Image: {input.profile_image}")
            print(f"   Address: {input.address}")
            print(f"   Bio: {input.bio}")
            print(f"   Gender: {input.gender}")
            print(f"   Date of Birth: {input.date_of_birth}")
            print(f"   Service Categories: {input.service_categories}")
            print(f"   Primary Purpose: {input.primary_purpose}")
            print(f"   Urgency: {input.urgency}")
            print(f"{'='*60}\n")
            
            # Build update dictionary with only non-null fields
            update_data = {}
            
            if input.full_name is not None:
                update_data['full_name'] = input.full_name
                print(f"   ✓ Will update: full_name = {input.full_name}")
            
            if input.phone is not None:
                update_data['phone'] = input.phone
                print(f"   ✓ Will update: phone = {input.phone}")
            
            if input.profile_image is not None:
                update_data['profile_image'] = input.profile_image
                print(f"   ✓ Will update: profile_image = {input.profile_image}")
            
            if input.address is not None:
                update_data['address'] = input.address
                print(f"   ✓ Will update: address = {input.address}")
            
            if input.bio is not None:
                update_data['bio'] = input.bio
                print(f"   ✓ Will update: bio = {input.bio[:50] if input.bio else None}...")
            
            if input.gender is not None:
                update_data['gender'] = input.gender
                print(f"   ✓ Will update: gender = {input.gender}")
            
            if input.date_of_birth is not None:
                update_data['date_of_birth'] = input.date_of_birth
                print(f"   ✓ Will update: date_of_birth = {input.date_of_birth}")
            
            if input.service_categories is not None:
                update_data['service_categories'] = input.service_categories
                if input.service_categories in ['[]', '{}', '']:
                    print(f"   🗑️ CLEARING: service_categories = '{input.service_categories}'")
                else:
                    print(f"   ✓ Will update: service_categories (JSON)")
            
            if input.category_details is not None:
                update_data['category_details'] = input.category_details
                if input.category_details in ['[]', '{}', '']:
                    print(f"   🗑️ CLEARING: category_details = '{input.category_details}'")
                else:
                    print(f"   ✓ Will update: category_details (JSON)")
            
            if input.service_requirements is not None:
                update_data['service_requirements'] = input.service_requirements
                if input.service_requirements in ['[]', '{}', '']:
                    print(f"   🗑️ CLEARING: service_requirements = '{input.service_requirements}'")
                else:
                    print(f"   ✓ Will update: service_requirements (JSON)")
            
            if input.primary_purpose is not None:
                update_data['primary_purpose'] = input.primary_purpose
                if input.primary_purpose == '':
                    print(f"   🗑️ CLEARING: primary_purpose")
                else:
                    print(f"   ✓ Will update: primary_purpose = {input.primary_purpose}")
            
            if input.urgency is not None:
                update_data['urgency'] = input.urgency
                if input.urgency == '':
                    print(f"   🗑️ CLEARING: urgency")
                else:
                    print(f"   ✓ Will update: urgency = {input.urgency}")
            
            if input.preferences_notes is not None:
                update_data['preferences_notes'] = input.preferences_notes
                if input.preferences_notes == '':
                    print(f"   🗑️ CLEARING: preferences_notes")
                else:
                    print(f"   ✓ Will update: preferences_notes")
            
            print(f"\n📦 Total fields to update: {len(update_data)}")
            print(f"{'='*60}\n")
            
            if not update_data:
                return SeekerAuthResponse(
                    success=False,
                    message="No fields to update",
                    token=None,
                    user=None
                )
            
            # Update in repository
            from repositories.user_repository import UserRepository
            
            user_repo = UserRepository()
            
            # Verify seeker exists first
            print(f"🔍 Verifying seeker exists with UID: {input.uid}")
            try:
                updated_user = user_repo.update_seeker_profile(input.uid, update_data)
            except Exception as repo_error:
                print(f"❌ Repository error: {str(repo_error)}")
                import traceback
                traceback.print_exc()
                return SeekerAuthResponse(
                    success=False,
                    message=f"Failed to update profile: {str(repo_error)}",
                    token=None,
                    user=None
                )
            
            if not updated_user:
                print(f"❌ Seeker not found in Neo4j database")
                return SeekerAuthResponse(
                    success=False,
                    message="Seeker profile not found. Please try logging out and logging in again.",
                    token=None,
                    user=None
                )
            
            # Convert to Seeker GraphQL type
            print(f"✅ Converting updated data to GraphQL type...")
            print(f"   Fields being returned: {list(updated_user.keys())}")
            
            user = Seeker(
                uid=updated_user['uid'],
                email=updated_user['email'],
                full_name=updated_user['full_name'],
                phone=updated_user['phone'],
                user_type=updated_user['user_type'],
                profile_image=updated_user.get('profile_image'),
                address=updated_user.get('address'),
                bio=updated_user.get('bio'),
                gender=updated_user.get('gender'),
                date_of_birth=updated_user.get('date_of_birth'),
                service_categories=updated_user.get('service_categories'),
                category_details=updated_user.get('category_details'),
                service_requirements=updated_user.get('service_requirements'),
                primary_purpose=updated_user.get('primary_purpose'),
                urgency=updated_user.get('urgency'),
                preferences_notes=updated_user.get('preferences_notes'),
                created_at=updated_user['created_at'],
                updated_at=updated_user['updated_at']
            )
            
            print(f"✅ Seeker profile update complete!")
            print(f"{'='*60}\n")
            
            # Create similarity relationships if preferences were updated
            preferences_updated = any(key in update_data for key in [
                'service_categories', 'primary_purpose', 'urgency', 'address'
            ])
            
            if preferences_updated:
                print(f"\n🔗 Creating similarity relationships...")
                try:
                    relationship_result = user_repo.create_seeker_similarity_relationships(input.uid)
                    print(f"✅ Created {relationship_result['relationships_created']} relationships")
                    print(f"   Found {len(relationship_result.get('similar_seekers', []))} similar seekers\n")
                except Exception as rel_error:
                    print(f"⚠️ Warning: Could not create relationships: {str(rel_error)}")
                    # Don't fail the mutation if relationship creation fails
            
            return SeekerAuthResponse(
                success=True,
                message="Profile updated successfully!",
                token=None,  # Token remains the same
                user=user
            )
            
        except Exception as e:
            print(f"❌ UPDATE FAILED: {str(e)}\n")
            return SeekerAuthResponse(
                success=False,
                message=str(e),
                token=None,
                user=None
            )
    
    # ==================== VEHICLE MUTATIONS ====================
    
    @strawberry.mutation
    async def add_vehicle(self, input: 'AddVehicleInput') -> 'VehicleResponse':
        """
        Add a new vehicle for a provider
        
        Args:
            input: Vehicle details including provider_uid, vehicle info, pricing
            
        Returns:
            VehicleResponse with success status, message, and created vehicle
        """
        print(f"\n{'='*60}")
        print(f"🚗 ADD_VEHICLE MUTATION CALLED")
        print(f"   Provider UID: {input.provider_uid}")
        print(f"   Vehicle Name: {input.name}")
        print(f"   Type: {input.vehicle_type}")
        print(f"{'='*60}\n")
        
        try:
            import uuid
            from models.user import VehicleNode
            from repositories.user_repository import UserRepository
            
            # Generate vehicle_id
            vehicle_id = str(uuid.uuid4())
            
            # Create VehicleNode
            vehicle = VehicleNode(
                vehicle_id=vehicle_id,
                provider_uid=input.provider_uid,
                name=input.name,
                vehicle_type=input.vehicle_type,
                make=input.make,
                model=input.model,
                year=input.year,
                registration_number=input.registration_number,
                capacity=input.capacity,
                condition=input.condition,
                vehicle_image=input.vehicle_image,
                additional_images=input.additional_images,
                has_insurance=input.has_insurance,
                insurance_expiry=input.insurance_expiry,
                is_available=input.is_available,
                city=input.city,
                province=input.province,
                price_per_hour=input.price_per_hour,
                price_per_day=input.price_per_day,
                description=input.description
            )
            
            # Save to Neo4j
            user_repo = UserRepository()
            created_vehicle = user_repo.create_vehicle(vehicle)
            
            if created_vehicle:
                from .types import Vehicle, VehicleResponse
                return VehicleResponse(
                    success=True,
                    message="Vehicle added successfully!",
                    vehicle=Vehicle(**created_vehicle)
                )
            
            return VehicleResponse(
                success=False,
                message="Failed to create vehicle",
                vehicle=None
            )
            
        except Exception as e:
            print(f"❌ ADD VEHICLE FAILED: {str(e)}\n")
            from .types import VehicleResponse
            return VehicleResponse(
                success=False,
                message=f"Error: {str(e)}",
                vehicle=None
            )
    
    @strawberry.mutation
    async def update_vehicle(self, input: 'UpdateVehicleInput') -> 'VehicleResponse':
        """
        Update an existing vehicle
        
        Args:
            input: UpdateVehicleInput with vehicle_id and fields to update
            
        Returns:
            VehicleResponse with success status and updated vehicle
        """
        print(f"\n{'='*60}")
        print(f"🔧 UPDATE_VEHICLE MUTATION CALLED")
        print(f"   Vehicle ID: {input.vehicle_id}")
        print(f"{'='*60}\n")
        
        try:
            from repositories.user_repository import UserRepository
            
            # Build update dict (only non-None fields)
            update_data = {}
            if input.name is not None:
                update_data['name'] = input.name
            if input.vehicle_type is not None:
                update_data['vehicle_type'] = input.vehicle_type
            if input.make is not None:
                update_data['make'] = input.make
            if input.model is not None:
                update_data['model'] = input.model
            if input.year is not None:
                update_data['year'] = input.year
            if input.registration_number is not None:
                update_data['registration_number'] = input.registration_number
            if input.capacity is not None:
                update_data['capacity'] = input.capacity
            if input.condition is not None:
                update_data['condition'] = input.condition
            if input.vehicle_image is not None:
                update_data['vehicle_image'] = input.vehicle_image
            if input.additional_images is not None:
                update_data['additional_images'] = input.additional_images
            if input.has_insurance is not None:
                update_data['has_insurance'] = input.has_insurance
            if input.insurance_expiry is not None:
                update_data['insurance_expiry'] = input.insurance_expiry
            if input.is_available is not None:
                update_data['is_available'] = input.is_available
            if input.city is not None:
                update_data['city'] = input.city
            if input.province is not None:
                update_data['province'] = input.province
            if input.price_per_hour is not None:
                update_data['price_per_hour'] = input.price_per_hour
            if input.price_per_day is not None:
                update_data['price_per_day'] = input.price_per_day
            if input.description is not None:
                update_data['description'] = input.description
            
            # Update in Neo4j
            user_repo = UserRepository()
            updated_vehicle = user_repo.update_vehicle(input.vehicle_id, update_data)
            
            if updated_vehicle:
                from .types import Vehicle, VehicleResponse
                return VehicleResponse(
                    success=True,
                    message="Vehicle updated successfully!",
                    vehicle=Vehicle(**updated_vehicle)
                )
            
            return VehicleResponse(
                success=False,
                message="Vehicle not found",
                vehicle=None
            )
            
        except Exception as e:
            print(f"❌ UPDATE VEHICLE FAILED: {str(e)}\n")
            from .types import VehicleResponse
            return VehicleResponse(
                success=False,
                message=f"Error: {str(e)}",
                vehicle=None
            )
    
    @strawberry.mutation
    async def delete_vehicle(self, vehicle_id: str) -> 'GenericResponse':
        """
        Delete a vehicle and all its related services (CASCADE DELETE)
        
        Args:
            vehicle_id: ID of vehicle to delete
            
        Returns:
            GenericResponse with success status and message
        """
        print(f"\n{'='*60}")
        print(f"🗑️  DELETE_VEHICLE MUTATION CALLED")
        print(f"   Vehicle ID: {vehicle_id}")
        print(f"   ⚠️  Will also delete all related services (CASCADE)")
        print(f"{'='*60}\n")
        
        try:
            from repositories.user_repository import UserRepository
            
            user_repo = UserRepository()
            success = user_repo.delete_vehicle(vehicle_id)
            
            if success:
                from .types import GenericResponse
                return GenericResponse(
                    success=True,
                    message="Vehicle and related services deleted successfully"
                )
            
            return GenericResponse(
                success=False,
                message="Vehicle not found"
            )
            
        except Exception as e:
            print(f"❌ DELETE VEHICLE FAILED: {str(e)}\n")
            from .types import GenericResponse
            return GenericResponse(
                success=False,
                message=f"Error: {str(e)}"
            )
    
    # ==================== SERVICE MUTATIONS ====================
    
    @strawberry.mutation
    async def add_service(self, input: 'AddServiceInput') -> 'ServiceResponse':
        """
        Add a new service for a vehicle
        
        Args:
            input: Service details including vehicle_id, provider_uid, service info
            
        Returns:
            ServiceResponse with success status, message, and created service
        """
        print(f"\n{'='*60}")
        print(f"🛠️  ADD_SERVICE MUTATION CALLED")
        print(f"   Provider UID: {input.provider_uid}")
        print(f"   Vehicle ID: {input.vehicle_id}")
        print(f"   Service Name: {input.service_name}")
        print(f"   Category: {input.service_category}")
        print(f"{'='*60}\n")
        
        try:
            import uuid
            from models.user import ServiceNode
            from repositories.user_repository import UserRepository
            
            # Generate service_id
            service_id = str(uuid.uuid4())
            
            # Create ServiceNode
            service = ServiceNode(
                service_id=service_id,
                vehicle_id=input.vehicle_id,
                provider_uid=input.provider_uid,
                service_name=input.service_name,
                service_category=input.service_category,
                price_per_hour=input.price_per_hour,
                price_per_day=input.price_per_day,
                price_per_service=input.price_per_service,
                description=input.description,
                service_area=input.service_area,
                min_booking_duration=input.min_booking_duration,
                service_images=input.service_images,  # Added service images
                is_active=input.is_active,
                available_days=input.available_days,
                available_hours=input.available_hours,
                operator_included=input.operator_included,
                fuel_included=input.fuel_included,
                transportation_included=input.transportation_included
            )
            
            # Save to Neo4j
            user_repo = UserRepository()
            created_service = user_repo.create_service(service)
            
            if created_service:
                from .types import Service, ServiceResponse
                return ServiceResponse(
                    success=True,
                    message="Service added successfully!",
                    service=Service(**created_service)
                )
            
            return ServiceResponse(
                success=False,
                message="Failed to create service",
                service=None
            )
            
        except Exception as e:
            print(f"❌ ADD SERVICE FAILED: {str(e)}\n")
            from .types import ServiceResponse
            return ServiceResponse(
                success=False,
                message=f"Error: {str(e)}",
                service=None
            )
    
    @strawberry.mutation
    async def update_service(self, input: 'UpdateServiceInput') -> 'ServiceResponse':
        """
        Update an existing service
        
        Args:
            input: UpdateServiceInput with service_id and fields to update
            
        Returns:
            ServiceResponse with success status and updated service
        """
        print(f"\n{'='*60}")
        print(f"🔧 UPDATE_SERVICE MUTATION CALLED")
        print(f"   Service ID: {input.service_id}")
        print(f"{'='*60}\n")
        
        try:
            from repositories.user_repository import UserRepository
            
            # Build update dict (only non-None fields)
            update_data = {}
            if input.service_name is not None:
                update_data['service_name'] = input.service_name
            if input.service_category is not None:
                update_data['service_category'] = input.service_category
            if input.price_per_hour is not None:
                update_data['price_per_hour'] = input.price_per_hour
            if input.price_per_day is not None:
                update_data['price_per_day'] = input.price_per_day
            if input.price_per_service is not None:
                update_data['price_per_service'] = input.price_per_service
            if input.description is not None:
                update_data['description'] = input.description
            if input.service_area is not None:
                update_data['service_area'] = input.service_area
            if input.min_booking_duration is not None:
                update_data['min_booking_duration'] = input.min_booking_duration
            if input.is_active is not None:
                update_data['is_active'] = input.is_active
            if input.available_days is not None:
                update_data['available_days'] = input.available_days
            if input.available_hours is not None:
                update_data['available_hours'] = input.available_hours
            if input.operator_included is not None:
                update_data['operator_included'] = input.operator_included
            if input.fuel_included is not None:
                update_data['fuel_included'] = input.fuel_included
            if input.transportation_included is not None:
                update_data['transportation_included'] = input.transportation_included
            
            # Update in Neo4j
            user_repo = UserRepository()
            updated_service = user_repo.update_service(input.service_id, update_data)
            
            if updated_service:
                from .types import Service, ServiceResponse
                return ServiceResponse(
                    success=True,
                    message="Service updated successfully!",
                    service=Service(**updated_service)
                )
            
            return ServiceResponse(
                success=False,
                message="Service not found",
                service=None
            )
            
        except Exception as e:
            print(f"❌ UPDATE SERVICE FAILED: {str(e)}\n")
            from .types import ServiceResponse
            return ServiceResponse(
                success=False,
                message=f"Error: {str(e)}",
                service=None
            )
    
    @strawberry.mutation
    async def delete_service(self, service_id: str) -> 'GenericResponse':
        """
        Delete a service
        
        Args:
            service_id: ID of service to delete
            
        Returns:
            GenericResponse with success status and message
        """
        print(f"\n{'='*60}")
        print(f"🗑️  DELETE_SERVICE MUTATION CALLED")
        print(f"   Service ID: {service_id}")
        print(f"{'='*60}\n")
        
        try:
            from repositories.user_repository import UserRepository
            
            user_repo = UserRepository()
            success = user_repo.delete_service(service_id)
            
            if success:
                from .types import GenericResponse
                return GenericResponse(
                    success=True,
                    message="Service deleted successfully"
                )
            
            return GenericResponse(
                success=False,
                message="Service not found"
            )
            
        except Exception as e:
            print(f"❌ DELETE SERVICE FAILED: {str(e)}\n")
            from .types import GenericResponse
            return GenericResponse(
                success=False,
                message=f"Error: {str(e)}"
            )

