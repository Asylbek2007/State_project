import 'package:shelf/shelf.dart';
import '../services/jwt_service.dart';

/// Middleware for JWT authentication.
Middleware authMiddleware(JwtService jwtService) {
  return (innerHandler) {
    return (Request request) async {
      // Skip auth for public routes
      final path = request.url.path;
      if (path.startsWith('auth/register') ||
          path.startsWith('auth/login') ||
          path.startsWith('health') ||
          (path.startsWith('goals') && request.method == 'GET') ||
          (path.startsWith('donations') && request.method == 'GET')) {
        return innerHandler(request);
      }

      // Extract token from Authorization header
      final authHeader = request.headers['authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.unauthorized(
          {'error': 'Missing or invalid authorization header'},
          headers: {'Content-Type': 'application/json'},
        );
      }

      final token = authHeader.substring(7); // Remove 'Bearer ' prefix
      final payload = jwtService.verifyToken(token);

      if (payload == null) {
        return Response.unauthorized(
          {'error': 'Invalid or expired token'},
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (jwtService.isTokenExpired(payload)) {
        return Response.unauthorized(
          {'error': 'Token expired'},
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Check admin routes
      if (path.startsWith('admin/')) {
        if (!jwtService.isAdminToken(payload)) {
          return Response.forbidden(
            {'error': 'Admin access required'},
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

