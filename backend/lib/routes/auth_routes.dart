import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/jwt_service.dart';
import '../services/google_sheets_service.dart';
import '../config/config.dart';

/// Authentication routes.
class AuthRoutes {
  final JwtService jwtService;
  final GoogleSheetsService sheetsService;
  final Router _router = Router();

  AuthRoutes(this.jwtService, this.sheetsService) {
    _setupRoutes();
  }

  void _setupRoutes() {
    // Register new user
    _router.post('/register', _registerUser);

    // Login user with email and password
    _router.post('/login', _loginUser);

    // Login user (verify token)
    _router.post('/verify', _verifyToken);

    // Admin login
    _router.post('/admin/login', _adminLogin);
  }

  Router get router => _router;

  /// Hash password using SHA-256 with salt.
  /// Uses email as salt to ensure consistent hashing for the same password.
  String _hashPassword(String password, String email) {
    // Use email as salt for consistent hashing
    final salt = email.toLowerCase();
    final bytes = utf8.encode('$password$salt');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Check if email already exists in Google Sheets.
  Future<bool> _emailExists(String email) async {
    try {
      final rows = await sheetsService.readSheet('Users');
      if (rows.isEmpty) return false;
      
      // Skip header row if exists
      final startIndex = rows[0][0].toString().toLowerCase() == 'email' ? 1 : 0;
      
      for (int i = startIndex; i < rows.length; i++) {
        if (rows[i].isNotEmpty && rows[i][0].toString().toLowerCase() == email.toLowerCase()) {
          return true;
        }
      }
      return false;
    } catch (e) {
      // If error reading, assume email doesn't exist to allow registration
      return false;
    }
  }

  /// Register a new user.
  Future<Response> _registerUser(Request request) async {
    try {
      final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final email = (body['email'] as String?)?.trim().toLowerCase();
      final password = body['password'] as String?;
      final fullName = body['fullName'] as String?;
      final surname = body['surname'] as String?;
      final studyGroup = body['studyGroup'] as String?;

      // Validation
      if (email == null || email.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Email is required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Email format validation
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email)) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Invalid email format'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Check if email already exists
      if (await _emailExists(email)) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Email already registered'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (password == null || password.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Password is required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (password.length < 6) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Password must be at least 6 characters'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (fullName == null || fullName.trim().isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Full name is required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (surname == null || surname.trim().isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Surname is required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (studyGroup == null || studyGroup.trim().isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Study group is required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Hash password
      final passwordHash = _hashPassword(password, email);

      // Save to Google Sheets
      // Sheet structure: Email | Password Hash | Full Name | Surname | Study Group | Registration Date
      final now = DateTime.now().toIso8601String();
      await sheetsService.appendRow(
        'Users',
        [
          email,
          passwordHash,
          fullName.trim(),
          surname.trim(),
          studyGroup.trim(),
          now,
        ],
      );

      // Generate user ID
      final userId = '${email.hashCode}_${DateTime.now().millisecondsSinceEpoch}';

      // Generate JWT token
      final token = jwtService.generateToken(
        userId: userId,
        userName: fullName.trim(),
        surname: surname.trim(),
        userGroup: studyGroup.trim(),
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'token': token,
          'user': {
            'userId': userId,
            'email': email,
            'userName': fullName.trim(),
            'surname': surname.trim(),
            'userGroup': studyGroup.trim(),
            'registeredAt': now,
          },
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Registration failed', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// Login user with email and password.
  Future<Response> _loginUser(Request request) async {
    try {
      final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final email = (body['email'] as String?)?.trim().toLowerCase();
      final password = body['password'] as String?;

      // Validation
      if (email == null || email.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Email is required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (password == null || password.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Password is required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Read Users sheet
      final rows = await sheetsService.readSheet('Users');
      if (rows.isEmpty || rows.length < 2) {
        return Response(
          401,
          body: jsonEncode({'error': 'Invalid email or password'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Skip header row
      final startIndex = rows[0][0].toString().toLowerCase() == 'email' ? 1 : 0;

      // Hash provided password
      final passwordHash = _hashPassword(password, email);

      // Find user by email and verify password
      for (int i = startIndex; i < rows.length; i++) {
        final row = rows[i];
        if (row.isEmpty || row.length < 6) continue;

        final rowEmail = row[0].toString().trim().toLowerCase();
        final rowPasswordHash = row[1].toString().trim();

        if (rowEmail == email && rowPasswordHash == passwordHash) {
          // User found and password matches
          final fullName = row[2].toString().trim();
          final surname = row[3].toString().trim();
          final studyGroup = row[4].toString().trim();
          final registeredAt = row.length > 5
              ? row[5].toString().trim()
              : DateTime.now().toIso8601String();

          // Generate user ID
          final userId = '${email.hashCode}_${DateTime.now().millisecondsSinceEpoch}';

          // Generate JWT token
          final token = jwtService.generateToken(
            userId: userId,
            userName: fullName,
            surname: surname,
            userGroup: studyGroup,
          );

          return Response.ok(
            jsonEncode({
              'success': true,
              'token': token,
              'user': {
                'userId': userId,
                'email': email,
                'userName': fullName,
                'surname': surname,
                'userGroup': studyGroup,
                'registeredAt': registeredAt,
              },
            }),
            headers: {'Content-Type': 'application/json'},
          );
        }
      }

      // User not found or password incorrect
      return Response(
        401,
        body: jsonEncode({'error': 'Invalid email or password'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Login failed', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// Verify JWT token.
  Future<Response> _verifyToken(Request request) async {
    try {
      final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final token = body['token'] as String?;

      if (token == null || token.isEmpty) {
        return Response.ok(
          jsonEncode({'valid': false}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final payload = jwtService.verifyToken(token);

      if (payload == null || jwtService.isTokenExpired(payload)) {
        return Response.ok(
          jsonEncode({'valid': false}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'valid': true,
          'user': {
            'userId': payload['userId'],
            'userName': payload['userName'],
            'surname': payload['surname'],
            'userGroup': payload['userGroup'],
          },
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.ok(
        jsonEncode({'valid': false}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// Admin login.
  Future<Response> _adminLogin(Request request) async {
    try {
      final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final password = body['password'] as String?;

      if (password == null || password != Config.adminPassword) {
        return Response(
          401,
          body: jsonEncode({'error': 'Invalid admin password'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Generate admin token
      final adminId = 'admin_${DateTime.now().millisecondsSinceEpoch}';
      final token = jwtService.generateAdminToken(adminId: adminId);

      return Response.ok(
        jsonEncode({
          'success': true,
          'token': token,
          'isAdmin': true,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Admin login failed', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}

