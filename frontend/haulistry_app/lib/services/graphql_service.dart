import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // Import for ValueNotifier
import 'package:http/http.dart' as http;
import 'dart:convert'; // Import for jsonEncode

class GraphQLService {
  static final GraphQLService _instance = GraphQLService._internal();
  factory GraphQLService() => _instance;
  GraphQLService._internal();

  late GraphQLClient _client;
  
  // Update this URL to your backend GraphQL endpoint
  static const String _graphqlEndpoint = 'http://localhost:8000/graphql';
  // For physical device/emulator use your computer's IP:
  // static const String _graphqlEndpoint = 'http://192.168.1.X:8000/graphql';

  /// Initialize GraphQL client
  void initialize() {
    // Create custom HTTP client with extended timeout
    final httpClient = http.Client();
    
    final httpLink = HttpLink(
      _graphqlEndpoint,
      httpClient: httpClient,
      defaultHeaders: {
        'Content-Type': 'application/json',
      },
    );

    // Add authentication link to include Firebase token in headers
    final authLink = AuthLink(
      getToken: () async {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final token = await user.getIdToken();
          return 'Bearer $token';
        }
        return null;
      },
    );

    final link = authLink.concat(httpLink);

    _client = GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: link,
      defaultPolicies: DefaultPolicies(
        query: Policies(
          fetch: FetchPolicy.networkOnly,
        ),
        mutate: Policies(
          fetch: FetchPolicy.networkOnly,
        ),
      ),
    );
  }

  /// Get GraphQL client instance
  GraphQLClient get client => _client;

  /// Create a value notifier for GraphQL provider
  ValueNotifier<GraphQLClient> getClientNotifier() {
    return ValueNotifier(_client);
  }

  // ============================================================================
  // AUTHENTICATION MUTATIONS
  // ============================================================================

  /// Register a new seeker (customer)
  Future<Map<String, dynamic>> registerSeeker({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    
    const String mutation = r'''
      mutation RegisterSeeker($input: SeekerRegisterInput!) {
        registerSeeker(input: $input) {
          success
          message
          token
          user {
            uid
            email
            fullName
            phone
            userType
            createdAt
            updatedAt
          }
        }
      }
    ''';

    final result = await _client.mutate(
      MutationOptions(
        document: gql(mutation),
        variables: {
          'input': {
            'email': email,
            'password': password,
            'fullName': fullName,
            'phone': phone,
          },
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    ).timeout(
      const Duration(seconds: 60),
      onTimeout: () {
        throw Exception('Request timed out. Please check your internet connection and try again.');
      },
    );

    if (result.hasException) {
      throw result.exception!;
    }

    return result.data!['registerSeeker'];
  }

  /// Register a new provider (service provider)
  Future<Map<String, dynamic>> registerProvider({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    String? businessName,
    String? businessType,
    String? serviceType,
    String? cnicNumber,
    String? address,
    String? city,
    String? province,
    int? yearsExperience,
    String? description,
  }) async {
    const String mutation = r'''
      mutation RegisterProvider($input: ProviderRegisterInput!) {
        registerProvider(input: $input) {
          success
          message
          token
          user {
            uid
            email
            fullName
            phone
            userType
            businessName
            businessType
            serviceType
            cnicNumber
            address
            city
            province
            yearsExperience
            description
            isVerified
            createdAt
            updatedAt
          }
        }
      }
    ''';

    final result = await _client.mutate(
      MutationOptions(
        document: gql(mutation),
        variables: {
          'input': {
            'email': email,
            'password': password,
            'fullName': fullName,
            'phone': phone,
            if (businessName != null) 'businessName': businessName,
            if (businessType != null) 'businessType': businessType,
            if (serviceType != null) 'serviceType': serviceType,
            if (cnicNumber != null) 'cnicNumber': cnicNumber,
            if (address != null) 'address': address,
            if (city != null) 'city': city,
            if (province != null) 'province': province,
            if (yearsExperience != null) 'yearsExperience': yearsExperience,
            if (description != null) 'description': description,
          },
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    ).timeout(
      const Duration(seconds: 60),
      onTimeout: () {
        throw Exception('Request timed out. Please check your internet connection and try again.');
      },
    );

    if (result.hasException) {
      throw result.exception!;
    }

    return result.data!['registerProvider'];
  }

  /// Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    const String mutation = r'''
      mutation Login($input: LoginInput!) {
        login(input: $input) {
          __typename
          ... on ProviderAuthResponse {
            success
            message
            token
            user {
              uid
              email
              fullName
              phone
              userType
              businessName
              businessType
              serviceType
              address
              city
              province
              isVerified
              createdAt
              updatedAt
              profileImage
              cnicNumber
              cnicFrontImage
              cnicBackImage
              licenseImage
              licenseNumber
              rating
              totalBookings
              verificationStatus
              documentsUploaded
              yearsExperience
              description
            }
          }
          ... on SeekerAuthResponse {
            success
            message
            token
            user {
              uid
              email
              fullName
              phone
              userType
              profileImage
              address
              bio
              gender
              dateOfBirth
              serviceCategories
              categoryDetails
              serviceRequirements
              primaryPurpose
              urgency
              preferencesNotes
              createdAt
              updatedAt
            }
          }
        }
      }
    ''';

    final result = await _client.mutate(
      MutationOptions(
        document: gql(mutation),
        variables: {
          'input': {
            'email': email,
            'password': password,
          },
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    ).timeout(
      const Duration(seconds: 60),
      onTimeout: () {
        throw Exception('Login request timed out. Please check your connection and try again.');
      },
    );

    if (result.hasException) {
      throw result.exception!;
    }

    return result.data!['login'];
  }

  // ============================================================================
  // QUERIES
  // ============================================================================

  /// Get user profile by UID
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    const String query = r'''
      query GetUserProfile($uid: String!) {
        user(uid: $uid) {
          __typename
          ... on Seeker {
            uid
            email
            fullName
            phone
            userType
            profileImage
            address
            bio
            gender
            dateOfBirth
            serviceCategories
            categoryDetails
            serviceRequirements
            primaryPurpose
            urgency
            preferencesNotes
            createdAt
            updatedAt
          }
          ... on Provider {
            uid
            email
            fullName
            phone
            userType
            profileImage
            businessName
            businessType
            serviceType
            cnicNumber
            cnicFrontImage
            cnicBackImage
            licenseImage
            licenseNumber
            address
            city
            province
            yearsExperience
            description
            rating
            totalBookings
            isVerified
            verificationStatus
            documentsUploaded
            createdAt
            updatedAt
          }
        }
      }
    ''';

    final result = await _client.query(
      QueryOptions(
        document: gql(query),
        variables: {'uid': uid},
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    return result.data?['user'];
  }

  /// Get available business types
  Future<List<String>> getBusinessTypes() async {
    const String query = r'''
      query GetBusinessTypes {
        businessTypes
      }
    ''';

    final result = await _client.query(
      QueryOptions(
        document: gql(query),
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    return List<String>.from(result.data!['businessTypes']);
  }

  /// Search service providers
  Future<List<Map<String, dynamic>>> searchProviders({
    String? businessType,
    String? location,
  }) async {
    const String query = r'''
      query SearchProviders($businessType: String, $location: String) {
        serviceProviders(businessType: $businessType, location: $location) {
          uid
          fullName
          email
          phone
          businessName
          businessType
          businessAddress
          isVerified
          createdAt
        }
      }
    ''';

    final result = await _client.query(
      QueryOptions(
        document: gql(query),
        variables: {
          if (businessType != null) 'businessType': businessType,
          if (location != null) 'location': location,
        },
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    return List<Map<String, dynamic>>.from(
      result.data!['serviceProviders'],
    );
  }

  Future<Map<String, dynamic>> updateProviderProfile({
    required String uid,
    String? businessName,
    String? businessType,
    String? serviceType,
    String? cnicNumber,
    String? address,
    String? city,
    String? province,
    int? yearsExperience,
    String? description,
    // Document images (Base64 data URLs)
    String? profileImage,
    String? cnicFrontImage,
    String? cnicBackImage,
    String? licenseImage,
    String? licenseNumber,
    List<Map<String, dynamic>>? vehicles, // Add vehicles parameter
  }) async {
    
    const String mutation = r'''
      mutation UpdateProviderProfile($input: UpdateProviderProfileInput!) {
        updateProviderProfile(input: $input) {
          success
          message
          user {
            uid
            email
            fullName
            phone
            userType
            businessName
            businessType
            serviceType
            cnicNumber
            address
            city
            province
            yearsExperience
            description
            profileImage
            cnicFrontImage
            cnicBackImage
            licenseImage
            licenseNumber
            isVerified
            documentsUploaded
            verificationStatus
            rating
            totalBookings
            createdAt
            updatedAt
          }
        }
      }
    ''';

    final Map<String, dynamic> input = {
      'uid': uid,
    };
    
    if (businessName != null) input['businessName'] = businessName;
    if (businessType != null) input['businessType'] = businessType;
    if (serviceType != null) input['serviceType'] = serviceType;
    if (cnicNumber != null) input['cnicNumber'] = cnicNumber;
    if (address != null) input['address'] = address;
    if (city != null) input['city'] = city;
    if (province != null) input['province'] = province;
    if (yearsExperience != null) input['yearsExperience'] = yearsExperience;
    if (description != null) input['description'] = description;
    // Document images
    if (profileImage != null) input['profileImage'] = profileImage;
    if (cnicFrontImage != null) input['cnicFrontImage'] = cnicFrontImage;
    if (cnicBackImage != null) input['cnicBackImage'] = cnicBackImage;
    if (licenseImage != null) input['licenseImage'] = licenseImage;
    if (licenseNumber != null) input['licenseNumber'] = licenseNumber;
    // Vehicles - convert to JSON string
    if (vehicles != null) input['vehicles'] = jsonEncode(vehicles);


    final QueryResult result = await _client.mutate(
      MutationOptions(
        document: gql(mutation),
        variables: {
          'input': input,
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    ).timeout(
      const Duration(seconds: 120),
      onTimeout: () {
        throw Exception('Request timed out after 120 seconds. The data may have been saved. Please refresh to check.');
      },
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final response = result.data!['updateProviderProfile'];
    
    return {
      'success': response['success'],
      'message': response['message'],
      'user': response['user'],
    };
  }

  Future<Map<String, dynamic>> updateSeekerProfile({
    required String uid,
    String? fullName,
    String? phone,
    String? profileImage,
    String? address,
    String? bio,
    String? gender,
    String? dateOfBirth,
    String? serviceCategories,
    String? categoryDetails,
    String? serviceRequirements,
    String? primaryPurpose,
    String? urgency,
    String? preferencesNotes,
  }) async {
    
    const String mutation = r'''
      mutation UpdateSeekerProfile($input: UpdateSeekerProfileInput!) {
        updateSeekerProfile(input: $input) {
          success
          message
          user {
            uid
            email
            fullName
            phone
            userType
            profileImage
            address
            bio
            gender
            dateOfBirth
            serviceCategories
            categoryDetails
            serviceRequirements
            primaryPurpose
            urgency
            preferencesNotes
            createdAt
            updatedAt
          }
        }
      }
    ''';

    final Map<String, dynamic> input = {
      'uid': uid,
    };
    
    if (fullName != null) input['fullName'] = fullName;
    if (phone != null) input['phone'] = phone;
    if (profileImage != null) input['profileImage'] = profileImage;
    if (address != null) input['address'] = address;
    if (bio != null) input['bio'] = bio;
    if (gender != null) input['gender'] = gender;
    if (dateOfBirth != null) input['dateOfBirth'] = dateOfBirth;
    if (serviceCategories != null) input['serviceCategories'] = serviceCategories;
    if (categoryDetails != null) input['categoryDetails'] = categoryDetails;
    if (serviceRequirements != null) input['serviceRequirements'] = serviceRequirements;
    if (primaryPurpose != null) input['primaryPurpose'] = primaryPurpose;
    if (urgency != null) input['urgency'] = urgency;
    if (preferencesNotes != null) input['preferencesNotes'] = preferencesNotes;


    final QueryResult result = await _client.mutate(
      MutationOptions(
        document: gql(mutation),
        variables: {
          'input': input,
        },
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final response = result.data!['updateSeekerProfile'];
    
    return {
      'success': response['success'],
      'message': response['message'],
      'user': response['user'],
    };
  }

  /// Clear seeker preferences by setting all preference fields to null in Neo4j
  Future<Map<String, dynamic>> clearSeekerPreferences({
    required String uid,
  }) async {
    
    // Set all preference-related fields to empty strings (which will be stored as null/empty in Neo4j)
    final result = await updateSeekerProfile(
      uid: uid,
      serviceCategories: '[]',  // Empty JSON array
      categoryDetails: '{}',     // Empty JSON object
      serviceRequirements: '{}', // Empty JSON object
      primaryPurpose: '',        // Empty string
      urgency: '',              // Empty string
      preferencesNotes: '',     // Empty string
    );
    
    return result;
  }

  // ============================================================================
  // VEHICLE MANAGEMENT
  // ============================================================================

  /// Add a new vehicle
  Future<Map<String, dynamic>> addVehicle({
    required String providerUid,
    required String name,
    required String vehicleType,
    required String make,
    required String model,
    required int year,
    required String registrationNumber,
    String? capacity,
    String condition = 'Good',
    String? vehicleImage,
    String? additionalImages,
    bool hasInsurance = false,
    String? insuranceExpiry,
    bool isAvailable = true,
    String? city,
    String? province,
    double? pricePerHour,
    double? pricePerDay,
    String? description,
  }) async {
    const String mutation = r'''
      mutation AddVehicle($input: AddVehicleInput!) {
        addVehicle(input: $input) {
          success
          message
          vehicle {
            vehicleId
            name
            vehicleType
            make
            model
            year
            registrationNumber
            vehicleImage
            city
            province
            pricePerHour
            pricePerDay
            isAvailable
          }
        }
      }
    ''';

    final result = await _client.mutate(
      MutationOptions(
        document: gql(mutation),
        variables: {
          'input': {
            'providerUid': providerUid,
            'name': name,
            'vehicleType': vehicleType,
            'make': make,
            'model': model,
            'year': year,
            'registrationNumber': registrationNumber,
            if (capacity != null) 'capacity': capacity,
            'condition': condition,
            if (vehicleImage != null) 'vehicleImage': vehicleImage,
            if (additionalImages != null) 'additionalImages': additionalImages,
            'hasInsurance': hasInsurance,
            if (insuranceExpiry != null) 'insuranceExpiry': insuranceExpiry,
            'isAvailable': isAvailable,
            if (city != null) 'city': city,
            if (province != null) 'province': province,
            if (pricePerHour != null) 'pricePerHour': pricePerHour,
            if (pricePerDay != null) 'pricePerDay': pricePerDay,
            if (description != null) 'description': description,
          },
        },
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return result.data!['addVehicle'];
  }

  /// Get all vehicles for a provider
  Future<List<Map<String, dynamic>>> getProviderVehicles(String providerUid) async {
    const String query = r'''
      query ProviderVehicles($providerUid: String!) {
        providerVehicles(providerUid: $providerUid) {
          vehicleId
          name
          vehicleType
          make
          model
          year
          registrationNumber
          capacity
          condition
          vehicleImage
          additionalImages
          hasInsurance
          insuranceExpiry
          isAvailable
          city
          province
          pricePerHour
          pricePerDay
          description
          createdAt
          updatedAt
        }
      }
    ''';

    final result = await _client.query(
      QueryOptions(
        document: gql(query),
        variables: {'providerUid': providerUid},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final vehicles = result.data!['providerVehicles'] as List;
    return vehicles.map((v) => Map<String, dynamic>.from(v)).toList();
  }

  /// Update an existing vehicle
  Future<Map<String, dynamic>> updateVehicle({
    required String vehicleId,
    String? name,
    String? vehicleType,
    String? make,
    String? model,
    int? year,
    String? registrationNumber,
    String? capacity,
    String? condition,
    String? vehicleImage,
    String? additionalImages,
    bool? hasInsurance,
    String? insuranceExpiry,
    bool? isAvailable,
    String? city,
    String? province,
    double? pricePerHour,
    double? pricePerDay,
    String? description,
  }) async {
    const String mutation = r'''
      mutation UpdateVehicle($input: UpdateVehicleInput!) {
        updateVehicle(input: $input) {
          success
          message
          vehicle {
            vehicleId
            name
            vehicleType
            make
            model
            year
            registrationNumber
            vehicleImage
            city
            province
            pricePerHour
            pricePerDay
            isAvailable
          }
        }
      }
    ''';

    final result = await _client.mutate(
      MutationOptions(
        document: gql(mutation),
        variables: {
          'input': {
            'vehicleId': vehicleId,
            if (name != null) 'name': name,
            if (vehicleType != null) 'vehicleType': vehicleType,
            if (make != null) 'make': make,
            if (model != null) 'model': model,
            if (year != null) 'year': year,
            if (registrationNumber != null) 'registrationNumber': registrationNumber,
            if (capacity != null) 'capacity': capacity,
            if (condition != null) 'condition': condition,
            if (vehicleImage != null) 'vehicleImage': vehicleImage,
            if (additionalImages != null) 'additionalImages': additionalImages,
            if (hasInsurance != null) 'hasInsurance': hasInsurance,
            if (insuranceExpiry != null) 'insuranceExpiry': insuranceExpiry,
            if (isAvailable != null) 'isAvailable': isAvailable,
            if (city != null) 'city': city,
            if (province != null) 'province': province,
            if (pricePerHour != null) 'pricePerHour': pricePerHour,
            if (pricePerDay != null) 'pricePerDay': pricePerDay,
            if (description != null) 'description': description,
          },
        },
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return result.data!['updateVehicle'];
  }

  /// Delete a vehicle (CASCADE - also deletes related services)
  Future<Map<String, dynamic>> deleteVehicle(String vehicleId) async {
    const String mutation = r'''
      mutation DeleteVehicle($vehicleId: String!) {
        deleteVehicle(vehicleId: $vehicleId) {
          success
          message
        }
      }
    ''';

    final result = await _client.mutate(
      MutationOptions(
        document: gql(mutation),
        variables: {'vehicleId': vehicleId},
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return result.data!['deleteVehicle'];
  }

  // ============================================================================
  // SERVICE MANAGEMENT
  // ============================================================================

  /// Add a new service
  Future<Map<String, dynamic>> addService({
    required String vehicleId,
    required String providerUid,
    required String serviceName,
    required String serviceCategory,
    double? pricePerHour,
    double? pricePerDay,
    double? pricePerService,
    String? description,
    String? serviceArea,
    String? minBookingDuration,
    double? latitude,
    double? longitude,
    String? fullAddress,
    String? city,
    String? province,
    String? serviceImages,  // JSON string array of base64 images
    bool isActive = true,
    String? availableDays,
    String? availableHours,
    bool operatorIncluded = true,
    bool fuelIncluded = false,
    bool transportationIncluded = false,
  }) async {
    const String mutation = r'''
      mutation AddService($input: AddServiceInput!) {
        addService(input: $input) {
          success
          message
          service {
            serviceId
            vehicleId
            serviceName
            serviceCategory
            pricePerHour
            pricePerDay
            pricePerService
            description
            latitude
            longitude
            fullAddress
            city
            province
            serviceImages
            isActive
            operatorIncluded
            fuelIncluded
            transportationIncluded
          }
        }
      }
    ''';

    final result = await _client.mutate(
      MutationOptions(
        document: gql(mutation),
        variables: {
          'input': {
            'vehicleId': vehicleId,
            'providerUid': providerUid,
            'serviceName': serviceName,
            'serviceCategory': serviceCategory,
            if (pricePerHour != null) 'pricePerHour': pricePerHour,
            if (pricePerDay != null) 'pricePerDay': pricePerDay,
            if (pricePerService != null) 'pricePerService': pricePerService,
            if (description != null) 'description': description,
            if (serviceArea != null) 'serviceArea': serviceArea,
            if (minBookingDuration != null) 'minBookingDuration': minBookingDuration,
            if (latitude != null) 'latitude': latitude,
            if (longitude != null) 'longitude': longitude,
            if (fullAddress != null) 'fullAddress': fullAddress,
            if (city != null) 'city': city,
            if (province != null) 'province': province,
            if (serviceImages != null) 'serviceImages': serviceImages,
            'isActive': isActive,
            if (availableDays != null) 'availableDays': availableDays,
            if (availableHours != null) 'availableHours': availableHours,
            'operatorIncluded': operatorIncluded,
            'fuelIncluded': fuelIncluded,
            'transportationIncluded': transportationIncluded,
          },
        },
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return result.data!['addService'];
  }

  /// Get all services for a vehicle
  Future<List<Map<String, dynamic>>> getVehicleServices(String vehicleId) async {
    const String query = r'''
      query VehicleServices($vehicleId: String!) {
        vehicleServices(vehicleId: $vehicleId) {
          serviceId
          vehicleId
          providerUid
          serviceName
          serviceCategory
          pricePerHour
          pricePerDay
          pricePerService
          description
          serviceArea
          minBookingDuration
          latitude
          longitude
          fullAddress
          city
          province
          isActive
          availableDays
          availableHours
          operatorIncluded
          fuelIncluded
          transportationIncluded
          totalBookings
          rating
          createdAt
          updatedAt
        }
      }
    ''';

    final result = await _client.query(
      QueryOptions(
        document: gql(query),
        variables: {'vehicleId': vehicleId},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final services = result.data!['vehicleServices'] as List;
    return services.map((s) => Map<String, dynamic>.from(s)).toList();
  }

  /// Get all services for a provider
  Future<List<Map<String, dynamic>>> getProviderServices(String providerUid) async {
    const String query = r'''
      query ProviderServices($providerUid: String!) {
        providerServices(providerUid: $providerUid) {
          serviceId
          vehicleId
          providerUid
          serviceName
          serviceCategory
          pricePerHour
          pricePerDay
          pricePerService
          description
          serviceArea
          minBookingDuration
          serviceImages
          isActive
          availableDays
          availableHours
          operatorIncluded
          fuelIncluded
          transportationIncluded
          totalBookings
          rating
          createdAt
          updatedAt
        }
      }
    ''';

    final result = await _client.query(
      QueryOptions(
        document: gql(query),
        variables: {'providerUid': providerUid},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final services = result.data!['providerServices'] as List;
    return services.map((s) => Map<String, dynamic>.from(s)).toList();
  }

  /// Update an existing service
  Future<Map<String, dynamic>> updateService({
    required String serviceId,
    String? serviceName,
    String? serviceCategory,
    double? pricePerHour,
    double? pricePerDay,
    double? pricePerService,
    String? description,
    String? serviceArea,
    String? minBookingDuration,
    bool? isActive,
    String? availableDays,
    String? availableHours,
    bool? operatorIncluded,
    bool? fuelIncluded,
    bool? transportationIncluded,
  }) async {
    const String mutation = r'''
      mutation UpdateService($input: UpdateServiceInput!) {
        updateService(input: $input) {
          success
          message
          service {
            serviceId
            serviceName
            serviceCategory
            pricePerHour
            pricePerDay
            pricePerService
            description
            isActive
          }
        }
      }
    ''';

    final result = await _client.mutate(
      MutationOptions(
        document: gql(mutation),
        variables: {
          'input': {
            'serviceId': serviceId,
            if (serviceName != null) 'serviceName': serviceName,
            if (serviceCategory != null) 'serviceCategory': serviceCategory,
            if (pricePerHour != null) 'pricePerHour': pricePerHour,
            if (pricePerDay != null) 'pricePerDay': pricePerDay,
            if (pricePerService != null) 'pricePerService': pricePerService,
            if (description != null) 'description': description,
            if (serviceArea != null) 'serviceArea': serviceArea,
            if (minBookingDuration != null) 'minBookingDuration': minBookingDuration,
            if (isActive != null) 'isActive': isActive,
            if (availableDays != null) 'availableDays': availableDays,
            if (availableHours != null) 'availableHours': availableHours,
            if (operatorIncluded != null) 'operatorIncluded': operatorIncluded,
            if (fuelIncluded != null) 'fuelIncluded': fuelIncluded,
            if (transportationIncluded != null) 'transportationIncluded': transportationIncluded,
          },
        },
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return result.data!['updateService'];
  }

  /// Delete a service
  Future<Map<String, dynamic>> deleteService(String serviceId) async {
    const String mutation = r'''
      mutation DeleteService($serviceId: String!) {
        deleteService(serviceId: $serviceId) {
          success
          message
        }
      }
    ''';

    final result = await _client.mutate(
      MutationOptions(
        document: gql(mutation),
        variables: {'serviceId': serviceId},
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return result.data!['deleteService'];
  }

  // ==================== SEEKER SERVICE QUERIES (ACTIVE ONLY) ====================

  /// Get all active services (for seekers) with optional filters
  /// Only returns services where isActive = true
  Future<List<Map<String, dynamic>>> getActiveServices({
    String? category,
    String? serviceArea,
    double? minRating,
    int limit = 50,
  }) async {
    const String query = r'''
      query ActiveServices(
        $category: String,
        $serviceArea: String,
        $minRating: Float,
        $limit: Int!
      ) {
        activeServices(
          category: $category,
          serviceArea: $serviceArea,
          minRating: $minRating,
          limit: $limit
        ) {
          serviceId
          vehicleId
          providerUid
          serviceName
          serviceCategory
          pricePerHour
          pricePerDay
          pricePerService
          description
          serviceArea
          minBookingDuration
          serviceImages
          isActive
          availableDays
          availableHours
          operatorIncluded
          fuelIncluded
          transportationIncluded
          totalBookings
          rating
          createdAt
          updatedAt
        }
      }
    ''';

    final result = await _client.query(
      QueryOptions(
        document: gql(query),
        variables: {
          if (category != null) 'category': category,
          if (serviceArea != null) 'serviceArea': serviceArea,
          if (minRating != null) 'minRating': minRating,
          'limit': limit,
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final services = result.data!['activeServices'] as List;
    return services.map((s) => Map<String, dynamic>.from(s)).toList();
  }

  /// Get all active services for a specific provider (for seekers)
  /// Only returns services where isActive = true
  Future<List<Map<String, dynamic>>> getActiveProviderServices(String providerUid) async {
    const String query = r'''
      query ActiveProviderServices($providerUid: String!) {
        activeProviderServices(providerUid: $providerUid) {
          serviceId
          vehicleId
          providerUid
          serviceName
          serviceCategory
          pricePerHour
          pricePerDay
          pricePerService
          description
          serviceArea
          minBookingDuration
          serviceImages
          isActive
          availableDays
          availableHours
          operatorIncluded
          fuelIncluded
          transportationIncluded
          totalBookings
          rating
          createdAt
          updatedAt
        }
      }
    ''';

    final result = await _client.query(
      QueryOptions(
        document: gql(query),
        variables: {'providerUid': providerUid},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final services = result.data!['activeProviderServices'] as List;
    return services.map((s) => Map<String, dynamic>.from(s)).toList();
  }
}

