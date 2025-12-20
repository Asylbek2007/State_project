/// Repository interface for admin operations.
abstract class AdminRepository {
  /// Create a new fundraising goal.
  Future<void> createGoal({
    required String name,
    required double targetAmount,
    required DateTime deadline,
    required String description,
  });

  /// Update an existing goal.
  Future<void> updateGoal({
    required String originalName,
    required String name,
    required double targetAmount,
    required double currentAmount,
    required DateTime deadline,
    required String description,
  });

  /// Delete a goal by name.
  Future<void> deleteGoal(String goalName);

  /// Delete a donation by finding it first.
  /// Uses fullName and date to locate the donation.
  Future<void> deleteDonation({
    required String fullName,
    required DateTime date,
  });

  /// Delete a user by finding it first.
  /// Uses fullName to locate the user.
  Future<void> deleteUser(String fullName);

  /// Update donation payment status.
  /// Uses fullName and date to locate the donation.
  Future<void> updateDonationPaymentStatus({
    required String fullName,
    required DateTime date,
    required String status, // 'pending', 'confirmed', 'rejected'
  });
}

