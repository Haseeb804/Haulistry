# Haulistry Backend API

Python FastAPI + GraphQL backend for Haulistry - Heavy Machinery & Transport Services Booking Platform

## 🚀 Features

- **GraphQL API**: Flexible, efficient data querying with GraphQL
- **Firebase Authentication**: Secure user authentication with Firebase Admin SDK
- **Neo4j Database**: Graph database for storing user and booking data
- **FastAPI Framework**: Modern, fast Python web framework
- **Strawberry GraphQL**: Python GraphQL library with type hints
- **Interactive Playground**: GraphiQL interface for testing queries
- **Dual User Types**: Support for Seekers and Providers

## 📋 Prerequisites

- Python 3.9 or higher
- Firebase Admin SDK credentials (service account key)
- Neo4j Aura database instance

## 🛠️ Installation

1. **Clone the repository**
   ```bash
   cd backend
   ```

2. **Create virtual environment**
   ```bash
   python -m venv venv
   
   # Windows (PowerShell)
   .\venv\Scripts\Activate.ps1
   
   # Windows (CMD)
   .\venv\Scripts\activate.bat
   
   # Linux/Mac
   source venv/bin/activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Configure environment variables**
   
   Create a `.env` file in the backend directory:
   ```env
   # Neo4j Configuration
   NEO4J_URI=neo4j+s://f957f86f.databases.neo4j.io
   NEO4J_USERNAME=neo4j
   NEO4J_PASSWORD=127lL3kjSH91rJxbe7_p67NMvyRjEPOXYRrJxWSmkXM
   NEO4J_DATABASE=neo4j
   
   # Firebase Configuration
   FIREBASE_CREDENTIALS_PATH=./firebase-credentials.json
   
   # API Configuration
   API_HOST=0.0.0.0
   API_PORT=8000
   DEBUG=True
   ```

5. **Add Firebase credentials**
   
   Download your Firebase service account key from Firebase Console:
   - Go to Project Settings → Service Accounts
   - Click "Generate New Private Key"
   - Save the JSON file as `firebase-credentials.json` in the backend directory

## 🏃‍♂️ Running the Server

```bash
# Development mode with auto-reload
python main.py

# Or using uvicorn directly
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

The API will be available at `http://localhost:8000`

## 📚 API Documentation

Once the server is running, visit:
- **GraphQL Playground**: http://localhost:8000/graphql (🎯 Primary interface)
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

## 🎯 GraphQL API

The backend now uses **GraphQL** instead of REST API. See [GRAPHQL_API.md](GRAPHQL_API.md) for complete documentation.

### Quick Start Examples

#### Register Seeker (Customer)
```graphql
mutation {
  registerSeeker(input: {
    email: "customer@example.com"
    password: "SecurePass123"
    fullName: "John Doe"
    phone: "+923001234567"
  }) {
    success
    message
    token
    user {
      uid
      email
      fullName
    }
  }
}
```

#### Register Provider (Service Provider)
```graphql
mutation {
  registerProvider(input: {
    email: "provider@example.com"
    password: "SecurePass123"
    fullName: "Ahmed Khan"
    phone: "+923001234567"
    businessName: "Khan Transport Services"
    businessType: "sand_truck"
    description: "Premium sand truck services"
    location: "Lahore, Punjab"
  }) {
    success
    message
    token
    user {
      uid
      email
      fullName
      businessName
      businessType
    }
  }
}
```

#### Login
```graphql
mutation {
  login(input: {
    email: "customer@example.com"
    password: "SecurePass123"
    userType: "seeker"
  }) {
    success
    message
    token
    user {
      uid
      email
      fullName
    }
  }
}
```

#### Search Providers
```graphql
query {
  providers(businessType: "sand_truck", limit: 10) {
    uid
    fullName
    businessName
    businessType
    description
    location
    rating
    totalBookings
    isVerified
  }
}
```

#### Get Current User (Authenticated)
```graphql
query {
  me {
    uid
    email
    fullName
    phone
    userType
  }
}
```

