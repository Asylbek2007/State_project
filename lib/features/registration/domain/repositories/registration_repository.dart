import 'package:donation_app/core/errors/failures.dart';
import '../entities/user.dart';

/// Repository interface for user registration operations.
abstract class RegistrationRepository {
  /// Register a new user by saving their data.
  ///
  /// Returns [User] on success, throws [Failure] on error.
  Future<User> registerUser(String fullName, String surname, String studyGroup);
}

