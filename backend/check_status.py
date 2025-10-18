"""
Backend Status Checker
Quick script to check if backend is running and accessible
"""

import requests
import sys

def check_backend_status():
    """Check if backend is running and responding"""
    
    base_url = "http://localhost:8000"
    
    print("=" * 60)
    print("HAULISTRY BACKEND STATUS CHECK")
    print("=" * 60)
    print()
    
    # Check if server is running
    print("🔍 Checking if server is running...")
    try:
        response = requests.get(f"{base_url}/health", timeout=5)
        
        if response.status_code == 200:
            print("✅ Server is running!")
            data = response.json()
            print(f"   Status: {data.get('status')}")
            print(f"   Version: {data.get('version')}")
        else:
            print(f"⚠️  Server responded with status code: {response.status_code}")
            
    except requests.exceptions.ConnectionError:
        print("❌ Cannot connect to server")
        print("   Make sure the server is running: python main.py")
        return False
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return False
    
    # Check database connections
    print("\n🔍 Checking database connections...")
    try:
        response = requests.get(f"{base_url}/test/database", timeout=10)
        
        if response.status_code == 200:
            data = response.json()
            print(f"   Neo4j: {data.get('neo4j')}")
            print(f"   Firebase: {data.get('firebase')}")
            print("✅ All database connections working!")
        else:
            print("⚠️  Database test failed")
            
    except Exception as e:
        print(f"❌ Error checking databases: {str(e)}")
    
    # Check API documentation
    print("\n📚 API Documentation:")
    print(f"   Swagger UI: {base_url}/docs")
    print(f"   ReDoc: {base_url}/redoc")
    
    # Test registration endpoint
    print("\n🔍 Checking authentication endpoints...")
    try:
        # Just check if endpoint exists (will return validation error, which is fine)
        response = requests.post(
            f"{base_url}/api/auth/register/seeker",
            json={},
            timeout=5
        )
        
        if response.status_code in [400, 422]:  # Validation error is expected
            print("✅ Authentication endpoints are accessible")
        else:
            print(f"⚠️  Unexpected response: {response.status_code}")
            
    except Exception as e:
        print(f"❌ Error checking endpoints: {str(e)}")
    
    print("\n" + "=" * 60)
    print("✅ Backend Status Check Complete!")
    print("=" * 60)
    print()
    
    return True


def main():
    """Main function"""
    success = check_backend_status()
    return 0 if success else 1


if __name__ == "__main__":
    sys.exit(main())
