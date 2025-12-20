import 'package:donation_app/core/errors/failures.dart';
import 'package:donation_app/features/registration/domain/entities/user.dart';

/// Repository interface for authentication operations.
abstract class AuthRepository {
  /// Login user with email and password.
  ///
  /// Returns [User] if credentials match.
  /// Throws [Failure] if login fails.
  Future<User> loginUser(
    String email,
    String password,
  );
}

