import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';
import 'core/config/credentials.dart' as credentials;
import 'core/services/google_sheets_service.dart';
import 'core/providers/google_sheets_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize locale data for DateFormat (Russian)
  try {
    await initializeDateFormatting('ru', null);
    print('✓ Locale data initialized successfully');
  } catch (e) {
    print('✗ Failed to initialize locale data: $e');
  }

  // Initialize Google Sheets service
  final googleSheetsService = GoogleSheetsService();

  try {
    // Load credentials from separate file (not tracked by git)
    const serviceAccountCredentials = credentials.serviceAccountCredentials;
    await googleSheetsService.initialize(serviceAccountCredentials);
    print('✓ Google Sheets API initialized successfully');
  } catch (e) {
    print('✗ Failed to initialize Google Sheets API: $e');
    print(
        '⚠️ Make sure lib/core/config/credentials.dart exists with valid credentials');
    // In production, show error dialog or fallback UI
  }

  // Create provider container with overrides
  final container = ProviderContainer(
    overrides: [
      googleSheetsServiceProvider.overrideWithValue(googleSheetsService),
    ],
  );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const DonationApp(),
    ),
  );
}
