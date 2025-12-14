import 'package:shelf/shelf.dart';
import 'dart:convert';

/// Middleware for error handling.
Middleware errorHandler() {
  return (innerHandler) {
    return (Request request) async {
      try {
        final response = await innerHandler(request);
        return response;
      } catch (e, stackTrace) {
        print('Error: $e');
        print('Stack trace: $stackTrace');

        return Response.internalServerError(
          body: jsonEncode({
            'error': 'Internal server error',
            'message': e.toString(),
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }
    };
  };
}

