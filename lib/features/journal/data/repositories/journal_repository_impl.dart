import 'package:donation_app/core/errors/failures.dart';
import 'package:donation_app/core/services/cache_service.dart';
import 'package:donation_app/core/services/google_sheets_service.dart';
import '../../../donation/data/models/donation_model.dart';
import '../../../donation/domain/entities/donation.dart';
import '../../domain/repositories/journal_repository.dart';

/// Implementation of [JournalRepository] using Google Sheets with caching.
class JournalRepositoryImpl implements JournalRepository {
  final GoogleSheetsService sheetsService;
  final CacheService cacheService;

  JournalRepositoryImpl(
    this.sheetsService, [
    CacheService? cacheService,
  ]) : cacheService = cacheService ?? CacheService();

  @override
  Future<List<Donation>> getDonations() async {
    const cacheKey = 'donations_list';
    
    // Try to get from cache first
    final cachedDonations = cacheService.get<List<Donation>>(cacheKey);
    if (cachedDonations != null) {
      return cachedDonations;
    }

    try {
      // Read from "Donations" sheet
      final data = await sheetsService.readSheet('Donations');

      if (data.isEmpty) {
        return [];
      }

      // Skip header row (index 0), parse data rows
      final donations = <Donation>[];
      for (int i = 1; i < data.length; i++) {
        try {
          final donation = DonationModel.fromSheetRow(data[i]);
          donations.add(donation);
        } catch (e) {
          // Skip invalid rows
          print('Warning: Skipped invalid donation row at index $i: $e');
        }
      }

      // Cache the results
      cacheService.set(cacheKey, donations);

      return donations;
    } on SheetsFailure {
      rethrow;
    } catch (e) {
      throw SheetsFailure('Ошибка загрузки журнала: ${e.toString()}');
    }
  }
}

