import '../entities/goal.dart';

/// Repository interface for goals operations.
abstract class GoalsRepository {
  /// Get all fundraising goals.
  Future<List<Goal>> getGoals();

  /// Get total amount collected across all donations.
  Future<double> getTotalCollected();
}

