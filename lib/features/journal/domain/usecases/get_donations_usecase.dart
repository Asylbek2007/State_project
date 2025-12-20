import '../../../donation/domain/entities/donation.dart';
import '../repositories/journal_repository.dart';

/// Use case for fetching all donations.
class GetDonationsUseCase {
  final JournalRepository repository;

  const GetDonationsUseCase(this.repository);

  /// Execute - get all donations sorted by date (newest first).
  /// [forceRefresh] - if true, bypass cache and fetch from server
  Future<List<Donation>> call({bool forceRefresh = false}) async {
    final donations = await repository.getDonations(forceRefresh: forceRefresh);
    
    // Sort by date (newest first)
    donations.sort((a, b) => b.date.compareTo(a.date));
    
    return donations;
  }
}

