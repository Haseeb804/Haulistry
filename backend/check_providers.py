"""
Check Provider nodes in the database
"""

from config.neo4j_config import get_neo4j_driver

def check_providers():
    """Check all Provider nodes and their properties"""
    
    driver = get_neo4j_driver()
    
    with driver.session() as session:
        print("\n" + "="*60)
        print("🔍 CHECKING PROVIDER NODES")
        print("="*60 + "\n")
        
        # Count all Provider nodes
        count_query = """
        MATCH (p:Provider)
        RETURN count(p) as total
        """
        
        result = session.run(count_query)
        record = result.single()
        total = record['total'] if record else 0
        print(f"Total Provider nodes: {total}\n")
        
        # Get all Provider nodes with details
        details_query = """
        MATCH (p:Provider)
        RETURN p.uid as uid, p.email as email, p.full_name as full_name, 
               p.business_name as business_name, p.name as name
        """
        
        result = session.run(details_query)
        print("Provider node details:")
        for i, record in enumerate(result, 1):
            print(f"\n{i}. Provider:")
            print(f"   UID: {record['uid']}")
            print(f"   Email: {record['email']}")
            print(f"   full_name: {record['full_name']}")
            print(f"   business_name: {record['business_name']}")
            print(f"   name: {record['name']}")
        
        print("\n" + "="*60 + "\n")

if __name__ == "__main__":
    check_providers()
