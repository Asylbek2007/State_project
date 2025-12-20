import '../../../donation/domain/entities/donation.dart';

/// Repository interface for journal (donations history) operations.
abstract class JournalRepository {
  /// Get all donations from history.
  /// [forceRefresh] - if true, bypass cache and fetch from server
  Future<List<Donation>> getDonations({bool forceRefresh = false});
}

