import '../entities/donation.dart';

/// Repository interface for donation operations.
abstract class DonationRepository {
  /// Make a donation.
  ///
  /// Saves donation to storage and returns created Donation entity.
  Future<Donation> makeDonation({
    required String fullName,
    required String studyGroup,
    required double amount,
    required String message,
    String? goalName,
    String? transactionId,
  });
}
