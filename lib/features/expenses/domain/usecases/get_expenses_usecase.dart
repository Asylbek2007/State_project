import '../entities/expense.dart';
import '../repositories/expenses_repository.dart';

/// Use case for fetching all expenses.
class GetExpensesUseCase {
  final ExpensesRepository repository;

  const GetExpensesUseCase(this.repository);

  /// Execute - get all expenses sorted by date (newest first).
  Future<List<Expense>> call() async {
    final expenses = await repository.getExpenses();
    
    // Sort by date (newest first)
    expenses.sort((a, b) => b.date.compareTo(a.date));
    
    return expenses;
  }
}
