import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/google_sheets_service.dart';

/// Centralized provider for Google Sheets service (singleton).
/// 
/// This provider should be used across all features instead of creating
/// duplicate providers in individual feature modules.
final googleSheetsServiceProvider = Provider<GoogleSheetsService>((ref) {
  return GoogleSheetsService();
});

