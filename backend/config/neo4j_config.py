"""
Neo4j Database Configuration
"""

from neo4j import GraphDatabase, Driver
from neo4j.exceptions import ServiceUnavailable, AuthError
from typing import Optional
import socket
import ssl
import certifi
from .settings import settings


_neo4j_driver: Optional[Driver] = None


def test_network_connectivity(uri: str) -> bool:
    """
    Test basic network connectivity to Neo4j host
    
    Args:
        uri: Neo4j connection URI
        
    Returns:
        bool: True if host is reachable
    """
    try:
        # Parse host from URI - handle all Neo4j URI schemes
        host = uri.replace("neo4j+ssc://", "").replace("neo4j+s://", "").replace("neo4j://", "") \
                  .replace("bolt+ssc://", "").replace("bolt+s://", "").replace("bolt://", "") \
                  .split(":")[0].split("/")[0]
        
        # Try DNS resolution
        ip = socket.gethostbyname(host)
        print(f"   🌐 DNS resolved: {host} -> {ip}")
        
        # Try TCP connection on port 7687
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(10)
        result = sock.connect_ex((host, 7687))
        sock.close()
        
        if result == 0:
            print(f"   ✅ Network reachable: {host}:7687")
            return True
        else:
            print(f"   ❌ Port 7687 not reachable (error: {result})")
            return False
            
    except socket.gaierror:
        print(f"   ❌ DNS resolution failed for {host}")
        return False
    except Exception as e:
        print(f"   ⚠️  Network test error: {e}")
        return False


def get_neo4j_driver() -> Driver:
    """
    Get Neo4j driver instance (singleton pattern)
    Tries multiple connection strategies for Neo4j Aura
    
    Returns:
        Driver: Neo4j driver instance
    """
    global _neo4j_driver
    
    if _neo4j_driver is None:
        # Try different URI schemes if the primary one fails
        uri_schemes = [
            settings.NEO4J_URI,  # Try the configured URI first
        ]
        
        # Add alternative schemes if not already in the list
        if "neo4j+ssc://" in settings.NEO4J_URI:
            # Already using +ssc, just try bolt as fallback
            bolt_uri = settings.NEO4J_URI.replace("neo4j+ssc://", "bolt+ssc://")
            uri_schemes.append(bolt_uri)
        elif "neo4j+s://" in settings.NEO4J_URI:
            # Try +ssc version first (works with certificate issues), then bolt
            ssc_uri = settings.NEO4J_URI.replace("neo4j+s://", "neo4j+ssc://")
            bolt_uri = settings.NEO4J_URI.replace("neo4j+s://", "bolt+ssc://")
            uri_schemes.extend([ssc_uri, bolt_uri])
        elif "bolt+s://" in settings.NEO4J_URI:
            neo4j_uri = settings.NEO4J_URI.replace("bolt+s://", "neo4j+ssc://")
            bolt_ssc = settings.NEO4J_URI.replace("bolt+s://", "bolt+ssc://")
            uri_schemes.extend([bolt_ssc, neo4j_uri])
        
        last_error = None
        
        for uri in uri_schemes:
            try:
                print(f"   🔌 Attempting connection to: {uri}")
                
                # Test network connectivity first
                if not test_network_connectivity(uri):
                    print(f"   ⚠️  Network test failed, trying next scheme...")
                    continue
                
                # Create driver for Neo4j Aura
                _neo4j_driver = GraphDatabase.driver(
                    uri,
                    auth=(settings.NEO4J_USERNAME, settings.NEO4J_PASSWORD),
                    max_connection_lifetime=3600,
                    max_connection_pool_size=50,
                    connection_timeout=30,
                    user_agent="HaulistryApp/1.0"
                )
                
                # Verify connection with a simple query
                print("   🔍 Verifying connectivity...")
                _neo4j_driver.verify_connectivity()
                
                # Test with actual query to ensure it's really working
                with _neo4j_driver.session() as session:
                    result = session.run("RETURN 1 as test")
                    result.single()
                
                print(f"✅ Neo4j connected successfully to {uri}")
                
                # If we successfully connected with an alternative URI, update the message
                if uri != settings.NEO4J_URI:
                    print(f"   💡 Note: Connected using {uri.split('://')[0]}:// instead of configured scheme")
                
                return _neo4j_driver
                
            except ServiceUnavailable as e:
                error_msg = str(e).lower()
                print(f"   ❌ Connection failed with {uri.split('://')[0]}://: {str(e)}")
                last_error = e
                
                if "routing" in error_msg:
                    print(f"   💡 Routing error - trying alternative scheme...")
                
                # Try next scheme
                continue
                
            except AuthError as e:
                print(f"❌ Neo4j authentication failed: {str(e)}")
                print(f"💡 Check your credentials in .env file")
                print(f"   Username: {settings.NEO4J_USERNAME}")
                print(f"   Password: {'*' * len(settings.NEO4J_PASSWORD)}")
                raise  # Don't try other schemes for auth errors
                
            except Exception as e:
                print(f"   ❌ Error with {uri.split('://')[0]}://: {str(e)}")
                last_error = e
                continue
        
        # If we get here, all schemes failed
        print(f"\n❌ Failed to connect with any URI scheme")
        print(f"💡 Troubleshooting steps:")
        print(f"   1. Check Neo4j Aura Console: https://console.neo4j.io/")
        print(f"   2. Verify instance {settings.NEO4J_URI.split('://')[1].split('.')[0]} is RUNNING")
        print(f"   3. Check if instance is PAUSED (resume it)")
        print(f"   4. Verify credentials are correct")
        print(f"   5. Check firewall settings")
        
        if last_error:
            raise last_error
        else:
            raise ServiceUnavailable("Unable to connect to Neo4j Aura")
    
    return _neo4j_driver


def close_neo4j_driver():
    """
    Close Neo4j driver connection
    """
    global _neo4j_driver
    
    if _neo4j_driver is not None:
        _neo4j_driver.close()
        _neo4j_driver = None
        print("✅ Neo4j connection closed")


def test_neo4j_connection():
    """
    Test Neo4j connection and return database info
    
    Returns:
        dict: Database information
    """
    driver = get_neo4j_driver()
    
    with driver.session() as session:
        result = session.run("RETURN 1 AS test")
        record = result.single()
        
        if record["test"] == 1:
            return {
                "status": "connected",
                "uri": settings.NEO4J_URI,
                "database": settings.NEO4J_DATABASE
            }
        else:
            return {
                "status": "failed",
                "message": "Connection test failed"
            }


# Context manager for sessions
class Neo4jSession:
    """
    Context manager for Neo4j sessions
    
    Usage:
        with Neo4jSession() as session:
            result = session.run("MATCH (n) RETURN n LIMIT 1")
    """
    
    def __init__(self):
        self.driver = get_neo4j_driver()
        self.session = None
    
    def __enter__(self):
        self.session = self.driver.session()
        return self.session
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        if self.session:
            self.session.close()
