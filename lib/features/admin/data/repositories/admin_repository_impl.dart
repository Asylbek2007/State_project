import 'package:donation_app/core/errors/failures.dart';
import 'package:donation_app/core/services/google_sheets_service.dart';
import 'package:donation_app/core/services/cache_service.dart';
import '../../domain/repositories/admin_repository.dart';

/// Implementation of [AdminRepository] using Google Sheets.
class AdminRepositoryImpl implements AdminRepository {
  final GoogleSheetsService sheetsService;
  final CacheService cacheService;

  AdminRepositoryImpl(this.sheetsService, [CacheService? cacheService])
      : cacheService = cacheService ?? CacheService();

  @override
  Future<void> createGoal({
    required String name,
    required double targetAmount,
    required DateTime deadline,
    required String description,
  }) async {
    try {
      final goalData = [
        name,
        targetAmount,
        0.0, // Current amount starts at 0
        deadline.toIso8601String(),
        description,
      ];

      await sheetsService.appendRow('Goals', goalData);
      
      // Invalidate cache to force refresh for all users
      cacheService.remove('goals_list');
      cacheService.remove('total_collected');
    } on SheetsFailure {
      rethrow;
    } catch (e) {
      throw SheetsFailure('Ошибка создания цели: ${e.toString()}');
    }
  }

  @override
  Future<void> updateGoal({
    required String originalName,
    required String name,
    required double targetAmount,
    required double currentAmount,
    required DateTime deadline,
    required String description,
  }) async {
    try {
      // Find the row index by original goal name
      final rowIndex = await sheetsService.findRowIndex(
        'Goals',
        0, // Column 0 = Goal Name
        originalName,
      );

      if (rowIndex == -1) {
        throw SheetsFailure('Цель "$originalName" не найдена в таблице');
      }

      // Prepare updated data
      final updatedData = [
        name,
        targetAmount,
        currentAmount,
        deadline.toIso8601String(),
        description,
      ];

      // Update the row
      await sheetsService.updateRow('Goals', rowIndex, updatedData);
      
      // Invalidate cache to force refresh for all users
      cacheService.remove('goals_list');
      cacheService.remove('total_collected');
    } on SheetsFailure {
      rethrow;
    } catch (e) {
      throw SheetsFailure('Ошибка обновления цели: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteGoal(String goalName) async {
    try {
      // Find the row index by goal name
      final rowIndex = await sheetsService.findRowIndex(
        'Goals',
        0, // Column 0 = Goal Name
        goalName,
      );

      if (rowIndex == -1) {
        throw SheetsFailure('Цель "$goalName" не найдена в таблице');
      }

      // Delete the row
      await sheetsService.deleteRow('Goals', rowIndex);
      
      // Invalidate cache to force refresh for all users
      cacheService.remove('goals_list');
      cacheService.remove('total_collected');
    } on SheetsFailure {
      rethrow;
    } catch (e) {
      throw SheetsFailure('Ошибка удаления цели: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteDonation({
    required String fullName,
    required DateTime date,
  }) async {
    try {
      // Find row by name and date (to handle duplicates)
      final dateStr = date.toIso8601String();
      final rowIndex = await sheetsService.findRowIndexByCriteria(
        'Donations',
        {
          0: fullName, // Column 0 = Full Name
          3: dateStr, // Column 3 = Date
        },
      );

      if (rowIndex == -1) {
        throw const SheetsFailure('Пожертвование не найдено в таблице');
      }

      await sheetsService.deleteRow('Donations', rowIndex);
      
      // Invalidate cache to force refresh (donations affect goals and total)
      cacheService.remove('donations_list');
      cacheService.remove('goals_list');
      cacheService.remove('total_collected');
    } on SheetsFailure {
      rethrow;
    } catch (e) {
      throw SheetsFailure('Ошибка удаления пожертвования: ${e.toString()}');
    }
  }

  @override
  Future<void> updateDonationPaymentStatus({
    required String fullName,
    required DateTime date,
    required String status,
  }) async {
    try {
      // Find row by name and date
      final dateStr = date.toIso8601String();
      final rowIndex = await sheetsService.findRowIndexByCriteria(
        'Donations',
        {
          0: fullName, // Column 0 = Full Name
          3: dateStr, // Column 3 = Date
        },
      );

      if (rowIndex == -1) {
        throw const SheetsFailure('Пожертвование не найдено в таблице');
      }

      // Read current row data
      final data = await sheetsService.readSheet('Donations');
      if (rowIndex >= data.length) {
        throw const SheetsFailure('Индекс строки вне диапазона');
      }

      final currentRow = data[rowIndex];
      
      // Update payment status (column 7)
      // Structure: [Full Name, Study Group, Amount, Date, Message, Goal Name, Transaction ID, Payment Status]
      final updatedData = List<dynamic>.from(currentRow);
      
      // Ensure we have enough columns
      while (updatedData.length < 8) {
        updatedData.add('');
      }
      
      updatedData[7] = status; // Payment Status

      await sheetsService.updateRow('Donations', rowIndex, updatedData);
      
      // Invalidate cache to force refresh
      cacheService.remove('donations_list');
      cacheService.remove('goals_list');
      cacheService.remove('total_collected');
    } on SheetsFailure {
      rethrow;
    } catch (e) {
      throw SheetsFailure('Ошибка обновления статуса: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteUser(String fullName) async {
    try {
      // Find row by fullName
      final rowIndex = await sheetsService.findRowIndex(
        'Users',
        0, // Column 0 = Full Name
        fullName,
      );

      if (rowIndex == -1) {
        throw SheetsFailure('Пользователь "$fullName" не найден в таблице');
      }

      await sheetsService.deleteRow('Users', rowIndex);
    } on SheetsFailure {
      rethrow;
    } catch (e) {
      throw SheetsFailure('Ошибка удаления пользователя: ${e.toString()}');
    }
  }
}

