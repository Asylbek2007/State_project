import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/google_sheets_provider.dart';
import '../../data/repositories/registration_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/register_user_usecase.dart';

/// State for registration process.
class RegistrationState {
  final bool isLoading;
  final User? user;
  final String? error;

  const RegistrationState({
    this.isLoading = false,
    this.user,
    this.error,
  });

  RegistrationState copyWith({
    bool? isLoading,
    User? user,
    String? error,
  }) {
    return RegistrationState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
    );
  }
}

/// Notifier for registration state management.
class RegistrationNotifier extends StateNotifier<RegistrationState> {
  final RegisterUserUseCase registerUserUseCase;

  RegistrationNotifier(this.registerUserUseCase)
      : super(const RegistrationState());

  /// Register a new user with validation.
  Future<void> registerUser(String email, String password, String fullName, String surname, String studyGroup) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await registerUserUseCase(email, password, fullName, surname, studyGroup);
      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Reset state (e.g., for retry).
  void reset() {
    state = const RegistrationState();
  }
}

// Note: googleSheetsServiceProvider is now in lib/core/providers/google_sheets_provider.dart
// Import it from there instead of defining it here.

/// Provider for registration repository.
final registrationRepositoryProvider = Provider((ref) {
  final sheetsService = ref.watch(googleSheetsServiceProvider);
  return RegistrationRepositoryImpl(sheetsService);
});

/// Provider for register user use case.
final registerUserUseCaseProvider = Provider((ref) {
  final repository = ref.watch(registrationRepositoryProvider);
  return RegisterUserUseCase(repository);
});

/// Provider for registration notifier.
final registrationProvider =
    StateNotifierProvider<RegistrationNotifier, RegistrationState>((ref) {
  final useCase = ref.watch(registerUserUseCaseProvider);
  return RegistrationNotifier(useCase);
});

