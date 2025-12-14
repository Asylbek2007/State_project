import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/jwt_service.dart';
import '../services/google_sheets_service.dart';

/// User routes.
class UserRoutes {
  final JwtService jwtService;
  final GoogleSheetsService sheetsService;
  final Router _router = Router();

  UserRoutes(this.jwtService, this.sheetsService) {
    _setupRoutes();
  }

  void _setupRoutes() {
    // Get user donations count
    _router.get('/donations/count', _getUserDonationsCount);
  }

  Router get router => _router;

  /// Get count of donations for current user.
  Future<Response> _getUserDonationsCount(Request request) async {
    try {
      // Get user from context
      final user = request.context['user'] as Map<String, dynamic>?;
      if (user == null) {
        return Response(
          401,
          body: jsonEncode({'error': 'Authentication required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final userName = user['userName'] as String;
      final surname = user['surname'] as String? ?? '';
      final fullName = '$userName $surname'.trim();

      // Get all donations
      final data = await sheetsService.readSheet('Donations');
      
      if (data.isEmpty) {
        return Response.ok(
          jsonEncode({'count': 0}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Count donations for this user
      int count = 0;
      for (var row in data.skip(1)) {
        if (row.isNotEmpty) {
          final donationName = row[0].toString().toLowerCase().trim();
          final userFullNameLower = fullName.toLowerCase().trim();
          
          // Match exact or partial (if donation name contains user name)
          if (donationName == userFullNameLower ||
              donationName.startsWith(userFullNameLower) ||
              userFullNameLower.startsWith(donationName)) {
            count++;
          }
        }
      }

      return Response.ok(
        jsonEncode({'count': count}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get donations count', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}

