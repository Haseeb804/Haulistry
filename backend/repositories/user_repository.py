"""
User Repository - Neo4j Database Operations
"""

from typing import Optional, Dict, Any, List
from datetime import datetime
from config.neo4j_config import get_neo4j_driver
from models.user import UserType, SeekerNode, ProviderNode, VehicleNode, ServiceNode


class UserRepository:
    """Repository for user-related database operations"""
    
    def __init__(self):
        self.driver = get_neo4j_driver()
    
    def create_seeker(self, seeker: SeekerNode) -> Dict[str, Any]:
        """
        Create a new Seeker node in Neo4j
        
        Args:
            seeker: SeekerNode instance
        
        Returns:
            dict: Created seeker data
        """
        with self.driver.session() as session:
            # Debug: Print what we're trying to store
            seeker_dict = seeker.to_dict()
            print(f"\n{'='*60}")
            print(f"💾 CREATING SEEKER NODE IN NEO4J")
            print(f"   UID: {seeker_dict.get('uid')}")
            print(f"   Email: {seeker_dict.get('email')}")
            print(f"   Full Name: {seeker_dict.get('full_name')}")
            print(f"   Phone: {seeker_dict.get('phone')}")
            print(f"   Profile Image: {seeker_dict.get('profile_image')}")
            print(f"   Address: {seeker_dict.get('address')}")
            print(f"   Bio: {seeker_dict.get('bio')}")
            print(f"   Gender: {seeker_dict.get('gender')}")
            print(f"   Date of Birth: {seeker_dict.get('date_of_birth')}")
            print(f"{'='*60}\n")
            
            # Use CREATE + SET pattern to ensure null values are stored
            query = """
            CREATE (s:Seeker)
            SET s.uid = $uid,
                s.email = $email,
                s.full_name = $full_name,
                s.name = $full_name,
                s.phone = $phone,
                s.profile_image = $profile_image,
                s.address = $address,
                s.bio = $bio,
                s.gender = $gender,
                s.date_of_birth = $date_of_birth,
                s.service_categories = $service_categories,
                s.category_details = $category_details,
                s.service_requirements = $service_requirements,
                s.primary_purpose = $primary_purpose,
                s.urgency = $urgency,
                s.preferences_notes = $preferences_notes,
                s.user_type = $user_type,
                s.created_at = datetime($created_at),
                s.updated_at = datetime($updated_at)
            RETURN s
            """
            
            result = session.run(query, **seeker_dict)
            record = result.single()
            
            if record:
                node_data = dict(record["s"])
                print(f"✅ Seeker node created successfully")
                print(f"   Total properties: {len(node_data)}")
                
                # Show which optional fields are non-null
                optional_fields = ['profile_image', 'address', 'bio', 'gender', 'date_of_birth']
                non_null = [f for f in optional_fields if node_data.get(f) is not None]
                if non_null:
                    print(f"   Optional fields with values: {non_null}")
                print()
                return node_data
            return None
    
    def create_provider(self, provider: ProviderNode) -> Dict[str, Any]:
        """
        Create a new Provider node in Neo4j
        
        Args:
            provider: ProviderNode instance
        
        Returns:
            dict: Created provider data
        """
        with self.driver.session() as session:
            # Debug: Print what we're trying to store
            provider_dict = provider.to_dict()
            print(f"\n{'='*60}")
            print(f"💾 CREATING PROVIDER NODE IN NEO4J")
            print(f"   UID: {provider_dict.get('uid')}")
            print(f"   Email: {provider_dict.get('email')}")
            print(f"   Full Name: {provider_dict.get('full_name')}")
            print(f"   Phone: {provider_dict.get('phone')}")
            print(f"   Business Name: {provider_dict.get('business_name')}")
            print(f"   Business Type: {provider_dict.get('business_type')}")
            print(f"   Service Type: {provider_dict.get('service_type')}")
            print(f"   CNIC Number: {provider_dict.get('cnic_number')}")
            print(f"   Address: {provider_dict.get('address')}")
            print(f"   City: {provider_dict.get('city')}")
            print(f"   Province: {provider_dict.get('province')}")
            print(f"   Years Experience: {provider_dict.get('years_experience')}")
            print(f"   Description: {provider_dict.get('description')}")
            print(f"{'='*60}\n")
            
            # Build properties dynamically - include all fields even if None
            # Neo4j will store them as null, which is what we want
            query = """
            CREATE (p:Provider)
            SET p.uid = $uid,
                p.email = $email,
                p.full_name = $full_name,
                p.name = $full_name,
                p.phone = $phone,
                p.business_name = $business_name,
                p.business_type = $business_type,
                p.service_type = $service_type,
                p.cnic_number = $cnic_number,
                p.address = $address,
                p.city = $city,
                p.province = $province,
                p.years_experience = $years_experience,
                p.description = $description,
                p.profile_image = $profile_image,
                p.cnic_front_image = $cnic_front_image,
                p.cnic_back_image = $cnic_back_image,
                p.license_image = $license_image,
                p.license_number = $license_number,
                p.user_type = $user_type,
                p.is_verified = $is_verified,
                p.documents_uploaded = $documents_uploaded,
                p.verification_status = $verification_status,
                p.rating = $rating,
                p.total_bookings = $total_bookings,
                p.created_at = datetime($created_at),
                p.updated_at = datetime($updated_at)
            RETURN p
            """
            
            result = session.run(query, **provider_dict)
            record = result.single()
            
            if record:
                node_data = dict(record["p"])
                print(f"✅ Provider node created successfully")
                print(f"   Stored properties: {len(node_data)} fields")
                print(f"   Property names: {list(node_data.keys())}")
                
                # Print non-null optional fields
                optional_fields = ['business_name', 'business_type', 'service_type', 
                                 'cnic_number', 'address', 'city', 'province', 
                                 'years_experience', 'description']
                stored_optional = [f for f in optional_fields if node_data.get(f) is not None]
                if stored_optional:
                    print(f"   ✅ Optional fields stored: {stored_optional}")
                else:
                    print(f"   ⚠️  No optional fields were provided")
                    
                return node_data
            return None
    
    def get_user_by_uid(self, uid: str) -> Optional[Dict[str, Any]]:
        """
        Get user by Firebase UID (checks both Seeker and Provider)
        
        Args:
            uid: Firebase user UID
        
        Returns:
            dict: User data or None
        """
        with self.driver.session() as session:
            query = """
            MATCH (u)
            WHERE (u:Seeker OR u:Provider) AND u.uid = $uid
            RETURN u, labels(u) as labels
            """
            
            result = session.run(query, uid=uid)
            record = result.single()
            
            if record:
                user_data = dict(record["u"])
                user_data["labels"] = record["labels"]
                return user_data
            return None
    
    def get_user_by_email(self, email: str) -> Optional[Dict[str, Any]]:
        """
        Get user by email (checks both Seeker and Provider)
        
        Args:
            email: User's email address
        
        Returns:
            dict: User data or None
        """
        with self.driver.session() as session:
            query = """
            MATCH (u)
            WHERE (u:Seeker OR u:Provider) AND u.email = $email
            RETURN u, labels(u) as labels
            """
            
            result = session.run(query, email=email)
            record = result.single()
            
            if record:
                user_data = dict(record["u"])
                user_data["labels"] = record["labels"]
                return user_data
            return None
    
    def update_seeker(self, uid: str, updates: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """
        Update Seeker node
        
        Args:
            uid: Firebase user UID
            updates: Dictionary of fields to update
        
        Returns:
            dict: Updated seeker data
        """
        if not updates:
            return None
        
        # Add updated_at timestamp
        updates["updated_at"] = datetime.utcnow().isoformat()
        
        # Build SET clause dynamically
        set_clauses = [f"s.{key} = ${key}" for key in updates.keys()]
        set_clause = ", ".join(set_clauses)
        
        with self.driver.session() as session:
            query = f"""
            MATCH (s:Seeker {{uid: $uid}})
            SET {set_clause}
            RETURN s
            """
            
            result = session.run(query, uid=uid, **updates)
            record = result.single()
            
            if record:
                return dict(record["s"])
            return None
    
    def update_provider(self, uid: str, updates: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """
        Update Provider node
        
        Args:
            uid: Firebase user UID
            updates: Dictionary of fields to update
        
        Returns:
            dict: Updated provider data
        """
        if not updates:
            return None
        
        # Add updated_at timestamp
        updates["updated_at"] = datetime.utcnow().isoformat()
        
        # Build SET clause dynamically
        set_clauses = [f"p.{key} = ${key}" for key in updates.keys()]
        set_clause = ", ".join(set_clauses)
        
        with self.driver.session() as session:
            query = f"""
            MATCH (p:Provider {{uid: $uid}})
            SET {set_clause}
            RETURN p
            """
            
            result = session.run(query, uid=uid, **updates)
            record = result.single()
            
            if record:
                return dict(record["p"])
            return None
    
    def delete_user(self, uid: str) -> bool:
        """
        Delete user node (both Seeker and Provider)
        
        Args:
            uid: Firebase user UID
        
        Returns:
            bool: True if deleted, False otherwise
        """
        with self.driver.session() as session:
            query = """
            MATCH (u)
            WHERE (u:Seeker OR u:Provider) AND u.uid = $uid
            DETACH DELETE u
            RETURN count(u) as deleted_count
            """
            
            result = session.run(query, uid=uid)
            record = result.single()
            
            return record["deleted_count"] > 0 if record else False
    
    def user_exists(self, uid: str = None, email: str = None) -> bool:
        """
        Check if user exists by UID or email
        
        Args:
            uid: Firebase user UID (optional)
            email: User's email (optional)
        
        Returns:
            bool: True if user exists
        """
        if not uid and not email:
            return False
        
        with self.driver.session() as session:
            if uid:
                query = """
                MATCH (u)
                WHERE (u:Seeker OR u:Provider) AND u.uid = $uid
                RETURN count(u) > 0 as exists
                """
                result = session.run(query, uid=uid)
            else:
                query = """
                MATCH (u)
                WHERE (u:Seeker OR u:Provider) AND u.email = $email
                RETURN count(u) > 0 as exists
                """
                result = session.run(query, email=email)
            
            record = result.single()
            return record["exists"] if record else False
    
    def get_all_seekers(self, limit: int = 100, skip: int = 0) -> List[Dict[str, Any]]:
        """
        Get all seekers with pagination
        
        Args:
            limit: Maximum number of records
            skip: Number of records to skip
        
        Returns:
            list: List of seeker data
        """
        with self.driver.session() as session:
            query = """
            MATCH (s:Seeker)
            RETURN s
            ORDER BY s.created_at DESC
            SKIP $skip
            LIMIT $limit
            """
            
            result = session.run(query, skip=skip, limit=limit)
            return [dict(record["s"]) for record in result]
    
    def get_all_providers(self, limit: int = 100, skip: int = 0) -> List[Dict[str, Any]]:
        """
        Get all providers with pagination
        
        Args:
            limit: Maximum number of records
            skip: Number of records to skip
        
        Returns:
            list: List of provider data
        """
        with self.driver.session() as session:
            query = """
            MATCH (p:Provider)
            RETURN p
            ORDER BY p.created_at DESC
            SKIP $skip
            LIMIT $limit
            """
            
            result = session.run(query, skip=skip, limit=limit)
            return [dict(record["p"]) for record in result]
    
    def search_providers(
        self, 
        business_type: Optional[str] = None,
        min_rating: float = 0.0,
        is_verified: Optional[bool] = None,
        limit: int = 50
    ) -> List[Dict[str, Any]]:
        """
        Search providers with filters
        
        Args:
            business_type: Filter by business type
            min_rating: Minimum rating
            is_verified: Filter by verification status
            limit: Maximum results
        
        Returns:
            list: List of matching providers
        """
        with self.driver.session() as session:
            conditions = ["p.rating >= $min_rating"]
            params = {"min_rating": min_rating, "limit": limit}
            
            if business_type:
                conditions.append("p.business_type = $business_type")
                params["business_type"] = business_type
            
            if is_verified is not None:
                conditions.append("p.is_verified = $is_verified")
                params["is_verified"] = is_verified
            
            where_clause = " AND ".join(conditions)
            
            query = f"""
            MATCH (p:Provider)
            WHERE {where_clause}
            RETURN p
            ORDER BY p.rating DESC, p.total_bookings DESC
            LIMIT $limit
            """
            
            result = session.run(query, **params)
            return [dict(record["p"]) for record in result]


    def update_provider_profile(self, uid: str, update_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """
        Update provider profile with optional business fields
        
        Args:
            uid: Provider Firebase UID
            update_data: Dictionary of fields to update
        
        Returns:
            dict: Updated provider data
        """
        with self.driver.session() as session:
            # Build SET clause dynamically
            set_clauses = []
            params = {"uid": uid}
            
            for key, value in update_data.items():
                set_clauses.append(f"p.{key} = ${key}")
                params[key] = value
            
            # Ensure 'name' property always matches 'full_name' for graph visualization
            # This property is used by Neo4j Browser to display node labels
            # We need to get the current full_name and set it as name
            
            # Always update timestamp
            set_clauses.append("p.updated_at = datetime()")
            
            set_clause = ", ".join(set_clauses)
            
            query = f"""
            MATCH (p:Provider {{uid: $uid}})
            SET {set_clause}, p.name = p.full_name
            RETURN p
            """
            
            result = session.run(query, params)
            record = result.single()
            
            if record:
                node_data = dict(record["p"])
                
                # Convert Neo4j datetime objects to ISO format strings
                if 'created_at' in node_data and hasattr(node_data['created_at'], 'iso_format'):
                    node_data['created_at'] = node_data['created_at'].iso_format()
                elif 'created_at' in node_data and hasattr(node_data['created_at'], 'isoformat'):
                    node_data['created_at'] = node_data['created_at'].isoformat()
                    
                if 'updated_at' in node_data and hasattr(node_data['updated_at'], 'iso_format'):
                    node_data['updated_at'] = node_data['updated_at'].iso_format()
                elif 'updated_at' in node_data and hasattr(node_data['updated_at'], 'isoformat'):
                    node_data['updated_at'] = node_data['updated_at'].isoformat()
                
                return node_data
            else:
                return None


    def update_seeker_profile(self, uid: str, update_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """
        Update seeker profile with optional fields
        
        Args:
            uid: Seeker Firebase UID
            update_data: Dictionary of fields to update
        
        Returns:
            dict: Updated seeker data
        """
        with self.driver.session() as session:
            print(f"\n{'='*60}")
            print(f" UPDATING SEEKER PROFILE IN NEO4J")
            print(f"   UID: {uid}")
            print(f"   Fields to update: {list(update_data.keys())}")
            print(f"{'='*60}\n")
            
            # Build SET clause dynamically
            set_clauses = []
            params = {"uid": uid}
            
            for key, value in update_data.items():
                set_clauses.append(f"s.{key} = ${key}")
                params[key] = value
            
            # Always update timestamp
            set_clauses.append("s.updated_at = datetime()")
            
            set_clause = ", ".join(set_clauses)
            
            query = f"""
            MATCH (s:Seeker {{uid: $uid}})
            SET {set_clause}, s.name = s.full_name
            RETURN s
            """
            
            print(f" Cypher Query:")
            print(f"   {query}")
            print(f" Parameters: {params}\n")
            
            result = session.run(query, params)
            record = result.single()
            
            if record:
                node_data = dict(record["s"])
                
                # Convert Neo4j datetime objects to ISO format strings
                if 'created_at' in node_data and hasattr(node_data['created_at'], 'iso_format'):
                    node_data['created_at'] = node_data['created_at'].iso_format()
                elif 'created_at' in node_data and hasattr(node_data['created_at'], 'isoformat'):
                    node_data['created_at'] = node_data['created_at'].isoformat()
                    
                if 'updated_at' in node_data and hasattr(node_data['updated_at'], 'iso_format'):
                    node_data['updated_at'] = node_data['updated_at'].iso_format()
                elif 'updated_at' in node_data and hasattr(node_data['updated_at'], 'isoformat'):
                    node_data['updated_at'] = node_data['updated_at'].isoformat()
                
                print(f"✅ Seeker profile updated successfully")
                print(f"   Total properties: {len(node_data)}")
                print(f"   Updated fields: {list(update_data.keys())}")
                print(f"   Stored preferences:")
                if 'service_categories' in update_data:
                    print(f"     - service_categories: {node_data.get('service_categories', 'None')[:100]}...")
                if 'category_details' in update_data:
                    print(f"     - category_details: {node_data.get('category_details', 'None')[:100]}...")
                if 'service_requirements' in update_data:
                    print(f"     - service_requirements: {node_data.get('service_requirements', 'None')[:100]}...")
                print()
                return node_data
            else:
                print(f"❌ Seeker not found with UID: {uid}\n")
                return None

    def create_seeker_similarity_relationships(self, uid: str) -> Dict[str, Any]:
        """
        Create relationships between seekers based on similar preferences
        
        Args:
            uid: Seeker UID to find similar seekers for
            
        Returns:
            dict: Summary of relationships created
        """
        import json
        
        with self.driver.session() as session:
            print(f"\n{'='*60}")
            print(f"🔗 CREATING SIMILARITY RELATIONSHIPS")
            print(f"   For Seeker UID: {uid}")
            print(f"{'='*60}\n")
            
            # Get the seeker's preferences
            get_seeker_query = """
            MATCH (s:Seeker {uid: $uid})
            RETURN s.service_categories as categories,
                   s.primary_purpose as purpose,
                   s.urgency as urgency,
                   s.address as address
            """
            
            result = session.run(get_seeker_query, uid=uid)
            record = result.single()
            
            if not record:
                print(f"❌ Seeker not found: {uid}\n")
                return {"relationships_created": 0, "similar_seekers": []}
            
            categories = record['categories']
            purpose = record['purpose']
            urgency = record['urgency']
            address = record['address']
            
            # Parse categories if it's a JSON string
            if categories:
                try:
                    categories_list = json.loads(categories) if isinstance(categories, str) else categories
                except:
                    categories_list = []
            else:
                categories_list = []
            
            print(f"📊 Seeker Preferences:")
            print(f"   Categories: {categories_list}")
            print(f"   Purpose: {purpose}")
            print(f"   Urgency: {urgency}")
            print(f"   Address: {address}\n")
            
            relationships_created = 0
            similar_seekers = []
            
            # Find seekers with similar service categories
            if categories_list:
                category_query = """
                MATCH (s1:Seeker {uid: $uid})
                MATCH (s2:Seeker)
                WHERE s2.uid <> $uid
                  AND s2.service_categories IS NOT NULL
                WITH s1, s2, s2.service_categories as s2_categories
                MERGE (s1)-[r:SIMILAR_INTERESTS {
                    similarity_type: 'service_category',
                    created_at: datetime()
                }]->(s2)
                RETURN s2.uid as similar_uid, s2.full_name as name, s2_categories
                """
                
                # First, let's find matches based on categories
                for category in categories_list:
                    find_query = """
                    MATCH (s1:Seeker {uid: $uid})
                    MATCH (s2:Seeker)
                    WHERE s2.uid <> $uid
                      AND s2.service_categories CONTAINS $category
                    MERGE (s1)-[r:SIMILAR_INTERESTS {
                        similarity_type: 'service_category',
                        matching_category: $category,
                        created_at: datetime()
                    }]->(s2)
                    SET r.strength = COALESCE(r.strength, 0) + 1
                    RETURN s2.uid as similar_uid, s2.full_name as name, r.strength as strength
                    """
                    
                    category_result = session.run(find_query, uid=uid, category=category)
                    for rec in category_result:
                        relationships_created += 1
                        similar_seekers.append({
                            'uid': rec['similar_uid'],
                            'name': rec['name'],
                            'similarity': 'service_category',
                            'strength': rec['strength']
                        })
                        print(f"   ✓ Created relationship with {rec['name']} (category: {category})")
            
            # Find seekers with same primary purpose
            if purpose:
                purpose_query = """
                MATCH (s1:Seeker {uid: $uid})
                MATCH (s2:Seeker)
                WHERE s2.uid <> $uid
                  AND s2.primary_purpose = $purpose
                MERGE (s1)-[r:SIMILAR_INTERESTS {
                    similarity_type: 'primary_purpose',
                    matching_purpose: $purpose,
                    created_at: datetime()
                }]->(s2)
                SET r.strength = COALESCE(r.strength, 0) + 2
                RETURN s2.uid as similar_uid, s2.full_name as name, r.strength as strength
                """
                
                purpose_result = session.run(purpose_query, uid=uid, purpose=purpose)
                for rec in purpose_result:
                    relationships_created += 1
                    similar_seekers.append({
                        'uid': rec['similar_uid'],
                        'name': rec['name'],
                        'similarity': 'primary_purpose',
                        'strength': rec['strength']
                    })
                    print(f"   ✓ Created relationship with {rec['name']} (purpose: {purpose})")
            
            # Find seekers with same urgency level
            if urgency:
                urgency_query = """
                MATCH (s1:Seeker {uid: $uid})
                MATCH (s2:Seeker)
                WHERE s2.uid <> $uid
                  AND s2.urgency = $urgency
                MERGE (s1)-[r:SIMILAR_INTERESTS {
                    similarity_type: 'urgency',
                    matching_urgency: $urgency,
                    created_at: datetime()
                }]->(s2)
                SET r.strength = COALESCE(r.strength, 0) + 1
                RETURN s2.uid as similar_uid, s2.full_name as name, r.strength as strength
                """
                
                urgency_result = session.run(urgency_query, uid=uid, urgency=urgency)
                for rec in urgency_result:
                    relationships_created += 1
                    similar_seekers.append({
                        'uid': rec['similar_uid'],
                        'name': rec['name'],
                        'similarity': 'urgency',
                        'strength': rec['strength']
                    })
                    print(f"   ✓ Created relationship with {rec['name']} (urgency: {urgency})")
            
            # Find seekers in same location/area
            if address:
                # Extract city or area from address
                location_query = """
                MATCH (s1:Seeker {uid: $uid})
                MATCH (s2:Seeker)
                WHERE s2.uid <> $uid
                  AND s2.address CONTAINS $address
                MERGE (s1)-[r:SIMILAR_LOCATION {
                    location: $address,
                    created_at: datetime()
                }]->(s2)
                SET r.strength = COALESCE(r.strength, 0) + 1
                RETURN s2.uid as similar_uid, s2.full_name as name, r.strength as strength
                """
                
                location_result = session.run(location_query, uid=uid, address=address)
                for rec in location_result:
                    relationships_created += 1
                    similar_seekers.append({
                        'uid': rec['similar_uid'],
                        'name': rec['name'],
                        'similarity': 'location',
                        'strength': rec['strength']
                    })
                    print(f"   ✓ Created location relationship with {rec['name']}")
            
            print(f"\n✅ Total relationships created: {relationships_created}")
            print(f"   Unique similar seekers: {len(set([s['uid'] for s in similar_seekers]))}\n")
            
            return {
                "relationships_created": relationships_created,
                "similar_seekers": similar_seekers,
                "seeker_uid": uid
            }

    def get_similar_seekers(self, uid: str, limit: int = 10) -> List[Dict[str, Any]]:
        """
        Get seekers similar to the given seeker based on relationships
        
        Args:
            uid: Seeker UID
            limit: Maximum number of similar seekers to return
            
        Returns:
            list: List of similar seekers with similarity scores
        """
        with self.driver.session() as session:
            query = """
            MATCH (s1:Seeker {uid: $uid})-[r:SIMILAR_INTERESTS|SIMILAR_LOCATION]->(s2:Seeker)
            RETURN s2.uid as uid,
                   s2.full_name as name,
                   s2.email as email,
                   s2.service_categories as categories,
                   s2.primary_purpose as purpose,
                   s2.address as address,
                   collect(DISTINCT type(r)) as relationship_types,
                   sum(COALESCE(r.strength, 1)) as total_strength
            ORDER BY total_strength DESC
            LIMIT $limit
            """
            
            result = session.run(query, uid=uid, limit=limit)
            similar_seekers = []
            
            for record in result:
                similar_seekers.append({
                    'uid': record['uid'],
                    'name': record['name'],
                    'email': record['email'],
                    'categories': record['categories'],
                    'purpose': record['purpose'],
                    'address': record['address'],
                    'relationship_types': record['relationship_types'],
                    'similarity_score': record['total_strength']
                })
            
            return similar_seekers
    
    # ==================== VEHICLE MANAGEMENT ====================
    
    def create_vehicle(self, vehicle: 'VehicleNode') -> Dict[str, Any]:
        """
        Create a new Vehicle node and link to Provider
        
        Args:
            vehicle: VehicleNode instance
        
        Returns:
            dict: Created vehicle data
        """
        from models.user import VehicleNode
        
        with self.driver.session() as session:
            vehicle_dict = vehicle.to_dict()
            
            print(f"\n{'='*60}")
            print(f"🚜 CREATING VEHICLE NODE IN NEO4J")
            print(f"   Vehicle ID: {vehicle_dict.get('vehicle_id')}")
            print(f"   Provider UID: {vehicle_dict.get('provider_uid')}")
            print(f"   Name: {vehicle_dict.get('name')}")
            print(f"   Type: {vehicle_dict.get('vehicle_type')}")
            print(f"   Make: {vehicle_dict.get('make')}")
            print(f"   Model: {vehicle_dict.get('model')}")
            print(f"{'='*60}\n")
            
            query = """
            MATCH (p:Provider {uid: $provider_uid})
            CREATE (v:Vehicle)
            SET v.vehicle_id = $vehicle_id,
                v.provider_uid = $provider_uid,
                v.name = $name,
                v.vehicle_type = $vehicle_type,
                v.make = $make,
                v.model = $model,
                v.year = $year,
                v.registration_number = $registration_number,
                v.capacity = $capacity,
                v.condition = $condition,
                v.vehicle_image = $vehicle_image,
                v.additional_images = $additional_images,
                v.has_insurance = $has_insurance,
                v.insurance_expiry = $insurance_expiry,
                v.is_available = $is_available,
                v.city = $city,
                v.province = $province,
                v.price_per_hour = $price_per_hour,
                v.price_per_day = $price_per_day,
                v.description = $description,
                v.created_at = datetime($created_at),
                v.updated_at = datetime($updated_at)
            CREATE (p)-[:OWNS]->(v)
            RETURN v
            """
            
            result = session.run(query, **vehicle_dict)
            record = result.single()
            
            if record:
                node_data = dict(record["v"])
                print(f"✅ Vehicle created successfully")
                print(f"   Vehicle ID: {node_data.get('vehicle_id')}\n")
                return node_data
            return None
    
    def get_provider_vehicles(self, provider_uid: str) -> List[Dict[str, Any]]:
        """
        Get all vehicles owned by a provider
        
        Args:
            provider_uid: Provider Firebase UID
        
        Returns:
            List of vehicle data dictionaries
        """
        with self.driver.session() as session:
            query = """
            MATCH (p:Provider {uid: $provider_uid})-[:OWNS]->(v:Vehicle)
            RETURN v
            ORDER BY v.created_at DESC
            """
            
            result = session.run(query, provider_uid=provider_uid)
            vehicles = []
            
            for record in result:
                vehicle_data = dict(record["v"])
                # Convert datetime objects to ISO format
                if vehicle_data.get('created_at'):
                    if hasattr(vehicle_data['created_at'], 'iso_format'):
                        vehicle_data['created_at'] = vehicle_data['created_at'].iso_format()
                    elif hasattr(vehicle_data['created_at'], 'isoformat'):
                        vehicle_data['created_at'] = vehicle_data['created_at'].isoformat()
                        
                if vehicle_data.get('updated_at'):
                    if hasattr(vehicle_data['updated_at'], 'iso_format'):
                        vehicle_data['updated_at'] = vehicle_data['updated_at'].iso_format()
                    elif hasattr(vehicle_data['updated_at'], 'isoformat'):
                        vehicle_data['updated_at'] = vehicle_data['updated_at'].isoformat()
                        
                vehicles.append(vehicle_data)
            
            print(f"📋 Retrieved {len(vehicles)} vehicles for provider {provider_uid}")
            return vehicles
    
    def get_vehicle_by_id(self, vehicle_id: str) -> Optional[Dict[str, Any]]:
        """
        Get vehicle by ID
        
        Args:
            vehicle_id: Vehicle ID
        
        Returns:
            Vehicle data or None
        """
        with self.driver.session() as session:
            query = """
            MATCH (v:Vehicle {vehicle_id: $vehicle_id})
            RETURN v
            """
            
            result = session.run(query, vehicle_id=vehicle_id)
            record = result.single()
            
            if record:
                vehicle_data = dict(record["v"])
                # Convert datetime
                if vehicle_data.get('created_at'):
                    if hasattr(vehicle_data['created_at'], 'iso_format'):
                        vehicle_data['created_at'] = vehicle_data['created_at'].iso_format()
                    elif hasattr(vehicle_data['created_at'], 'isoformat'):
                        vehicle_data['created_at'] = vehicle_data['created_at'].isoformat()
                        
                if vehicle_data.get('updated_at'):
                    if hasattr(vehicle_data['updated_at'], 'iso_format'):
                        vehicle_data['updated_at'] = vehicle_data['updated_at'].iso_format()
                    elif hasattr(vehicle_data['updated_at'], 'isoformat'):
                        vehicle_data['updated_at'] = vehicle_data['updated_at'].isoformat()
                        
                return vehicle_data
            return None
    
    def update_vehicle(self, vehicle_id: str, update_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """
        Update vehicle properties
        
        Args:
            vehicle_id: Vehicle ID
            update_data: Dictionary of fields to update
        
        Returns:
            Updated vehicle data or None
        """
        with self.driver.session() as session:
            print(f"\n{'='*60}")
            print(f"🔧 UPDATING VEHICLE IN NEO4J")
            print(f"   Vehicle ID: {vehicle_id}")
            print(f"   Fields to update: {list(update_data.keys())}")
            print(f"{'='*60}\n")
            
            # Build SET clause dynamically
            set_clauses = []
            params = {"vehicle_id": vehicle_id}
            
            for key, value in update_data.items():
                set_clauses.append(f"v.{key} = ${key}")
                params[key] = value
            
            # Always update timestamp
            set_clauses.append("v.updated_at = datetime()")
            
            set_clause = ", ".join(set_clauses)
            
            query = f"""
            MATCH (v:Vehicle {{vehicle_id: $vehicle_id}})
            SET {set_clause}
            RETURN v
            """
            
            result = session.run(query, params)
            record = result.single()
            
            if record:
                vehicle_data = dict(record["v"])
                # Convert datetime
                if vehicle_data.get('created_at'):
                    if hasattr(vehicle_data['created_at'], 'iso_format'):
                        vehicle_data['created_at'] = vehicle_data['created_at'].iso_format()
                    elif hasattr(vehicle_data['created_at'], 'isoformat'):
                        vehicle_data['created_at'] = vehicle_data['created_at'].isoformat()
                        
                if vehicle_data.get('updated_at'):
                    if hasattr(vehicle_data['updated_at'], 'iso_format'):
                        vehicle_data['updated_at'] = vehicle_data['updated_at'].iso_format()
                    elif hasattr(vehicle_data['updated_at'], 'isoformat'):
                        vehicle_data['updated_at'] = vehicle_data['updated_at'].isoformat()
                        
                print(f"✅ Vehicle updated successfully\n")
                return vehicle_data
            return None
    
    def delete_vehicle(self, vehicle_id: str) -> bool:
        """
        Delete vehicle and all related services (CASCADE)
        
        Args:
            vehicle_id: Vehicle ID
        
        Returns:
            True if deleted, False otherwise
        """
        with self.driver.session() as session:
            print(f"\n{'='*60}")
            print(f"🗑️  DELETING VEHICLE (CASCADE)")
            print(f"   Vehicle ID: {vehicle_id}")
            print(f"{'='*60}\n")
            
            # First, get count of services that will be deleted
            count_query = """
            MATCH (v:Vehicle {vehicle_id: $vehicle_id})-[:PROVIDES]->(s:Service)
            RETURN count(s) as service_count
            """
            
            count_result = session.run(count_query, vehicle_id=vehicle_id)
            count_record = count_result.single()
            service_count = count_record["service_count"] if count_record else 0
            
            # Delete vehicle and all related services
            delete_query = """
            MATCH (v:Vehicle {vehicle_id: $vehicle_id})
            OPTIONAL MATCH (v)-[:PROVIDES]->(s:Service)
            OPTIONAL MATCH (p:Provider)-[r:OFFERS]->(s)
            DELETE r, s, v
            RETURN count(v) as deleted_count
            """
            
            result = session.run(delete_query, vehicle_id=vehicle_id)
            record = result.single()
            
            if record and record["deleted_count"] > 0:
                print(f"✅ Vehicle deleted successfully")
                print(f"   Also deleted {service_count} related services\n")
                return True
            
            print(f"❌ Vehicle not found\n")
            return False
    
    # ==================== SERVICE MANAGEMENT ====================
    
    def create_service(self, service: 'ServiceNode') -> Dict[str, Any]:
        """
        Create a new Service node and link to Provider and Vehicle
        
        Args:
            service: ServiceNode instance
        
        Returns:
            dict: Created service data
        """
        from models.user import ServiceNode
        
        with self.driver.session() as session:
            service_dict = service.to_dict()
            
            print(f"\n{'='*60}")
            print(f"🛠️  CREATING SERVICE NODE IN NEO4J")
            print(f"   Service ID: {service_dict.get('service_id')}")
            print(f"   Vehicle ID: {service_dict.get('vehicle_id')}")
            print(f"   Provider UID: {service_dict.get('provider_uid')}")
            print(f"   Service Name: {service_dict.get('service_name')}")
            print(f"   Category: {service_dict.get('service_category')}")
            print(f"{'='*60}\n")
            
            query = """
            MATCH (p:Provider {uid: $provider_uid})
            MATCH (v:Vehicle {vehicle_id: $vehicle_id})
            CREATE (s:Service)
            SET s.service_id = $service_id,
                s.vehicle_id = $vehicle_id,
                s.provider_uid = $provider_uid,
                s.service_name = $service_name,
                s.service_category = $service_category,
                s.price_per_hour = $price_per_hour,
                s.price_per_day = $price_per_day,
                s.price_per_service = $price_per_service,
                s.description = $description,
                s.service_area = $service_area,
                s.min_booking_duration = $min_booking_duration,
                s.is_active = $is_active,
                s.available_days = $available_days,
                s.available_hours = $available_hours,
                s.operator_included = $operator_included,
                s.fuel_included = $fuel_included,
                s.transportation_included = $transportation_included,
                s.total_bookings = $total_bookings,
                s.rating = $rating,
                s.created_at = datetime($created_at),
                s.updated_at = datetime($updated_at)
            CREATE (p)-[:OFFERS]->(s)
            CREATE (v)-[:PROVIDES]->(s)
            RETURN s
            """
            
            result = session.run(query, **service_dict)
            record = result.single()
            
            if record:
                node_data = dict(record["s"])
                print(f"✅ Service created successfully")
                print(f"   Service ID: {node_data.get('service_id')}\n")
                return node_data
            return None
    
    def get_vehicle_services(self, vehicle_id: str) -> List[Dict[str, Any]]:
        """
        Get all services for a specific vehicle
        
        Args:
            vehicle_id: Vehicle ID
        
        Returns:
            List of service data dictionaries
        """
        with self.driver.session() as session:
            query = """
            MATCH (v:Vehicle {vehicle_id: $vehicle_id})-[:PROVIDES]->(s:Service)
            RETURN s
            ORDER BY s.created_at DESC
            """
            
            result = session.run(query, vehicle_id=vehicle_id)
            services = []
            
            for record in result:
                service_data = dict(record["s"])
                # Convert datetime
                if service_data.get('created_at'):
                    if hasattr(service_data['created_at'], 'iso_format'):
                        service_data['created_at'] = service_data['created_at'].iso_format()
                    elif hasattr(service_data['created_at'], 'isoformat'):
                        service_data['created_at'] = service_data['created_at'].isoformat()
                        
                if service_data.get('updated_at'):
                    if hasattr(service_data['updated_at'], 'iso_format'):
                        service_data['updated_at'] = service_data['updated_at'].iso_format()
                    elif hasattr(service_data['updated_at'], 'isoformat'):
                        service_data['updated_at'] = service_data['updated_at'].isoformat()
                        
                services.append(service_data)
            
            print(f"📋 Retrieved {len(services)} services for vehicle {vehicle_id}")
            return services
    
    def get_provider_services(self, provider_uid: str) -> List[Dict[str, Any]]:
        """
        Get all services offered by a provider
        
        Args:
            provider_uid: Provider Firebase UID
        
        Returns:
            List of service data dictionaries
        """
        with self.driver.session() as session:
            query = """
            MATCH (p:Provider {uid: $provider_uid})-[:OFFERS]->(s:Service)
            RETURN s
            ORDER BY s.created_at DESC
            """
            
            result = session.run(query, provider_uid=provider_uid)
            services = []
            
            for record in result:
                service_data = dict(record["s"])
                # Convert datetime
                if service_data.get('created_at'):
                    if hasattr(service_data['created_at'], 'iso_format'):
                        service_data['created_at'] = service_data['created_at'].iso_format()
                    elif hasattr(service_data['created_at'], 'isoformat'):
                        service_data['created_at'] = service_data['created_at'].isoformat()
                        
                if service_data.get('updated_at'):
                    if hasattr(service_data['updated_at'], 'iso_format'):
                        service_data['updated_at'] = service_data['updated_at'].iso_format()
                    elif hasattr(service_data['updated_at'], 'isoformat'):
                        service_data['updated_at'] = service_data['updated_at'].isoformat()
                        
                services.append(service_data)
            
            print(f"📋 Retrieved {len(services)} services for provider {provider_uid}")
            return services
    
    def get_service_by_id(self, service_id: str) -> Optional[Dict[str, Any]]:
        """
        Get service by ID
        
        Args:
            service_id: Service ID
        
        Returns:
            Service data or None
        """
        with self.driver.session() as session:
            query = """
            MATCH (s:Service {service_id: $service_id})
            RETURN s
            """
            
            result = session.run(query, service_id=service_id)
            record = result.single()
            
            if record:
                service_data = dict(record["s"])
                # Convert datetime
                if service_data.get('created_at'):
                    if hasattr(service_data['created_at'], 'iso_format'):
                        service_data['created_at'] = service_data['created_at'].iso_format()
                    elif hasattr(service_data['created_at'], 'isoformat'):
                        service_data['created_at'] = service_data['created_at'].isoformat()
                        
                if service_data.get('updated_at'):
                    if hasattr(service_data['updated_at'], 'iso_format'):
                        service_data['updated_at'] = service_data['updated_at'].iso_format()
                    elif hasattr(service_data['updated_at'], 'isoformat'):
                        service_data['updated_at'] = service_data['updated_at'].isoformat()
                        
                return service_data
            return None
    
    def update_service(self, service_id: str, update_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """
        Update service properties
        
        Args:
            service_id: Service ID
            update_data: Dictionary of fields to update
        
        Returns:
            Updated service data or None
        """
        with self.driver.session() as session:
            print(f"\n{'='*60}")
            print(f"🔧 UPDATING SERVICE IN NEO4J")
            print(f"   Service ID: {service_id}")
            print(f"   Fields to update: {list(update_data.keys())}")
            print(f"{'='*60}\n")
            
            # Build SET clause dynamically
            set_clauses = []
            params = {"service_id": service_id}
            
            for key, value in update_data.items():
                set_clauses.append(f"s.{key} = ${key}")
                params[key] = value
            
            # Always update timestamp
            set_clauses.append("s.updated_at = datetime()")
            
            set_clause = ", ".join(set_clauses)
            
            query = f"""
            MATCH (s:Service {{service_id: $service_id}})
            SET {set_clause}
            RETURN s
            """
            
            result = session.run(query, params)
            record = result.single()
            
            if record:
                service_data = dict(record["s"])
                # Convert datetime
                if service_data.get('created_at'):
                    if hasattr(service_data['created_at'], 'iso_format'):
                        service_data['created_at'] = service_data['created_at'].iso_format()
                    elif hasattr(service_data['created_at'], 'isoformat'):
                        service_data['created_at'] = service_data['created_at'].isoformat()
                        
                if service_data.get('updated_at'):
                    if hasattr(service_data['updated_at'], 'iso_format'):
                        service_data['updated_at'] = service_data['updated_at'].iso_format()
                    elif hasattr(service_data['updated_at'], 'isoformat'):
                        service_data['updated_at'] = service_data['updated_at'].isoformat()
                        
                print(f"✅ Service updated successfully\n")
                return service_data
            return None
    
    def delete_service(self, service_id: str) -> bool:
        """
        Delete a service
        
        Args:
            service_id: Service ID
        
        Returns:
            True if deleted, False otherwise
        """
        with self.driver.session() as session:
            print(f"\n{'='*60}")
            print(f"🗑️  DELETING SERVICE")
            print(f"   Service ID: {service_id}")
            print(f"{'='*60}\n")
            
            query = """
            MATCH (s:Service {service_id: $service_id})
            OPTIONAL MATCH (p:Provider)-[r1:OFFERS]->(s)
            OPTIONAL MATCH (v:Vehicle)-[r2:PROVIDES]->(s)
            DELETE r1, r2, s
            RETURN count(s) as deleted_count
            """
            
            result = session.run(query, service_id=service_id)
            record = result.single()
            
            if record and record["deleted_count"] > 0:
                print(f"✅ Service deleted successfully\n")
                return True
            
            print(f"❌ Service not found\n")
            return False
