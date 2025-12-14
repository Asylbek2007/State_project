import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for storing and managing authentication tokens.
///
/// Uses flutter_secure_storage for secure token persistence.
/// Implements a simple HMAC-signed token approach (client-side signing).
///
/// ⚠️ SECURITY NOTE:
/// For production deployment to Play Market, consider:
/// 1. Server-side JWT signing with Cloud Function/Backend
/// 2. Token refresh mechanism
/// 3. Proper secret management (not hardcoded)
///
/// Current implementation: Simpler approach with client-side HMAC
/// Good for: MVP, college internal app
/// Upgrade to: Server-signed JWT for public Play Market release
class TokenStorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userGroupKey = 'user_group';
  
  // ⚠️ WARNING: This secret should be stored server-side in production!
  // For now, using a client-side secret for MVP.
  // TODO: Move to Cloud Function for Play Market release.
  static const String _appSecret = 'donation_app_secret_key_2024_v1';
  
  final FlutterSecureStorage _secureStorage;

  TokenStorageService()
      : _secureStorage = const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock,
          ),
        );

  /// Generate a signed token for a user.
  ///
  /// Token format: {userId}:{userName}:{userGroup}:{timestamp}:{signature}
  ///
  /// Signature = HMAC-SHA256(userId|userName|userGroup|timestamp, secret)
  ///
  /// ⚠️ In production, this should be done server-side!
  String generateToken({
    required String userId,
    required String userName,
    required String userGroup,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final payload = '$userId|$userName|$userGroup|$timestamp';
    
    // Generate HMAC signature
    final key = utf8.encode(_appSecret);
    final bytes = utf8.encode(payload);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    final signature = base64Url.encode(digest.bytes);

    // Construct token
    final token = base64Url.encode(utf8.encode(
      '$userId:$userName:$userGroup:$timestamp:$signature',
    ));

    return token;
  }

  /// Validate a token.
  ///
  /// Returns token data if valid, null if invalid or expired.
  Map<String, String>? validateToken(String token) {
    try {
      // Decode token
      final decoded = utf8.decode(base64Url.decode(token));
      final parts = decoded.split(':');
      
      if (parts.length != 5) {
        return null; // Invalid format
      }

      final userId = parts[0];
      final userName = parts[1];
      final userGroup = parts[2];
      final timestamp = parts[3];
      final signature = parts[4];

      // Verify signature
      final payload = '$userId|$userName|$userGroup|$timestamp';
      final key = utf8.encode(_appSecret);
      final bytes = utf8.encode(payload);
      final hmac = Hmac(sha256, key);
      final digest = hmac.convert(bytes);
      final expectedSignature = base64Url.encode(digest.bytes);

      if (signature != expectedSignature) {
        return null; // Invalid signature
      }

      // Check expiry (30 days)
      final tokenTimestamp = int.tryParse(timestamp);
      if (tokenTimestamp == null) {
        return null;
      }

      final tokenDate = DateTime.fromMillisecondsSinceEpoch(tokenTimestamp);
      final expiryDate = tokenDate.add(const Duration(days: 30));
      
      if (DateTime.now().isAfter(expiryDate)) {
        return null; // Expired
      }

      return {
        'userId': userId,
        'userName': userName,
        'userGroup': userGroup,
        'timestamp': timestamp,
      };
    } catch (e) {
      print('Token validation error: $e');
      return null;
    }
  }

  /// Save token and user data securely.
  Future<void> saveToken({
    required String token,
    required String userId,
    required String userName,
    required String userGroup,
  }) async {
    try {
      await Future.wait([
        _secureStorage.write(key: _tokenKey, value: token),
        _secureStorage.write(key: _userIdKey, value: userId),
        _secureStorage.write(key: _userNameKey, value: userName),
        _secureStorage.write(key: _userGroupKey, value: userGroup),
      ]);
    } catch (e) {
      throw Exception('Failed to save token: $e');
    }
  }

  /// Get stored token.
  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: _tokenKey);
    } catch (e) {
      print('Failed to read token: $e');
      return null;
    }
  }

  /// Get stored user data.
  Future<Map<String, String>?> getUserData() async {
    try {
      final results = await Future.wait([
        _secureStorage.read(key: _userIdKey),
        _secureStorage.read(key: _userNameKey),
        _secureStorage.read(key: _userGroupKey),
      ]);

      final userId = results[0];
      final userName = results[1];
      final userGroup = results[2];

      if (userId == null || userName == null || userGroup == null) {
        return null;
      }

      return {
        'userId': userId,
        'userName': userName,
        'userGroup': userGroup,
      };
    } catch (e) {
      print('Failed to read user data: $e');
      return null;
    }
  }

  /// Check if user is authenticated (has valid token).
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    if (token == null) {
      return false;
    }

    final validationResult = validateToken(token);
    return validationResult != null;
  }

  /// Clear all stored data (logout).
  Future<void> clearAll() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      throw Exception('Failed to clear storage: $e');
    }
  }

  /// Delete specific key.
  Future<void> delete(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (e) {
      throw Exception('Failed to delete key $key: $e');
    }
  }
}

