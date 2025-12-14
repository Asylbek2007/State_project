import '../../../donation/domain/entities/donation.dart';
import '../repositories/journal_repository.dart';

/// Use case for fetching all donations.
class GetDonationsUseCase {
  final JournalRepository repository;

  const GetDonationsUseCase(this.repository);

  /// Execute - get all donations sorted by date (newest first).
  Future<List<Donation>> call() async {
    final donations = await repository.getDonations();
    
    // Sort by date (newest first)
    donations.sort((a, b) => b.date.compareTo(a.date));
    
    return donations;
  }
}

