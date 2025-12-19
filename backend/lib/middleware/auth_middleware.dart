import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../services/jwt_service.dart';

/// Middleware for JWT authentication.
Middleware authMiddleware(JwtService jwtService) {
  return (innerHandler) {
    return (Request request) async {
      // Skip auth for public routes
      final path = request.url.path;
      if (path.startsWith('api/auth/register') ||
          path.startsWith('api/auth/login') ||
          path.startsWith('api/auth/verify') ||
          path.startsWith('api/auth/admin/login') ||
          path == 'health' ||
          (path.startsWith('api/goals') && request.method == 'GET') ||
          (path.startsWith('api/donations') && request.method == 'GET')) {
        return innerHandler(request);
      }

      // Extract token from Authorization header
      final authHeader = request.headers['authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.unauthorized(
          jsonEncode({'error': 'Missing or invalid authorization header'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final token = authHeader.substring(7); // Remove 'Bearer ' prefix
      final payload = jwtService.verifyToken(token);

      if (payload == null) {
        return Response.unauthorized(
          jsonEncode({'error': 'Invalid or expired token'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (jwtService.isTokenExpired(payload)) {
        return Response.unauthorized(
          jsonEncode({'error': 'Token expired'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Check admin routes
      if (path.startsWith('api/admin/')) {
        if (!jwtService.isAdminToken(payload)) {
          return Response.forbidden(
            jsonEncode({'error': 'Admin access required'}),
            headers: {'Content-Type': 'application/json'},
          );
        }
      }

      // Add user info to request context
      final updatedRequest = request.change(
        context: {
          ...request.context,
          'user': payload,
          'userId': jwtService.getUserId(payload),
          'isAdmin': jwtService.isAdminToken(payload),
        },
      );

      return innerHandler(updatedRequest);
    };
  };
}

