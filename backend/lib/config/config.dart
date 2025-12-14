import 'dart:convert';
import 'dart:io';

/// Application configuration.
class Config {
  static late String jwtSecret;
  static late String spreadsheetId;
  static late Map<String, dynamic> serviceAccountCredentials;
  static late String adminPassword;

  /// Load configuration from environment variables or .env file.
  static Future<void> load() async {
    // Try to load .env file if exists
    final envFile = File('.env');
    Map<String, String> envVars = {};

    if (await envFile.exists()) {
      final lines = await envFile.readAsLines();
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
        final parts = trimmed.split('=');
        if (parts.length >= 2) {
          final key = parts[0].trim();
          final value = parts.sublist(1).join('=').trim();
          envVars[key] = value;
        }
      }
    }

    // Helper to get value from env file or environment
    String? getEnv(String key) => envVars[key] ?? Platform.environment[key];

    // JWT Secret (required)
    jwtSecret =
        getEnv('JWT_SECRET') ?? 'your-secret-key-change-me-in-production';

    // Google Sheets Spreadsheet ID (required)
    spreadsheetId = getEnv('SPREADSHEET_ID') ??
        '1qMwgXatKVAywkdGbTQYpKV6jNzXQhbjwrduajKXlA-o';

    // Admin password (required)
    adminPassword = getEnv('ADMIN_PASSWORD') ?? 'admin2024';

    // Service Account Credentials (required)
    final serviceAccountJson = getEnv('SERVICE_ACCOUNT_JSON');

    if (serviceAccountJson != null) {
      serviceAccountCredentials =
          jsonDecode(serviceAccountJson) as Map<String, dynamic>;
    } else {
      // Try to load from file
      final serviceAccountPath =
          getEnv('SERVICE_ACCOUNT_PATH') ?? 'service_account.json';

      final file = File(serviceAccountPath);
      if (await file.exists()) {
        final content = await file.readAsString();
        serviceAccountCredentials = jsonDecode(content) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Service account credentials not found. '
          'Set SERVICE_ACCOUNT_JSON or SERVICE_ACCOUNT_PATH environment variable.',
        );
      }
    }

    // Validate required config
    if (jwtSecret.isEmpty ||
        jwtSecret == 'your-secret-key-change-me-in-production') {
      print('⚠️  WARNING: Using default JWT secret. Change it in production!');
    }
  }
}
