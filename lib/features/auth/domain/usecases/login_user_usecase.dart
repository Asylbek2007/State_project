import 'package:donation_app/core/errors/failures.dart';
import 'package:donation_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:donation_app/features/registration/domain/entities/user.dart';

/// Use case for user login.
class LoginUserUseCase {
  final AuthRepository repository;

  const LoginUserUseCase(this.repository);

  /// Execute login with email and password.
  ///
  /// Returns [User] if login successful.
  /// Throws [Failure] if login fails.
  Future<User> call(
    String email,
    String password,
  ) async {
    // Validation
    if (email.trim().isEmpty) {
      throw const ValidationFailure('Email не может быть пустым');
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email.trim())) {
      throw const ValidationFailure('Некорректный формат email');
    }

    if (password.isEmpty) {
      throw const ValidationFailure('Пароль не может быть пустым');
    }

    if (password.length < 6) {
      throw const ValidationFailure('Пароль должен содержать минимум 6 символов');
    }

    return await repository.loginUser(
      email.trim().toLowerCase(),
      password,
    );
  }
}

