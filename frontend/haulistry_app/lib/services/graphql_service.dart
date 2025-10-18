import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // Import for ValueNotifier

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
    final httpLink = HttpLink(_graphqlEndpoint);

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
    debugPrint('\n🌐 GraphQL Service - registerSeeker');
    debugPrint('   Endpoint: $_graphqlEndpoint');
    debugPrint('   Email: $email');
    debugPrint('   Name: $fullName');
    
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

    debugPrint('📤 Sending mutation request...');
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
      ),
    );

    if (result.hasException) {
      debugPrint('❌ GraphQL Exception: ${result.exception}');
      debugPrint('❌ Link Exception: ${result.exception?.linkException}');
      debugPrint('❌ GraphQL Errors: ${result.exception?.graphqlErrors}');
      throw result.exception!;
    }

    debugPrint('✅ GraphQL Success: ${result.data}');
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
      ),
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
              address
              bio
              gender
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
      ),
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
            businessName
            businessType
            serviceType
            cnicNumber
            address
            city
            province
            yearsExperience
            description
            rating
            totalBookings
            isVerified
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
  }) async {
    print('📡 GraphQL: Updating provider profile...');
    
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
            rating
            totalBookings
            isVerified
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

    print('📤 Sending update with fields: ${input.keys.join(", ")}');

    final QueryResult result = await _client.mutate(
      MutationOptions(
        document: gql(mutation),
        variables: {
          'input': input,
        },
      ),
    );

    if (result.hasException) {
      print('❌ GraphQL Error: ${result.exception}');
      throw result.exception!;
    }

    final response = result.data!['updateProviderProfile'];
    print('✅ Update response: ${response['message']}');
    
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
    print('📡 GraphQL: Updating seeker profile...');
    
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

    print('📤 Sending update with fields: ${input.keys.join(", ")}');

    final QueryResult result = await _client.mutate(
      MutationOptions(
        document: gql(mutation),
        variables: {
          'input': input,
        },
      ),
    );

    if (result.hasException) {
      print('❌ GraphQL Error: ${result.exception}');
      throw result.exception!;
    }

    final response = result.data!['updateSeekerProfile'];
    print('✅ Update response: ${response['message']}');
    
    return {
      'success': response['success'],
      'message': response['message'],
      'user': response['user'],
    };
  }
}

