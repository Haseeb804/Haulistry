# 🚀 HAULISTRY APP - QUICK NAVIGATION REFERENCE

**Last Updated:** October 2, 2025  
**Status:** ✅ All Routes Working

---

## 📱 APP NAVIGATION STRUCTURE

### 🔐 AUTHENTICATION (6 Routes)

| Route | Screen | Description |
|-------|--------|-------------|
| `/` | Splash Screen | App initialization |
| `/onboarding` | Onboarding | Welcome screens |
| `/role-selection` | Role Selection | Choose Seeker or Provider |
| `/login` | Login | Sign in to account |
| `/signup?role=` | Signup | Create new account |
| `/forgot-password` | Forgot Password | Reset password |

---

### 👤 SEEKER ROUTES (10 Routes)

| Route | Screen | From Dashboard |
|-------|--------|----------------|
| `/seeker/dashboard` | Dashboard | Home |
| `/seeker/services/:type` | Service Listing | ✅ Service cards |
| `/seeker/service/:id` | Service Detail | ✅ From listing |
| `/seeker/booking/:serviceId` | New Booking | ✅ From detail |
| `/seeker/my-bookings` | My Bookings | ✅ Bottom nav |
| `/seeker/booking-detail/:id` | Booking Detail | ✅ From my bookings |
| `/seeker/profile` | Profile | ✅ Bottom nav |
| `/seeker/edit-profile` | Edit Profile | ✅ From profile |
| `/seeker/favorites` | Favorites | ✅ From profile |
| `/seeker/settings` | Settings | ✅ From profile |

**Service Types Available:**
- `harvester` - Harvesters
- `sandTruck` - Sand Trucks
- `brickTruck` - Brick Trucks
- `crane` - Cranes
- `all` - All Services (search)

---

### 🚜 PROVIDER ROUTES (11 Routes)

| Route | Screen | From Dashboard |
|-------|--------|----------------|
| `/provider/dashboard` | Dashboard | Home |
| `/provider/services` | Services Management | ✅ Bottom nav |
| `/provider/add-service` | Add Service | ✅ From services |
| `/provider/edit-service/:id` | Edit Service | ✅ From services |
| `/provider/booking-requests` | Booking Requests | ✅ Quick action |
| `/provider/bookings` | My Bookings | ✅ Bottom nav |
| `/provider/earnings` | Earnings | ✅ Quick action |
| `/provider/reviews` | Reviews | ✅ Quick action |
| `/provider/profile` | Profile | ✅ Bottom nav |
| `/provider/edit-profile` | Edit Profile | ✅ From profile |
| `/provider/settings` | Settings | ✅ From profile |

---

### 🌐 COMMON ROUTES (5 Routes)

| Route | Screen | Accessible From |
|-------|--------|----------------|
| `/notifications` | Notifications | Both roles - Top bar |
| `/messages` | Messages List | Both roles - Messages icon |
| `/chat/:userId?name=` | Chat | From messages |
| `/settings` | Common Settings | Both roles |
| `/help-support` | Help & Support | Both roles - Profile menu |

---

## 🎨 COLOR GUIDE

### Role Colors
```dart
Seeker:   AppColors.primary   = #2563EB (Blue)
Provider: AppColors.secondary = #F59E0B (Amber/Orange)
```

### Status Colors
```dart
Success:   #10B981 (Green)    - Completed, Accepted, Active
Warning:   #F59E0B (Amber)    - Pending, In Progress
Error:     #EF4444 (Red)      - Cancelled, Rejected, Error
Info:      #3B82F6 (Blue)     - In Progress, Information
```

### Service Category Colors
```dart
Harvester:   AppColors.secondary (#F59E0B - Amber)
Sand Truck:  Colors.purple
Brick Truck: Colors.pink
Crane:       Colors.cyan
```

---

## 🔄 COMMON NAVIGATION PATTERNS

### Using GoRouter:
```dart
// Navigate to new route (push)
context.push('/seeker/services/harvester');

// Navigate with parameters
context.push('/seeker/service/${serviceId}');

// Navigate with query parameters
context.push('/chat/user123?name=John');

// Replace current route (go)
context.go('/seeker/dashboard');

// Go back
context.pop();
```

---

## 📋 NAVIGATION FLOW EXAMPLES

### Seeker: Book a Service
```
Dashboard → Service Card Click
  → /seeker/services/harvester
    → Service Card Click
      → /seeker/service/123
        → "Book Now" Click
          → /seeker/booking/123
            → Submit Booking
              → /seeker/my-bookings
                → Booking Card Click
                  → /seeker/booking-detail/456
```

### Provider: Manage Booking
```
Dashboard → "View Requests" Click
  → /provider/booking-requests
    → Accept Booking
      → /provider/bookings
        → Booking Card Click
          → Update Status
            → Back to bookings
```

### Common: Send Message
```
Dashboard → Messages Icon
  → /messages
    → Conversation Click
      → /chat/user123?name=John Doe
        → Send messages
```

---

## 🛠️ BOTTOM NAVIGATION

### Seeker Bottom Nav (4 Items):
1. **Home** → `/seeker/dashboard`
2. **Services** → `/seeker/services/all`
3. **Bookings** → `/seeker/my-bookings`
4. **Profile** → `/seeker/profile`

### Provider Bottom Nav (4 Items):
1. **Home** → `/provider/dashboard`
2. **Services** → `/provider/services`
3. **Bookings** → `/provider/bookings`
4. **Profile** → `/provider/profile`

---

## 🎯 QUICK ACTIONS

### From Seeker Dashboard:
- Search services → `/seeker/services/all`
- View service → `/seeker/services/:type`
- View bookings → `/seeker/my-bookings`
- View favorites → `/seeker/favorites`
- Notifications → `/notifications`

### From Provider Dashboard:
- Add service → `/provider/add-service`
- View bookings → `/provider/bookings`
- View earnings → `/provider/earnings`
- View reviews → `/provider/reviews`
- Booking requests → `/provider/booking-requests`
- Notifications → `/notifications`

---

## 📱 SCREEN PARAMETERS

### Routes with Path Parameters:
```dart
'/seeker/services/:type'           // type = harvester, sandTruck, etc.
'/seeker/service/:id'              // id = service ID
'/seeker/booking/:serviceId'       // serviceId = service to book
'/seeker/booking-detail/:id'       // id = booking ID
'/provider/edit-service/:id'       // id = service ID to edit
'/provider/booking-management/:id' // id = booking ID to manage
'/chat/:userId'                    // userId = user to chat with
```

### Routes with Query Parameters:
```dart
'/signup?role=seeker'     // role = seeker or provider
'/chat/:userId?name=John' // name = display name
```

---

## ✅ ALL ROUTES TESTED

**Total Routes:** 32  
**Working Routes:** 32 ✅  
**Broken Routes:** 0 ❌

**Status:** 🟢 **ALL NAVIGATION WORKING**

---

## 📞 SUPPORT

**Documentation:**
- Full Review: `IMPLEMENTATION_REVIEW.md`
- Fixes Log: `FIXES_COMPLETED.md`
- This Guide: `NAVIGATION_REFERENCE.md`

**Quick Commands:**
```bash
# Check for errors
flutter analyze

# Run app
flutter run

# Build app
flutter build apk  # Android
flutter build ios  # iOS
```

---

**Last Verified:** October 2, 2025  
**App Version:** 1.0.0  
**Flutter SDK:** >=3.0.0
