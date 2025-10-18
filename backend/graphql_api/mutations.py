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
    Provider
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
                rating=result['user'].get('rating'),
                total_bookings=result['user'].get('total_bookings', 0),
                is_verified=result['user'].get('is_verified', False),
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
                    rating=result['user'].get('rating'),
                    total_bookings=result['user'].get('total_bookings', 0),
                    is_verified=result['user'].get('is_verified', False),
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
            
            print(f"📝 Updating {len(update_data)} fields in Neo4j...")
            
            # Update provider in Neo4j
            updated_user = user_repo.update_provider_profile(input.uid, update_data)
            
            if not updated_user:
                raise Exception("Failed to update provider profile. User not found.")
            
            print(f"✅ Provider profile updated successfully")
            print(f"   Updated fields: {list(update_data.keys())}\n")
            
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
                rating=updated_user.get('rating'),
                total_bookings=updated_user.get('total_bookings', 0),
                is_verified=updated_user.get('is_verified', False),
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
                print(f"   ✓ Will update: service_categories (JSON)")
            
            if input.category_details is not None:
                update_data['category_details'] = input.category_details
                print(f"   ✓ Will update: category_details (JSON)")
            
            if input.service_requirements is not None:
                update_data['service_requirements'] = input.service_requirements
                print(f"   ✓ Will update: service_requirements (JSON)")
            
            if input.primary_purpose is not None:
                update_data['primary_purpose'] = input.primary_purpose
                print(f"   ✓ Will update: primary_purpose = {input.primary_purpose}")
            
            if input.urgency is not None:
                update_data['urgency'] = input.urgency
                print(f"   ✓ Will update: urgency = {input.urgency}")
            
            if input.preferences_notes is not None:
                update_data['preferences_notes'] = input.preferences_notes
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

