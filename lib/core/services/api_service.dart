import 'dart:convert';
import 'package:http/http.dart' as http;
import '../errors/failures.dart';

/// Service for communicating with backend API (Cloud Functions).
///
/// ⚠️ PRODUCTION SETUP REQUIRED:
/// 1. Deploy Cloud Functions (see backend/DEPLOYMENT.md)
/// 2. Update BASE_URL with your actual function URLs
/// 3. For Firebase: use cloud_functions package instead of HTTP
///
/// Current implementation: HTTP calls to Cloud Functions
/// Alternative: Use cloud_functions package for Firebase integration
class ApiService {
  // TODO: Replace with your actual Cloud Function URL after deployment
  // Example: https://us-central1-your-project.cloudfunctions.net
  static const String baseUrl = 'YOUR_CLOUD_FUNCTION_BASE_URL';

  // For local testing with Firebase Emulator:
  // static const String baseUrl = 'http://localhost:5001/YOUR_PROJECT/us-central1';

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Register a new user.
  ///
  /// Calls Cloud Function: registerUser
  /// Returns: { token: string, user: {...} }
  Future<Map<String, dynamic>> registerUser({
    required String fullName,
    required String studyGroup,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/registerUser'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'data': {
            'fullName': fullName,
            'studyGroup': studyGroup,
          },
        }),
      );

      if (response.statusCode != 200) {
        throw ServerFailure(
          'Registration failed: ${response.statusCode} ${response.body}',
        );
      }

      final result = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (result['result'] == null) {
        throw const ServerFailure('Invalid response from server');
      }

      return result['result'] as Map<String, dynamic>;
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure('Network error: ${e.toString()}');
    }
  }

  /// Verify token validity.
  ///
  /// Calls Cloud Function: verifyToken
  /// Returns: { valid: boolean, user?: {...} }
  Future<Map<String, dynamic>> verifyToken(String token) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/verifyToken'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'data': {'token': token},
        }),
      );

      if (response.statusCode != 200) {
        return {'valid': false};
      }

      final result = jsonDecode(response.body) as Map<String, dynamic>;
      return result['result'] as Map<String, dynamic>;
    } catch (e) {
      print('Token verification error: $e');
      return {'valid': false};
    }
  }

  /// Create a donation.
  ///
  /// Calls Cloud Function: createDonation
  /// Requires: Authorization header with token
  Future<Map<String, dynamic>> createDonation({
    required String token,
    required double amount,
    required String message,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/createDonation'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'data': {
            'amount': amount,
            'message': message,
          },
        }),
      );

      if (response.statusCode != 200) {
        throw ServerFailure(
          'Donation failed: ${response.statusCode} ${response.body}',
        );
      }

      final result = jsonDecode(response.body) as Map<String, dynamic>;
      return result['result'] as Map<String, dynamic>;
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure('Network error: ${e.toString()}');
    }
  }

  /// Get all goals.
  ///
  /// Calls Cloud Function: getGoals
  Future<List<Map<String, dynamic>>> getGoals() async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/getGoals'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'data': {}}),
      );

      if (response.statusCode != 200) {
        throw const ServerFailure('Failed to fetch goals');
      }

      final result = jsonDecode(response.body) as Map<String, dynamic>;
      final goals = result['result']['goals'] as List;
      
      return goals.map((g) => g as Map<String, dynamic>).toList();
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure('Network error: ${e.toString()}');
    }
  }

  /// Get total collected amount.
  ///
  /// Calls Cloud Function: getTotalCollected
  Future<double> getTotalCollected() async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/getTotalCollected'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'data': {}}),
      );

      if (response.statusCode != 200) {
        throw const ServerFailure('Failed to fetch total');
      }

      final result = jsonDecode(response.body) as Map<String, dynamic>;
      final total = result['result']['total'];
      
      return (total as num).toDouble();
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure('Network error: ${e.toString()}');
    }
  }

  /// Get donations journal.
  ///
  /// Calls Cloud Function: getDonations
  Future<List<Map<String, dynamic>>> getDonations({int? limit}) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/getDonations'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'data': {'limit': limit},
        }),
      );

      if (response.statusCode != 200) {
        throw const ServerFailure('Failed to fetch donations');
      }

      final result = jsonDecode(response.body) as Map<String, dynamic>;
      final donations = result['result']['donations'] as List;
      
      return donations.map((d) => d as Map<String, dynamic>).toList();
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure('Network error: ${e.toString()}');
    }
  }

  /// Get expenses.
  ///
  /// Calls Cloud Function: getExpenses
  Future<List<Map<String, dynamic>>> getExpenses() async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/getExpenses'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'data': {}}),
      );

      if (response.statusCode != 200) {
        throw const ServerFailure('Failed to fetch expenses');
      }

      final result = jsonDecode(response.body) as Map<String, dynamic>;
      final expenses = result['result']['expenses'] as List;
      
      return expenses.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure('Network error: ${e.toString()}');
    }
  }

  /// Dispose resources.
  void dispose() {
    _client.close();
  }
}

/// Alternative: Firebase Cloud Functions Integration
///
/// If using Firebase, add dependency:
/// ```yaml
/// dependencies:
///   cloud_functions: ^4.5.0
/// ```
///
/// Then use this implementation:
/// ```dart
/// import 'package:cloud_functions/cloud_functions.dart';
///
/// class ApiService {
///   final _functions = FirebaseFunctions.instance;
///
///   Future<Map<String, dynamic>> registerUser(...) async {
///     final result = await _functions
///         .httpsCallable('registerUser')
///         .call({'fullName': fullName, 'studyGroup': studyGroup});
///     return result.data;
///   }
/// }
/// ```

