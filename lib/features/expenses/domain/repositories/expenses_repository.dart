import '../entities/expense.dart';

/// Repository interface for expenses operations.
abstract class ExpensesRepository {
  /// Get all expenses.
  Future<List<Expense>> getExpenses();
}
