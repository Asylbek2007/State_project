import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:donation_app/core/providers/google_sheets_provider.dart';
import 'package:donation_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:donation_app/features/auth/domain/usecases/login_user_usecase.dart';
import 'package:donation_app/features/registration/domain/entities/user.dart';

/// State for authentication.
class AuthState {
  final bool isLoading;
  final User? user;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    User? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
    );
  }
}

/// Provider for authentication state.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final sheetsService = ref.watch(googleSheetsServiceProvider);
  final repository = AuthRepositoryImpl(sheetsService);
  final useCase = LoginUserUseCase(repository);
  return AuthNotifier(useCase);
});

/// Notifier for authentication operations.
class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUserUseCase loginUseCase;

  AuthNotifier(this.loginUseCase) : super(const AuthState());

  /// Login user with credentials.
  Future<void> loginUser(
    String fullName,
    String surname,
    String studyGroup,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await loginUseCase(fullName, surname, studyGroup);
      state = state.copyWith(
        isLoading: false,
        user: user,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Reset state.
  void reset() {
    state = const AuthState();
  }
}

