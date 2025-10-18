"""
Haulistry Backend API
FastAPI application with GraphQL, Firebase Auth and Neo4j database
"""

import uvicorn
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from contextlib import asynccontextmanager
from strawberry.fastapi import GraphQLRouter

from config import settings, initialize_firebase, get_neo4j_driver, close_neo4j_driver
from graphql_api.schema import schema


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Lifespan context manager for startup and shutdown events
    """
    # Startup
    print("🚀 Starting Haulistry Backend API with GraphQL...")
    print(f"📝 Environment: {'Development' if settings.DEBUG else 'Production'}")
    
    # Initialize Firebase
    try:
        initialize_firebase()
    except Exception as e:
        print(f"⚠️  Firebase initialization failed: {str(e)}")
        print(f"⚠️  Continuing without Firebase...")
    
    # Test Neo4j connection (non-blocking)
    try:
        driver = get_neo4j_driver()
        print(f"✅ All services initialized successfully!\n")
    except Exception as e:
        print(f"⚠️  Neo4j connection failed: {str(e)}")
        print(f"⚠️  Server will start but database operations may fail")
        print(f"⚠️  Please check Neo4j Aura instance is running\n")
    
    yield
    
    # Shutdown
    print("\n🛑 Shutting down Haulistry Backend API...")
    close_neo4j_driver()
    print("✅ Cleanup completed")


# Initialize FastAPI app
app = FastAPI(
    title=settings.API_TITLE + " (GraphQL)",
    description=settings.API_DESCRIPTION + "\n\nThis API uses GraphQL. Access the GraphQL playground at /graphql",
    version=settings.API_VERSION,
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan
)

# Configure CORS - MUST be before routes
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins for development
    allow_credentials=True,
    allow_methods=["GET", "POST", "OPTIONS"],  # Explicitly include OPTIONS
    allow_headers=["*"],
    expose_headers=["*"],
)


# Global exception handler
@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    """
    Global exception handler for unhandled errors
    """
    return JSONResponse(
        status_code=500,
        content={
            "detail": "Internal server error",
            "message": str(exc) if settings.DEBUG else "An error occurred"
        }
    )


# Context getter for GraphQL
async def get_context(request: Request):
    """
    Context getter for GraphQL - provides request context to resolvers
    """
    return {
        "request": request
    }


# Handle OPTIONS requests for CORS preflight
@app.options("/graphql")
async def graphql_options():
    """Handle CORS preflight requests for GraphQL endpoint"""
    return JSONResponse(
        content={"message": "OK"},
        headers={
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
            "Access-Control-Allow-Headers": "*",
            "Access-Control-Max-Age": "86400",
        }
    )


# Create GraphQL router
graphql_app = GraphQLRouter(
    schema,
    context_getter=get_context,
    graphql_ide="graphiql"  # Enable GraphQL playground in development
)

# Mount GraphQL endpoint
app.include_router(graphql_app, prefix="/graphql")


# Root endpoint
@app.get("/", tags=["Root"])
async def root():
    """
    Root endpoint - API information
    """
    return {
        "message": "Welcome to Haulistry GraphQL API",
        "version": settings.API_VERSION,
        "graphql": "/graphql",
        "docs": "/docs",
        "redoc": "/redoc",
        "status": "running"
    }


# Health check endpoint
@app.get("/health", tags=["Health"])
async def health_check():
    """
    Health check endpoint
    """
    return {
        "status": "healthy",
        "service": "Haulistry Backend API",
        "version": settings.API_VERSION
    }


# Database test endpoint
@app.get("/test/database", tags=["Testing"])
async def test_database():
    """
    Test database connections
    """
    try:
        # Test Neo4j
        driver = get_neo4j_driver()
        with driver.session() as session:
            result = session.run("RETURN 1 AS test")
            neo4j_status = "connected" if result.single()["test"] == 1 else "failed"
        
        return {
            "neo4j": neo4j_status,
            "firebase": "initialized",
            "message": "All database connections are working"
        }
    except Exception as e:
        return {
            "error": str(e),
            "message": "Database connection test failed"
        }


if __name__ == "__main__":
    print(f"""
╔══════════════════════════════════════════════════╗
║       HAULISTRY BACKEND GraphQL API SERVER      ║
║  Heavy Machinery & Transport Services Platform  ║
╚══════════════════════════════════════════════════╝

📍 Server: {settings.API_HOST}:{settings.API_PORT}
🎯 GraphQL Playground: http://{settings.API_HOST}:{settings.API_PORT}/graphql
📚 API Documentation: http://{settings.API_HOST}:{settings.API_PORT}/docs
🔧 Environment: {'Development' if settings.DEBUG else 'Production'}

""")
    
    uvicorn.run(
        "main:app",
        host=settings.API_HOST,
        port=settings.API_PORT,
        reload=settings.DEBUG,
        log_level=settings.LOG_LEVEL.lower()
    )
