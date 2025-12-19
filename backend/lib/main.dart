import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:logging/logging.dart';

import 'config/config.dart';
import 'middleware/auth_middleware.dart';
import 'middleware/error_middleware.dart';
import 'routes/auth_routes.dart';
import 'routes/user_routes.dart';
import 'routes/admin_routes.dart';
import 'routes/donation_routes.dart';
import 'routes/goals_routes.dart';
import 'services/google_sheets_service.dart';
import 'services/jwt_service.dart';

final _logger = Logger('DonationBackend');

void main(List<String> args) async {
  // Setup logging
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  _logger.info('Starting Donation Backend Server...');

  // Load configuration
  await Config.load();
  _logger.info('Configuration loaded');

  // Initialize services
  final jwtService = JwtService(Config.jwtSecret);
  final sheetsService = GoogleSheetsService(
    spreadsheetId: Config.spreadsheetId,
    serviceAccountCredentials: Config.serviceAccountCredentials,
  );

  // Initialize Google Sheets
  try {
    await sheetsService.initialize();
    _logger.info('Google Sheets service initialized');
  } catch (e) {
    _logger.severe('Failed to initialize Google Sheets: $e');
    exit(1);
  }

  // Create router
  final router = Router();

  // Auth routes (public)
  final authRoutes = AuthRoutes(jwtService, sheetsService);
  final authRouter = authRoutes.router;
  // ignore: implicit_call_tearoffs
  router.mount('/api/auth', authRouter);

  // User routes (protected)
  final userRoutes = UserRoutes(jwtService, sheetsService);
  final userRouter = userRoutes.router;
  router.mount(
    '/api/user',
    // ignore: implicit_call_tearoffs
    userRouter,
  );

  // Donation routes (protected)
  final donationRoutes = DonationRoutes(jwtService, sheetsService);
  final donationRouter = donationRoutes.router;
  router.mount(
    '/api/donations',
    // ignore: implicit_call_tearoffs
    donationRouter,
  );

  // Goals routes (public read, protected write)
  final goalsRoutes = GoalsRoutes(jwtService, sheetsService);
  final goalsRouter = goalsRoutes.router;
  router.mount(
    '/api/goals',
    // ignore: implicit_call_tearoffs
    goalsRouter,
  );

  // Admin routes (admin only)
  final adminRoutes = AdminRoutes(jwtService, sheetsService);
  final adminRouter = adminRoutes.router;
  router.mount(
    '/api/admin',
    // ignore: implicit_call_tearoffs
    adminRouter,
  );

  // Health check
  router.get('/health', (Request request) {
    return Response.ok(
      jsonEncode({'status': 'ok', 'timestamp': DateTime.now().toIso8601String()}),
      headers: const {'Content-Type': 'application/json'},
    );
  });

  // Create pipeline with middleware
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addMiddleware(errorHandler())
      .addMiddleware(authMiddleware(jwtService))
      .addHandler(router.call);

  // Start server
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await shelf_io.serve(
    handler,
    InternetAddress.anyIPv4,
    port,
  );

  _logger
      .info('Server running on http://${server.address.host}:${server.port}');
}
