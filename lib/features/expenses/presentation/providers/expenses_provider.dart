import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/cache_provider.dart';
import '../../../../core/providers/google_sheets_provider.dart';
import '../../data/repositories/expenses_repository_impl.dart';
import '../../domain/entities/expense.dart';
import '../../domain/usecases/get_expenses_usecase.dart';

/// State for expenses.
class ExpensesState {
  final bool isLoading;
  final List<Expense> expenses;
  final String? error;

  const ExpensesState({
    this.isLoading = false,
    this.expenses = const [],
    this.error,
  });

  ExpensesState copyWith({
    bool? isLoading,
    List<Expense>? expenses,
    String? error,
  }) {
    return ExpensesState(
      isLoading: isLoading ?? this.isLoading,
      expenses: expenses ?? this.expenses,
      error: error,
    );
  }

  /// Get total number of expenses.
  int get totalCount => expenses.length;

  /// Get total amount spent.
  double get totalAmount {
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  /// Get expenses grouped by category.
  Map<String, double> get expensesByCategory {
    final categoryTotals = <String, double>{};
    for (final expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    return categoryTotals;
  }

  /// Get top spending category.
  String? get topCategory {
    if (expenses.isEmpty) return null;

    final categoryTotals = expensesByCategory;
    var maxAmount = 0.0;
    String? topCategory;

    categoryTotals.forEach((category, amount) {
      if (amount > maxAmount) {
        maxAmount = amount;
        topCategory = category;
      }
    });

    return topCategory;
  }

  /// Get average expense amount.
  double get averageAmount {
    if (expenses.isEmpty) return 0.0;
    return totalAmount / expenses.length;
  }
}

/// Notifier for expenses state management.
class ExpensesNotifier extends StateNotifier<ExpensesState> {
  final GetExpensesUseCase getExpensesUseCase;

  ExpensesNotifier(this.getExpensesUseCase) : super(const ExpensesState());

  /// Load all expenses.
  Future<void> loadExpenses() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final expenses = await getExpensesUseCase();
      state = state.copyWith(
        isLoading: false,
        expenses: expenses,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh expenses.
  Future<void> refresh() => loadExpenses();
}

/// Provider for expenses repository.
final expensesRepositoryProvider = Provider((ref) {
  final sheetsService = ref.watch(googleSheetsServiceProvider);
  final cacheService = ref.watch(cacheServiceProvider);
  return ExpensesRepositoryImpl(sheetsService, cacheService);
});

/// Provider for get expenses use case.
final getExpensesUseCaseProvider = Provider((ref) {
  final repository = ref.watch(expensesRepositoryProvider);
  return GetExpensesUseCase(repository);
});

/// Provider for expenses notifier.
final expensesProvider =
    StateNotifierProvider<ExpensesNotifier, ExpensesState>((ref) {
  final useCase = ref.watch(getExpensesUseCaseProvider);
  return ExpensesNotifier(useCase);
});
