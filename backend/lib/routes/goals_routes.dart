import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/jwt_service.dart';
import '../services/google_sheets_service.dart';

/// Goals routes.
class GoalsRoutes {
  final JwtService jwtService;
  final GoogleSheetsService sheetsService;
  final Router _router = Router();

  GoalsRoutes(this.jwtService, this.sheetsService) {
    _setupRoutes();
  }

  void _setupRoutes() {
    // Get all goals (public)
    _router.get('/list', _getGoals);

    // Get total collected (public)
    _router.get('/total', _getTotalCollected);
  }

  Router get router => _router;

  /// Get all goals.
  Future<Response> _getGoals(Request request) async {
    try {
      final data = await sheetsService.readSheet('Goals');
      
      if (data.isEmpty) {
        return Response.ok(
          jsonEncode({'goals': []}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Skip header row
      final goals = data.skip(1).map((row) {
        return {
          'name': row.isNotEmpty ? row[0].toString() : '',
          'targetAmount': row.length > 1 ? (double.tryParse(row[1].toString()) ?? 0.0) : 0.0,
          'currentAmount': row.length > 2 ? (double.tryParse(row[2].toString()) ?? 0.0) : 0.0,
          'deadline': row.length > 3 ? row[3].toString() : '',
          'description': row.length > 4 ? row[4].toString() : '',
        };
      }).toList();

      return Response.ok(
        jsonEncode({'goals': goals}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to fetch goals', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// Get total collected amount.
  Future<Response> _getTotalCollected(Request request) async {
    try {
      // Calculate sum of Amount column (index 2) from Donations sheet
      final total = await sheetsService.calculateColumnSum('Donations', 2, startRow: 2);

      return Response.ok(
        jsonEncode({'total': total}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to calculate total', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}

