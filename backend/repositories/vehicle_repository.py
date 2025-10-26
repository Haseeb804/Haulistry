"""
Vehicle Repository - Neo4j Database Operations for Vehicles
"""

from typing import Optional, Dict, Any, List
from datetime import datetime
import uuid
from config.neo4j_config import get_neo4j_driver


class VehicleRepository:
    """Repository for vehicle-related database operations"""
    
    def __init__(self):
        self.driver = get_neo4j_driver()
    
    def create_vehicle(
        self,
        provider_uid: str,
        vehicle_type: str,
        registration_number: str,
        model: str,
        vehicle_image: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Create a new Vehicle node in Neo4j and link it to provider
        
        Args:
            provider_uid: Provider's UID
            vehicle_type: Type of vehicle (Harvester, Tractor, Crane, Loader riksha)
            registration_number: Vehicle registration number
            model: Vehicle model
            vehicle_image: Base64 encoded vehicle image
        
        Returns:
            dict: Created vehicle data
        """
        with self.driver.session() as session:
            vehicle_id = str(uuid.uuid4())
            now = datetime.utcnow().isoformat()
            
            print(f"\n{'='*60}")
            print(f"🚗 CREATING VEHICLE NODE IN NEO4J")
            print(f"   Vehicle ID: {vehicle_id}")
            print(f"   Provider UID: {provider_uid}")
            print(f"   Type: {vehicle_type}")
            print(f"   Number: {registration_number}")
            print(f"   Model: {model}")
            print(f"   Has Image: {vehicle_image is not None}")
            print(f"{'='*60}\n")
            
            query = """
            MATCH (p:Provider {uid: $provider_uid})
            CREATE (v:Vehicle {
                vehicle_id: $vehicle_id,
                provider_uid: $provider_uid,
                vehicle_type: $vehicle_type,
                registration_number: $registration_number,
                model: $model,
                vehicle_image: $vehicle_image,
                name: $vehicle_type,
                make: '',
                year: 0,
                is_available: true,
                condition: 'Good',
                has_insurance: false,
                created_at: datetime($created_at),
                updated_at: datetime($updated_at)
            })
            CREATE (p)-[:OWNS]->(v)
            RETURN v
            """
            
            result = session.run(
                query,
                provider_uid=provider_uid,
                vehicle_id=vehicle_id,
                vehicle_type=vehicle_type,
                registration_number=registration_number,
                model=model,
                vehicle_image=vehicle_image,
                created_at=now,
                updated_at=now
            )
            
            record = result.single()
            
            if record:
                node_data = dict(record["v"])
                print(f"✅ Vehicle node created successfully: {vehicle_type} - {registration_number}\n")
                return node_data
            else:
                raise Exception(f"Provider with UID {provider_uid} not found")
    
    def get_provider_vehicles(self, provider_uid: str) -> List[Dict[str, Any]]:
        """
        Get all vehicles for a specific provider
        
        Args:
            provider_uid: Provider's UID
        
        Returns:
            list: List of vehicle dictionaries
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
                vehicles.append(vehicle_data)
            
            return vehicles
    
    def get_vehicle_by_id(self, vehicle_id: str) -> Optional[Dict[str, Any]]:
        """
        Get a specific vehicle by ID
        
        Args:
            vehicle_id: Vehicle's unique ID
        
        Returns:
            dict: Vehicle data or None if not found
        """
        with self.driver.session() as session:
            query = """
            MATCH (v:Vehicle {vehicle_id: $vehicle_id})
            RETURN v
            """
            
            result = session.run(query, vehicle_id=vehicle_id)
            record = result.single()
            
            if record:
                return dict(record["v"])
            return None
    
    def update_vehicle(self, vehicle_id: str, update_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """
        Update vehicle information
        
        Args:
            vehicle_id: Vehicle's unique ID
            update_data: Dictionary of fields to update
        
        Returns:
            dict: Updated vehicle data or None if not found
        """
        with self.driver.session() as session:
            # Build SET clause dynamically
            set_clauses = [f"v.{key} = ${key}" for key in update_data.keys()]
            set_clauses.append("v.updated_at = datetime($updated_at)")
            set_clause = ", ".join(set_clauses)
            
            update_data['updated_at'] = datetime.utcnow().isoformat()
            
            query = f"""
            MATCH (v:Vehicle {{vehicle_id: $vehicle_id}})
            SET {set_clause}
            RETURN v
            """
            
            result = session.run(query, vehicle_id=vehicle_id, **update_data)
            record = result.single()
            
            if record:
                return dict(record["v"])
            return None
    
    def delete_vehicle(self, vehicle_id: str) -> bool:
        """
        Delete a vehicle
        
        Args:
            vehicle_id: Vehicle's unique ID
        
        Returns:
            bool: True if deleted, False if not found
        """
        with self.driver.session() as session:
            query = """
            MATCH (v:Vehicle {vehicle_id: $vehicle_id})
            DETACH DELETE v
            RETURN count(v) as deleted_count
            """
            
            result = session.run(query, vehicle_id=vehicle_id)
            record = result.single()
            
            return record["deleted_count"] > 0 if record else False
    
    def check_vehicle_availability(self, vehicle_id: str) -> bool:
        """
        Check if a vehicle is available
        
        Args:
            vehicle_id: Vehicle's unique ID
        
        Returns:
            bool: True if available, False otherwise
        """
        with self.driver.session() as session:
            query = """
            MATCH (v:Vehicle {vehicle_id: $vehicle_id})
            RETURN v.is_available as is_available
            """
            
            result = session.run(query, vehicle_id=vehicle_id)
            record = result.single()
            
            return record["is_available"] if record else False
    
    def update_vehicle_availability(self, vehicle_id: str, is_available: bool) -> bool:
        """
        Update vehicle availability status
        
        Args:
            vehicle_id: Vehicle's unique ID
            is_available: New availability status
        
        Returns:
            bool: True if updated successfully
        """
        with self.driver.session() as session:
            query = """
            MATCH (v:Vehicle {vehicle_id: $vehicle_id})
            SET v.is_available = $is_available,
                v.updated_at = datetime($updated_at)
            RETURN v
            """
            
            result = session.run(
                query,
                vehicle_id=vehicle_id,
                is_available=is_available,
                updated_at=datetime.utcnow().isoformat()
            )
            record = result.single()
            
            return record is not None
    
    def remove_duplicate_vehicles(self, provider_uid: str) -> int:
        """
        Remove duplicate vehicles (same registration number) for a provider
        Keeps the oldest vehicle and removes duplicates
        
        Args:
            provider_uid: Provider's UID
        
        Returns:
            int: Number of duplicates removed
        """
        with self.driver.session() as session:
            query = """
            MATCH (p:Provider {uid: $provider_uid})-[:OWNS]->(v:Vehicle)
            WITH v.registration_number as reg_num, COLLECT(v) as vehicles
            WHERE SIZE(vehicles) > 1
            WITH vehicles
            UNWIND vehicles[1..] as duplicate
            DETACH DELETE duplicate
            RETURN COUNT(duplicate) as deleted_count
            """
            
            result = session.run(query, provider_uid=provider_uid)
            record = result.single()
            
            deleted_count = record["deleted_count"] if record else 0
            if deleted_count > 0:
                print(f"🧹 Removed {deleted_count} duplicate vehicles for provider {provider_uid}")
            
            return deleted_count
