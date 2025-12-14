import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/cache_provider.dart';
import '../../../../core/providers/google_sheets_provider.dart';
import '../../data/repositories/goals_repository_impl.dart';
import '../../domain/entities/goal.dart';
import '../../domain/usecases/get_goals_usecase.dart';
import '../../domain/usecases/get_total_collected_usecase.dart';

/// State for goals and total amount.
class GoalsState {
  final bool isLoading;
  final List<Goal> goals;
  final double totalCollected;
  final String? error;

  const GoalsState({
    this.isLoading = false,
    this.goals = const [],
    this.totalCollected = 0.0,
    this.error,
  });

  GoalsState copyWith({
    bool? isLoading,
    List<Goal>? goals,
    double? totalCollected,
    String? error,
  }) {
    return GoalsState(
      isLoading: isLoading ?? this.isLoading,
      goals: goals ?? this.goals,
      totalCollected: totalCollected ?? this.totalCollected,
      error: error,
    );
  }
}

/// Notifier for goals state management.
class GoalsNotifier extends StateNotifier<GoalsState> {
  final GetGoalsUseCase getGoalsUseCase;
  final GetTotalCollectedUseCase getTotalCollectedUseCase;

  GoalsNotifier({
    required this.getGoalsUseCase,
    required this.getTotalCollectedUseCase,
  }) : super(const GoalsState());

  /// Load goals and total collected amount.
  Future<void> loadGoals() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Load goals and total in parallel
      final results = await Future.wait([
        getGoalsUseCase(),
        getTotalCollectedUseCase(),
      ]);

      final goals = results[0] as List<Goal>;
      final total = results[1] as double;

      state = state.copyWith(
        isLoading: false,
        goals: goals,
        totalCollected: total,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh data (pull-to-refresh).
  Future<void> refresh() => loadGoals();
}

/// Provider for goals repository.
final goalsRepositoryProvider = Provider((ref) {
  final sheetsService = ref.watch(googleSheetsServiceProvider);
  final cacheService = ref.watch(cacheServiceProvider);
  return GoalsRepositoryImpl(sheetsService, cacheService);
});

/// Provider for get goals use case.
final getGoalsUseCaseProvider = Provider((ref) {
  final repository = ref.watch(goalsRepositoryProvider);
  return GetGoalsUseCase(repository);
});

/// Provider for get total collected use case.
final getTotalCollectedUseCaseProvider = Provider((ref) {
  final repository = ref.watch(goalsRepositoryProvider);
  return GetTotalCollectedUseCase(repository);
});

/// Provider for goals notifier.
final goalsProvider = StateNotifierProvider<GoalsNotifier, GoalsState>((ref) {
  final getGoalsUseCase = ref.watch(getGoalsUseCaseProvider);
  final getTotalUseCase = ref.watch(getTotalCollectedUseCaseProvider);
  
  return GoalsNotifier(
    getGoalsUseCase: getGoalsUseCase,
    getTotalCollectedUseCase: getTotalUseCase,
  );
});

