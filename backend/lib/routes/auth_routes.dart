import 'dart:convert';
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

    // Login user (verify token)
    _router.post('/verify', _verifyToken);

    // Admin login
    _router.post('/admin/login', _adminLogin);
  }

  Router get router => _router;

  /// Register a new user.
  Future<Response> _registerUser(Request request) async {
    try {
      final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final fullName = body['fullName'] as String?;
      final surname = body['surname'] as String?;
      final studyGroup = body['studyGroup'] as String?;

      // Validation
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

      // Save to Google Sheets
      final now = DateTime.now().toIso8601String();
      await sheetsService.appendRow(
        'Users',
        [fullName.trim(), surname.trim(), studyGroup.trim(), now],
      );

      // Generate user ID
      final userId = '${DateTime.now().millisecondsSinceEpoch}_${fullName.hashCode}';

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

