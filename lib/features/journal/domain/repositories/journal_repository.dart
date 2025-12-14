import '../../../donation/domain/entities/donation.dart';

/// Repository interface for journal (donations history) operations.
abstract class JournalRepository {
  /// Get all donations from history.
  Future<List<Donation>> getDonations();
}

