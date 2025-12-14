import 'package:donation_app/core/errors/failures.dart';
import 'package:donation_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:donation_app/features/registration/domain/entities/user.dart';

/// Use case for user login.
class LoginUserUseCase {
  final AuthRepository repository;

  const LoginUserUseCase(this.repository);

  /// Execute login with user credentials.
  ///
  /// Returns [User] if login successful.
  /// Throws [Failure] if login fails.
  Future<User> call(
    String fullName,
    String surname,
    String studyGroup,
  ) async {
    // Validation
    if (fullName.trim().isEmpty) {
      throw const ValidationFailure('Имя не может быть пустым');
    }

    if (surname.trim().isEmpty) {
      throw const ValidationFailure('Фамилия не может быть пустой');
    }

    if (studyGroup.trim().isEmpty) {
      throw const ValidationFailure('Группа не может быть пустой');
    }

    return await repository.loginUser(
      fullName.trim(),
      surname.trim(),
      studyGroup.trim(),
    );
  }
}

