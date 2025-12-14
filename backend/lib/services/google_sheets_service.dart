import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';

/// Service for interacting with Google Sheets API.
class GoogleSheetsService {
  final String spreadsheetId;
  final Map<String, dynamic> serviceAccountCredentials;

  sheets.SheetsApi? _sheetsApi;
  AutoRefreshingAuthClient? _client;

  GoogleSheetsService({
    required this.spreadsheetId,
    required this.serviceAccountCredentials,
  });

  /// Initialize Google Sheets API.
  Future<void> initialize() async {
    try {
      final accountCredentials =
          ServiceAccountCredentials.fromJson(serviceAccountCredentials);
      _client = await clientViaServiceAccount(
        accountCredentials,
        [sheets.SheetsApi.spreadsheetsScope],
      );
      _sheetsApi = sheets.SheetsApi(_client!);
    } catch (e) {
      throw Exception('Failed to initialize Google Sheets: $e');
    }
  }

  /// Append a row to a sheet.
  Future<void> appendRow(String sheetName, List<dynamic> values) async {
    if (_sheetsApi == null) {
      throw Exception('Google Sheets API not initialized');
    }

    try {
      final valueRange = sheets.ValueRange.fromJson({
        'values': [values],
      });

      await _sheetsApi!.spreadsheets.values.append(
        valueRange,
        spreadsheetId,
        '$sheetName!A:A',
        valueInputOption: 'USER_ENTERED',
        insertDataOption: 'INSERT_ROWS',
      );
    } catch (e) {
      throw Exception('Failed to append row: $e');
    }
  }

  /// Read data from a sheet.
  Future<List<List<dynamic>>> readSheet(String sheetName,
      {String? range}) async {
    if (_sheetsApi == null) {
      throw Exception('Google Sheets API not initialized');
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
      throw Exception('Failed to read sheet: $e');
    }
  }

  /// Update a row in a sheet.
  Future<void> updateRow(
    String sheetName,
    int rowIndex,
    List<dynamic> values,
  ) async {
    if (_sheetsApi == null) {
      throw Exception('Google Sheets API not initialized');
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
      throw Exception('Failed to update row: $e');
    }
  }

  /// Delete a row from a sheet.
  Future<void> deleteRow(String sheetName, int rowIndex) async {
    if (_sheetsApi == null) {
      throw Exception('Google Sheets API not initialized');
    }

    try {
      final spreadsheet = await _sheetsApi!.spreadsheets.get(spreadsheetId);
      final sheetsList = spreadsheet.sheets;
      if (sheetsList == null || sheetsList.isEmpty) {
        throw Exception('No sheets found in spreadsheet');
      }

      final sheet = sheetsList.firstWhere(
        (s) => s.properties?.title == sheetName,
        orElse: () => throw Exception('Sheet "$sheetName" not found'),
      );

      final sheetId = sheet.properties?.sheetId;
      if (sheetId == null) {
        throw Exception('Could not find sheet ID');
      }

      await _sheetsApi!.spreadsheets.batchUpdate(
        sheets.BatchUpdateSpreadsheetRequest.fromJson({
          'requests': [
            {
              'deleteDimension': {
                'range': {
                  'sheetId': sheetId,
                  'dimension': 'ROWS',
                  'startIndex': rowIndex - 1,
                  'endIndex': rowIndex,
                },
              },
            },
          ],
        }),
        spreadsheetId,
      );
    } catch (e) {
      throw Exception('Failed to delete row: $e');
    }
  }

  /// Find row index by value in a column.
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

  /// Calculate sum of a column.
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
}
