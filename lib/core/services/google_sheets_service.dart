import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';
import '../errors/failures.dart';

/// Service for interacting with Google Sheets API.
///
/// Handles all read/write operations to the donation Google Sheet.
class GoogleSheetsService {
  static const _scopes = [sheets.SheetsApi.spreadsheetsScope];

  // Spreadsheet ID from: https://docs.google.com/spreadsheets/d/1qMwgXatKVAywkdGbTQYpKV6jNzXQhbjwrduajKXlA-o/
  static const String spreadsheetId =
      '1qMwgXatKVAywkdGbTQYpKV6jNzXQhbjwrduajKXlA-o';

  sheets.SheetsApi? _sheetsApi;
  AutoRefreshingAuthClient? _client;

  /// Initialize the Google Sheets API with service account credentials.
  ///
  /// [credentials] should be the JSON content from your service account key file.
  Future<void> initialize(Map<String, dynamic> credentials) async {
    try {
      final accountCredentials =
          ServiceAccountCredentials.fromJson(credentials);
      _client = await clientViaServiceAccount(accountCredentials, _scopes);
      _sheetsApi = sheets.SheetsApi(_client!);
    } catch (e) {
      throw SheetsFailure(
          'Failed to initialize Google Sheets: ${e.toString()}');
    }
  }

  /// Append a row to a specific sheet.
  ///
  /// [sheetName] - Name of the sheet tab (e.g., "Users", "Donations")
  /// [values] - List of values to append as a new row
  Future<void> appendRow(String sheetName, List<dynamic> values) async {
    if (_sheetsApi == null) {
      throw const SheetsFailure('Google Sheets API not initialized');
    }

    try {
      final valueRange = sheets.ValueRange.fromJson({
        'values': [values],
      });

      // For append operation, use sheet name with A1 notation
      // Try different formats based on Google Sheets API requirements
      String range;
      
      // First try: Use column range format
      try {
        range = '$sheetName!A:A';
        await _sheetsApi!.spreadsheets.values.append(
          valueRange,
          spreadsheetId,
          range,
          valueInputOption: 'USER_ENTERED',
          insertDataOption: 'INSERT_ROWS',
        );
      } catch (e) {
        // Fallback: Try with just sheet name (API will use first column)
        range = sheetName;
        await _sheetsApi!.spreadsheets.values.append(
          valueRange,
          spreadsheetId,
          range,
          valueInputOption: 'USER_ENTERED',
          insertDataOption: 'INSERT_ROWS',
        );
      }
    } catch (e) {
      final errorMessage = e.toString();
      // Provide more helpful error message
      if (errorMessage.contains('Unable to parse range') || 
          errorMessage.contains('Unable to parse')) {
        throw SheetsFailure(
          'Ошибка: Лист "$sheetName" не найден в Google Sheets. '
          'Пожалуйста, создайте лист с названием "$sheetName" в вашей таблице.',
        );
      }
      throw SheetsFailure('Failed to append row: $errorMessage');
    }
  }

  /// Read all data from a specific sheet.
  ///
  /// [sheetName] - Name of the sheet tab
  /// [range] - Optional range in A1 notation (e.g., "A1:D100")
  /// Returns list of rows, where each row is a list of cell values
  Future<List<List<dynamic>>> readSheet(
    String sheetName, {
    String? range,
  }) async {
    if (_sheetsApi == null) {
      throw const SheetsFailure('Google Sheets API not initialized');
    }

    try {
      final rangeNotation = range ?? '$sheetName!A:Z';
      final response = await _sheetsApi!.spreadsheets.values.get(
        spreadsheetId,
        rangeNotation,
      );

      if (response.values == null || response.values!.isEmpty) {
        return [];
      }

      return response.values!.map((row) => row.toList()).toList();
    } catch (e) {
      throw SheetsFailure('Failed to read sheet: ${e.toString()}');
    }
  }

  /// Calculate total from a numeric column.
  ///
  /// [sheetName] - Name of the sheet tab
  /// [columnIndex] - Zero-based column index
  /// [startRow] - Row to start from (1-based, typically 2 to skip header)
  Future<double> calculateColumnSum(
    String sheetName,
    int columnIndex, {
    int startRow = 2,
  }) async {
    final data = await readSheet(sheetName);

    if (data.isEmpty || data.length < startRow) {
      return 0.0;
    }

    double sum = 0.0;
    for (int i = startRow - 1; i < data.length; i++) {
      if (data[i].length > columnIndex) {
        final value = data[i][columnIndex];
        if (value != null) {
          final parsed = double.tryParse(value.toString());
          if (parsed != null) {
            sum += parsed;
          }
        }
      }
    }

    return sum;
  }

