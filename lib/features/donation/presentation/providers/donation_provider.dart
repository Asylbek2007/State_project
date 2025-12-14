import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/cache_provider.dart';
import '../../../../core/providers/google_sheets_provider.dart';
import '../../data/repositories/donation_repository_impl.dart';
import '../../domain/entities/donation.dart';
import '../../domain/usecases/make_donation_usecase.dart';

/// State for donation process.
class DonationState {
  final bool isLoading;
  final Donation? donation;
  final String? error;

  const DonationState({
    this.isLoading = false,
    this.donation,
    this.error,
  });

  DonationState copyWith({
    bool? isLoading,
    Donation? donation,
    String? error,
  }) {
    return DonationState(
      isLoading: isLoading ?? this.isLoading,
      donation: donation ?? this.donation,
      error: error,
    );
  }
}

/// Notifier for donation state management.
class DonationNotifier extends StateNotifier<DonationState> {
  final MakeDonationUseCase makeDonationUseCase;

  DonationNotifier(this.makeDonationUseCase) : super(const DonationState());

  /// Make a donation.
  Future<void> makeDonation({
    required String fullName,
    required String studyGroup,
    required double amount,
    required String message,
    String? goalName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final donation = await makeDonationUseCase(
        fullName: fullName,
        studyGroup: studyGroup,
        amount: amount,
        message: message,
        goalName: goalName,
      );
      
      state = state.copyWith(isLoading: false, donation: donation);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Reset state (e.g., for making another donation).
  void reset() {
    state = const DonationState();
  }
}

/// Provider for donation repository.
final donationRepositoryProvider = Provider((ref) {
  final sheetsService = ref.watch(googleSheetsServiceProvider);
  final cacheService = ref.watch(cacheServiceProvider);
  return DonationRepositoryImpl(sheetsService, cacheService);
});

/// Provider for make donation use case.
final makeDonationUseCaseProvider = Provider((ref) {
  final repository = ref.watch(donationRepositoryProvider);
  return MakeDonationUseCase(repository);
});

/// Provider for donation notifier.
final donationProvider =
    StateNotifierProvider<DonationNotifier, DonationState>((ref) {
  final useCase = ref.watch(makeDonationUseCaseProvider);
  return DonationNotifier(useCase);
});