**Note**: For authenticated queries, add Authorization header:
```
Authorization: Bearer <your_firebase_token>
```

---

## 🔄 Migration from REST to GraphQL

If you were using the REST API before, here are the key changes:

| REST Endpoint | GraphQL Operation |
|--------------|-------------------|
| `POST /api/auth/register/seeker` | `mutation { registerSeeker(input: {...}) }` |
| `POST /api/auth/register/provider` | `mutation { registerProvider(input: {...}) }` |
| `POST /api/auth/login` | `mutation { login(input: {...}) }` |
| `GET /api/auth/me` | `query { me { ... } }` |
| `GET /api/auth/profile/:uid` | `query { user(uid: "...") { ... } }` |

**Benefits of GraphQL:**
- Request exactly the data you need
- Single endpoint for all operations
- Better type safety
- Interactive documentation
- Easier to version and extend

---

## 🔑 Business Types

The following vehicle/equipment types are supported:

1. **harvester** - Harvester Services
2. **sand_truck** - Sand Truck (Trolley)
3. **brick_truck** - Brick Truck (Trolley)
4. **crane** - Crane Services

---

## ⚠️ Legacy REST Endpoints (Deprecated)

The following REST endpoints are **deprecated** and will be removed in future versions:

### 3. Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "securePassword123"
}

Response:
{
  "uid": "firebase_uid_here",
  "email": "user@example.com",
  "token": "firebase_id_token",
  "user_type": "seeker",
  "user_data": { ... }
}
```

### 4. Verify Token
```http
POST /api/auth/verify
Authorization: Bearer <firebase_token>

Response:
{
  "valid": true,
  "uid": "firebase_uid_here",
  "email": "user@example.com"
}
```

### 5. Get User Profile
```http
GET /api/auth/profile
Authorization: Bearer <firebase_token>

Response:
{
  "uid": "firebase_uid_here",
  "email": "user@example.com",
  "user_type": "seeker",
  "profile": { ... }
}
```

## 🗄️ Database Schema

### Neo4j Graph Structure

#### Seeker Node
```cypher
(:Seeker {
  uid: String,
  email: String,
  full_name: String,
  phone: String,
  profile_image: String,
  created_at: DateTime,
  updated_at: DateTime
})
```

#### Provider Node
```cypher
(:Provider {
  uid: String,
  email: String,
  full_name: String,
  phone: String,
  business_name: String,
  business_type: String,
  profile_image: String,
  is_verified: Boolean,
  rating: Float,
  total_bookings: Integer,
  created_at: DateTime,
  updated_at: DateTime
})
```

## 🔒 Security

- Firebase handles password hashing and authentication
- JWT tokens for API authentication
- Environment variables for sensitive data
- Input validation with Pydantic models

## 📁 Project Structure

```
backend/
├── main.py                 # FastAPI application entry point
├── requirements.txt        # Python dependencies
├── .env                    # Environment variables
├── firebase-credentials.json  # Firebase service account key
├── config/
│   ├── __init__.py
│   ├── firebase.py        # Firebase configuration
│   ├── neo4j.py          # Neo4j configuration
│   └── settings.py       # App settings
├── models/
│   ├── __init__.py
│   ├── user.py           # User models
│   └── schemas.py        # Pydantic schemas
├── services/
│   ├── __init__.py
│   ├── auth_service.py   # Authentication logic
│   └── user_service.py   # User CRUD operations
├── repositories/
│   ├── __init__.py
│   └── user_repository.py  # Neo4j queries
└── routes/
    ├── __init__.py
    └── auth.py           # Auth endpoints
```

## 🧪 Testing

```bash
# Run tests
pytest

# Run with coverage
pytest --cov=.
```

## 🚀 Future Enhancements

- [ ] Booking management endpoints
- [ ] Real-time messaging with WebSockets
- [ ] Payment integration
- [ ] Rating and review system
- [ ] Notification service
- [ ] Admin dashboard APIs
- [ ] Analytics and reporting

## 📝 License

Proprietary - Haulistry Project

## 👥 Authors

FYP Team - Haulistry

---

For issues and questions, please contact the development team.
