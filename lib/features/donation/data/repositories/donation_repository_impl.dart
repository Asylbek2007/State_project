import 'package:donation_app/core/errors/failures.dart';
import 'package:donation_app/core/services/cache_service.dart';
import 'package:donation_app/core/services/google_sheets_service.dart';
import '../../domain/entities/donation.dart';
import '../../domain/repositories/donation_repository.dart';
import '../models/donation_model.dart';

/// Implementation of [DonationRepository] using Google Sheets with cache invalidation.
class DonationRepositoryImpl implements DonationRepository {
  final GoogleSheetsService sheetsService;
  final CacheService cacheService;

  DonationRepositoryImpl(
    this.sheetsService, [
    CacheService? cacheService,
  ]) : cacheService = cacheService ?? CacheService();

  @override
  Future<Donation> makeDonation({
    required String fullName,
    required String studyGroup,
    required double amount,
    required String message,
    String? goalName,
    String? transactionId,
  }) async {
    try {
      final now = DateTime.now();
      final donationModel = DonationModel(
        fullName: fullName,
        studyGroup: studyGroup,
        amount: amount,
        date: now,
        message: message,
        goalName: goalName,
        transactionId: transactionId,
        paymentStatus: transactionId != null && transactionId.isNotEmpty
            ? PaymentStatus.pending
            : null,
      );

      // Append to "Donations" sheet
      // Sheet structure: Full Name | Study Group | Amount | Date | Message | Goal Name
      await sheetsService.appendRow(
        'Donations',
        donationModel.toSheetRow(),
      );

      // If donation is for a specific goal, update the goal's currentAmount
      if (goalName != null && goalName.trim().isNotEmpty) {
        await _updateGoalCurrentAmount(goalName.trim(), amount);
      }

      // Invalidate cache for goals and donations
      cacheService.remove('goals_list');
      cacheService.remove('total_collected');
      cacheService.remove('donations_list');

      return donationModel;
    } on SheetsFailure {
      rethrow;
    } catch (e) {
      throw SheetsFailure('Ошибка при сохранении пожертвования: ${e.toString()}');
    }
  }

  /// Update goal's currentAmount by adding the donation amount.
  Future<void> _updateGoalCurrentAmount(String goalName, double donationAmount) async {
    try {
      // Find the goal row by name
      final rowIndex = await sheetsService.findRowIndex(
        'Goals',
        0, // Column 0 = Goal Name
        goalName,
      );

      if (rowIndex == -1) {
        // Goal not found, skip update (donation will still be saved)
        print('Warning: Goal "$goalName" not found, skipping currentAmount update');
        return;
      }

      // Read current goal data
      final goalsData = await sheetsService.readSheet('Goals');
      if (rowIndex > goalsData.length - 1) {
        print('Warning: Goal row index out of bounds');
        return;
      }

      final goalRow = goalsData[rowIndex];
      if (goalRow.length < 3) {
        print('Warning: Invalid goal row format');
        return;
      }

      // Parse current amount
      final currentAmount = _parseDouble(goalRow[2]); // Column 2 = Current Amount
      final newCurrentAmount = currentAmount + donationAmount;

      // Update the goal row with new currentAmount
      // Goals sheet structure: Name | Target Amount | Current Amount | Deadline | Description
      final updatedData = [
        goalRow[0], // Name
        goalRow[1], // Target Amount
        newCurrentAmount, // Updated Current Amount
        goalRow.length > 3 ? goalRow[3] : '', // Deadline
        goalRow.length > 4 ? goalRow[4] : '', // Description
      ];

      await sheetsService.updateRow('Goals', rowIndex, updatedData);
    } catch (e) {
      // Don't fail the donation if goal update fails
      print('Warning: Failed to update goal currentAmount: $e');
    }
  }

  /// Helper to parse double from dynamic value.
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}

