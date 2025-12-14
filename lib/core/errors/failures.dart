/// Base class for all failures in the application.
abstract class Failure {
  final String message;

  const Failure(this.message);

  @override
  String toString() => message;
}

/// Failure related to server communication.
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Failure related to network connectivity.
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Failure related to data parsing or validation.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Failure related to Google Sheets operations.
class SheetsFailure extends Failure {
  const SheetsFailure(super.message);
}

/// Failure related to authentication (login).
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

