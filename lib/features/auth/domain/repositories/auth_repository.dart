import 'package:donation_app/core/errors/failures.dart';
import 'package:donation_app/features/registration/domain/entities/user.dart';

/// Repository interface for authentication operations.
abstract class AuthRepository {
  /// Login user by checking credentials in Google Sheets.
  ///
  /// Returns [User] if credentials match.
  /// Throws [Failure] if login fails.
  Future<User> loginUser(
    String fullName,
    String surname,
    String studyGroup,
  );
}

