import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/jwt_service.dart';
import '../services/google_sheets_service.dart';

/// Donation routes.
class DonationRoutes {
  final JwtService jwtService;
  final GoogleSheetsService sheetsService;
  final Router _router = Router();

  DonationRoutes(this.jwtService, this.sheetsService) {
    _setupRoutes();
  }

  void _setupRoutes() {
    // Create donation (protected)
    _router.post('/create', _createDonation);

    // Get all donations (public read)
    _router.get('/list', _getDonations);
  }

  Router get router => _router;

  /// Create a new donation.
  Future<Response> _createDonation(Request request) async {
    try {
      // Get user from context (set by auth middleware)
      final user = request.context['user'] as Map<String, dynamic>?;
      if (user == null) {
        return Response(
          401,
          body: jsonEncode({'error': 'Authentication required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final amount = (body['amount'] as num?)?.toDouble();
      final message = body['message'] as String? ?? '';

      // Validation
      if (amount == null || amount <= 0) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Amount must be greater than 0'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (amount > 1000000) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Amount cannot exceed 1,000,000'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Save to Google Sheets
      final now = DateTime.now().toIso8601String();
      final userName = user['userName'] as String;
      final surname = user['surname'] as String? ?? '';
      final userGroup = user['userGroup'] as String;
      final fullName = '$userName $surname'.trim();

      await sheetsService.appendRow(
        'Donations',
        [fullName, userGroup, amount, now, message],
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'donation': {
            'fullName': fullName,
            'studyGroup': userGroup,
            'amount': amount,
            'date': now,
            'message': message,
          },
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to create donation', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// Get all donations.
  Future<Response> _getDonations(Request request) async {
    try {
      final data = await sheetsService.readSheet('Donations');
      
      if (data.isEmpty) {
        return Response.ok(
          jsonEncode({'donations': []}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Skip header row
      final donations = data.skip(1).map((row) {
        return {
          'fullName': row.isNotEmpty ? row[0].toString() : '',
          'studyGroup': row.length > 1 ? row[1].toString() : '',
          'amount': row.length > 2 ? (double.tryParse(row[2].toString()) ?? 0.0) : 0.0,
          'date': row.length > 3 ? row[3].toString() : '',
          'message': row.length > 4 ? row[4].toString() : '',
        };
      }).toList();

      // Sort by date (newest first)
      donations.sort((a, b) {
        final dateA = DateTime.tryParse(a['date'] as String) ?? DateTime(1970);
        final dateB = DateTime.tryParse(b['date'] as String) ?? DateTime(1970);
        return dateB.compareTo(dateA);
      });

      return Response.ok(
        jsonEncode({'donations': donations}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to fetch donations', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}