  /// Update a specific row in a sheet.
  ///
  /// [sheetName] - Name of the sheet tab
  /// [rowIndex] - 1-based row index (1 = header, 2 = first data row)
  /// [values] - List of values to update (will update columns starting from A)
  Future<void> updateRow(
    String sheetName,
    int rowIndex,
    List<dynamic> values,
  ) async {
    if (_sheetsApi == null) {
      throw const SheetsFailure('Google Sheets API not initialized');
    }

    try {
      final valueRange = sheets.ValueRange.fromJson({
        'values': [values],
      });

      await _sheetsApi!.spreadsheets.values.update(
        valueRange,
        spreadsheetId,
        '$sheetName!A$rowIndex',
        valueInputOption: 'USER_ENTERED',
      );
    } catch (e) {
      throw SheetsFailure('Failed to update row: ${e.toString()}');
    }
  }

  /// Delete a specific row from a sheet.
  ///
  /// [sheetName] - Name of the sheet tab
  /// [rowIndex] - 1-based row index to delete
  Future<void> deleteRow(String sheetName, int rowIndex) async {
    if (_sheetsApi == null) {
      throw const SheetsFailure('Google Sheets API not initialized');
    }

    try {
      // First, get the sheet ID
      final spreadsheet = await _sheetsApi!.spreadsheets.get(spreadsheetId);
      final sheetsList = spreadsheet.sheets;
      if (sheetsList == null || sheetsList.isEmpty) {
        throw const SheetsFailure('No sheets found in spreadsheet');
      }

      final sheet = sheetsList.firstWhere(
        (s) => s.properties?.title == sheetName,
        orElse: () => throw SheetsFailure('Sheet "$sheetName" not found'),
      );

      final sheetId = sheet.properties?.sheetId;
      if (sheetId == null) {
        throw const SheetsFailure('Could not find sheet ID');
      }

      // Delete the row using batchUpdate
      await _sheetsApi!.spreadsheets.batchUpdate(
        sheets.BatchUpdateSpreadsheetRequest.fromJson({
          'requests': [
            {
              'deleteDimension': {
                'range': {
                  'sheetId': sheetId,
                  'dimension': 'ROWS',
                  'startIndex': rowIndex - 1, // 0-based
                  'endIndex': rowIndex, // 0-based, exclusive
                },
              },
            },
          ],
        }),
        spreadsheetId,
      );
    } catch (e) {
      throw SheetsFailure('Failed to delete row: ${e.toString()}');
    }
  }

  /// Find row index by matching value in a specific column.
  ///
  /// [sheetName] - Name of the sheet tab
  /// [columnIndex] - Zero-based column index to search in
  /// [searchValue] - Value to search for
  /// Returns 1-based row index, or -1 if not found
  Future<int> findRowIndex(
    String sheetName,
    int columnIndex,
    String searchValue,
  ) async {
    final data = await readSheet(sheetName);

    for (int i = 0; i < data.length; i++) {
      if (data[i].length > columnIndex &&
          data[i][columnIndex].toString() == searchValue) {
        return i + 1; // Convert to 1-based
      }
    }

    return -1; // Not found
  }

  /// Find row index by matching multiple criteria.
  ///
  /// [sheetName] - Name of the sheet tab
  /// [criteria] - Map of column index -> expected value
  /// Returns 1-based row index, or -1 if not found
  Future<int> findRowIndexByCriteria(
    String sheetName,
    Map<int, String> criteria,
  ) async {
    final data = await readSheet(sheetName);

    for (int i = 0; i < data.length; i++) {
      bool matches = true;
      for (final entry in criteria.entries) {
        final columnIndex = entry.key;
        final expectedValue = entry.value;

        if (data[i].length <= columnIndex ||
            data[i][columnIndex].toString() != expectedValue) {
          matches = false;
          break;
        }
      }

      if (matches) {
        return i + 1; // Convert to 1-based
      }
    }

    return -1; // Not found
  }

  /// Dispose resources.
  void dispose() {
    _client?.close();
  }
}
