import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/jwt_service.dart';
import '../services/google_sheets_service.dart';

/// Admin routes (admin only).
class AdminRoutes {
  final JwtService jwtService;
  final GoogleSheetsService sheetsService;
  final Router _router = Router();

  AdminRoutes(this.jwtService, this.sheetsService) {
    _setupRoutes();
  }

  void _setupRoutes() {
    // Create goal
    _router.post('/goals/create', _createGoal);

    // Update goal
    _router.put('/goals/update', _updateGoal);

    // Delete goal
    _router.delete('/goals/delete', _deleteGoal);

    // Delete donation
    _router.delete('/donations/delete', _deleteDonation);

    // Delete user
    _router.delete('/users/delete', _deleteUser);
  }

  Router get router => _router;

  /// Create a new goal.
  Future<Response> _createGoal(Request request) async {
    try {
      final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final name = body['name'] as String?;
      final targetAmount = (body['targetAmount'] as num?)?.toDouble();
      final deadline = body['deadline'] as String?;
      final description = body['description'] as String?;

      // Validation
      if (name == null || name.trim().isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Goal name is required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (targetAmount == null || targetAmount <= 0) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Target amount must be greater than 0'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (deadline == null || deadline.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Deadline is required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (description == null || description.trim().isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Description is required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Save to Google Sheets
      await sheetsService.appendRow(
        'Goals',
        [name.trim(), targetAmount, 0.0, deadline, description.trim()],
      );

      return Response.ok(
        jsonEncode({'success': true}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to create goal', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// Update an existing goal.
  Future<Response> _updateGoal(Request request) async {
    try {
      final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final originalName = body['originalName'] as String?;
      final name = body['name'] as String?;
      final targetAmount = (body['targetAmount'] as num?)?.toDouble();
      final currentAmount = (body['currentAmount'] as num?)?.toDouble();
      final deadline = body['deadline'] as String?;
      final description = body['description'] as String?;

      if (originalName == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Original goal name is required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Find goal row
      final rowIndex = await sheetsService.findRowIndex('Goals', 0, originalName);
      if (rowIndex == -1) {
        return Response(
          404,
          body: jsonEncode({'error': 'Goal not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Update row
      await sheetsService.updateRow(
        'Goals',
        rowIndex,
        [
          name ?? originalName,
          targetAmount ?? 0.0,
          currentAmount ?? 0.0,
          deadline ?? '',
          description ?? '',
        ],
      );

      return Response.ok(
        jsonEncode({'success': true}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to update goal', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// Delete a goal.
  Future<Response> _deleteGoal(Request request) async {
    try {
      final uri = request.url;
      final goalName = uri.queryParameters['goalName'];

      if (goalName == null || goalName.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Goal name is required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Find goal row
      final rowIndex = await sheetsService.findRowIndex('Goals', 0, goalName);
      if (rowIndex == -1) {
        return Response(
          404,
          body: jsonEncode({'error': 'Goal not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Delete row
      await sheetsService.deleteRow('Goals', rowIndex);

      return Response.ok(
        jsonEncode({'success': true}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to delete goal', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// Delete a donation.
  Future<Response> _deleteDonation(Request request) async {
    try {
      final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final fullName = body['fullName'] as String?;
      final date = body['date'] as String?;

      if (fullName == null || date == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Full name and date are required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Find donation row by name and date
      final data = await sheetsService.readSheet('Donations');
      int rowIndex = -1;

      for (int i = 1; i < data.length; i++) {
        if (data[i].length >= 4 &&
            data[i][0].toString() == fullName &&
            data[i][3].toString() == date) {
          rowIndex = i + 1; // Convert to 1-based
          break;
        }
      }

      if (rowIndex == -1) {
        return Response(
          404,
          body: jsonEncode({'error': 'Donation not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Delete row
      await sheetsService.deleteRow('Donations', rowIndex);

      return Response.ok(
        jsonEncode({'success': true}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to delete donation', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// Delete a user.
  Future<Response> _deleteUser(Request request) async {
    try {
      final uri = request.url;
      final fullName = uri.queryParameters['fullName'];

      if (fullName == null || fullName.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Full name is required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Find user row
      final rowIndex = await sheetsService.findRowIndex('Users', 0, fullName);
      if (rowIndex == -1) {
        return Response(
          404,
          body: jsonEncode({'error': 'User not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Delete row
      await sheetsService.deleteRow('Users', rowIndex);

      return Response.ok(
        jsonEncode({'success': true}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to delete user', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}

