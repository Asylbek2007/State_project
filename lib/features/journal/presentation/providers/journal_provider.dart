import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../donation/domain/entities/donation.dart';
import '../../../../core/providers/cache_provider.dart';
import '../../../../core/providers/google_sheets_provider.dart';
import '../../data/repositories/journal_repository_impl.dart';
import '../../domain/usecases/get_donations_usecase.dart';

/// State for journal.
class JournalState {
  final bool isLoading;
  final List<Donation> donations;
  final String? error;

  const JournalState({
    this.isLoading = false,
    this.donations = const [],
    this.error,
  });

  JournalState copyWith({
    bool? isLoading,
    List<Donation>? donations,
    String? error,
  }) {
    return JournalState(
      isLoading: isLoading ?? this.isLoading,
      donations: donations ?? this.donations,
      error: error,
    );
  }

  /// Get total number of donations.
  int get totalCount => donations.length;

  /// Get total amount donated.
  double get totalAmount {
    return donations.fold(0.0, (sum, donation) => sum + donation.amount);
  }

  /// Get top donor (by total amount).
  String? get topDonor {
    if (donations.isEmpty) return null;

    final donorTotals = <String, double>{};
    for (final donation in donations) {
      donorTotals[donation.fullName] =
          (donorTotals[donation.fullName] ?? 0) + donation.amount;
    }

    var maxAmount = 0.0;
    String? topDonor;
    donorTotals.forEach((name, amount) {
      if (amount > maxAmount) {
        maxAmount = amount;
        topDonor = name;
      }
    });

    return topDonor;
  }

  /// Get average donation amount.
  double get averageAmount {
    if (donations.isEmpty) return 0.0;
    return totalAmount / donations.length;
  }
}

/// Notifier for journal state management.
class JournalNotifier extends StateNotifier<JournalState> {
  final GetDonationsUseCase getDonationsUseCase;

  JournalNotifier(this.getDonationsUseCase) : super(const JournalState());

  /// Load all donations.
  Future<void> loadDonations() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final donations = await getDonationsUseCase();
      state = state.copyWith(
        isLoading: false,
        donations: donations,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh donations.
  Future<void> refresh() => loadDonations();
}

/// Provider for journal repository.
final journalRepositoryProvider = Provider((ref) {
  final sheetsService = ref.watch(googleSheetsServiceProvider);
  final cacheService = ref.watch(cacheServiceProvider);
  return JournalRepositoryImpl(sheetsService, cacheService);
});

/// Provider for get donations use case.
final getDonationsUseCaseProvider = Provider((ref) {
  final repository = ref.watch(journalRepositoryProvider);
  return GetDonationsUseCase(repository);
});

/// Provider for journal notifier.
final journalProvider =
    StateNotifierProvider<JournalNotifier, JournalState>((ref) {
  final useCase = ref.watch(getDonationsUseCaseProvider);
  return JournalNotifier(useCase);
});

