import 'package:donation_app/core/errors/failures.dart';
import 'package:donation_app/core/services/cache_service.dart';
import 'package:donation_app/core/services/google_sheets_service.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expenses_repository.dart';
import '../models/expense_model.dart';

/// Implementation of [ExpensesRepository] using Google Sheets with caching.
class ExpensesRepositoryImpl implements ExpensesRepository {
  final GoogleSheetsService sheetsService;
  final CacheService cacheService;

  ExpensesRepositoryImpl(
    this.sheetsService, [
    CacheService? cacheService,
  ]) : cacheService = cacheService ?? CacheService();

  @override
  Future<List<Expense>> getExpenses() async {
    const cacheKey = 'expenses_list';
    
    // Try to get from cache first
    final cachedExpenses = cacheService.get<List<Expense>>(cacheKey);
    if (cachedExpenses != null) {
      return cachedExpenses;
    }

    try {
      // Read from "Expenses" sheet
      final data = await sheetsService.readSheet('Expenses');

      if (data.isEmpty) {
        return [];
      }

      // Skip header row (index 0), parse data rows
      final expenses = <Expense>[];
      for (int i = 1; i < data.length; i++) {
        try {
          final expense = ExpenseModel.fromSheetRow(data[i]);
          expenses.add(expense);
        } catch (e) {
          // Skip invalid rows
          print('Warning: Skipped invalid expense row at index $i: $e');
        }
      }

      // Cache the results
      cacheService.set(cacheKey, expenses);

      return expenses;
    } on SheetsFailure {
      rethrow;
    } catch (e) {
      throw SheetsFailure('Ошибка загрузки расходов: ${e.toString()}');
    }
  }
  
  /// Invalidate cache for expenses.
  /// Call this when expenses are updated.
  void invalidateCache() {
    cacheService.remove('expenses_list');
  }
}
