import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

/// Service for JWT token generation and validation.
class JwtService {
  final String secret;

  JwtService(this.secret);

  /// Generate JWT token for user.
  ///
  /// [userId] - Unique user identifier
  /// [userName] - User's full name
  /// [surname] - User's surname
  /// [userGroup] - User's study group
  /// [expiresInDays] - Token expiration in days (default: 30)
  String generateToken({
    required String userId,
    required String userName,
    required String surname,
    required String userGroup,
    int expiresInDays = 30,
  }) {
    final now = DateTime.now();
    final expiresAt = now.add(Duration(days: expiresInDays));

    final payload = {
      'userId': userId,
      'userName': userName,
      'surname': surname,
      'userGroup': userGroup,
      'iat': now.millisecondsSinceEpoch ~/ 1000, // Issued at
      'exp': expiresAt.millisecondsSinceEpoch ~/ 1000, // Expiration
    };

    final jwt = JWT(payload);
    final token = jwt.sign(SecretKey(secret));
    return token;
  }

  /// Generate admin JWT token.
  ///
  /// [adminId] - Admin identifier
  /// [expiresInDays] - Token expiration in days (default: 7)
  String generateAdminToken({
    required String adminId,
    int expiresInDays = 7,
  }) {
    final now = DateTime.now();
    final expiresAt = now.add(Duration(days: expiresInDays));

    final payload = {
      'adminId': adminId,
      'isAdmin': true,
      'iat': now.millisecondsSinceEpoch ~/ 1000,
      'exp': expiresAt.millisecondsSinceEpoch ~/ 1000,
    };

    final jwt = JWT(payload);
    final token = jwt.sign(SecretKey(secret));
    return token;
  }

  /// Verify and decode JWT token.
  ///
  /// Returns decoded payload if valid, null otherwise.
  Map<String, dynamic>? verifyToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(secret));
      return jwt.payload as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  /// Check if token is expired.
  bool isTokenExpired(Map<String, dynamic> payload) {
    final exp = payload['exp'] as int?;
    if (exp == null) return true;

    final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    return DateTime.now().isAfter(expirationDate);
  }

  /// Extract user ID from token payload.
  String? getUserId(Map<String, dynamic> payload) {
    return payload['userId'] as String?;
  }

  /// Check if token is admin token.
  bool isAdminToken(Map<String, dynamic> payload) {
    return payload['isAdmin'] == true;
  }
}
