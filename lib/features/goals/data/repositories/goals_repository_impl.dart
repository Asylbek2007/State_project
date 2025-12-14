import 'package:donation_app/core/errors/failures.dart';
import 'package:donation_app/core/services/cache_service.dart';
import 'package:donation_app/core/services/google_sheets_service.dart';
import '../../domain/entities/goal.dart';
import '../../domain/repositories/goals_repository.dart';
import '../models/goal_model.dart';

/// Implementation of [GoalsRepository] using Google Sheets with caching.
class GoalsRepositoryImpl implements GoalsRepository {
  final GoogleSheetsService sheetsService;
  final CacheService cacheService;

  GoalsRepositoryImpl(
    this.sheetsService, [
    CacheService? cacheService,
  ]) : cacheService = cacheService ?? CacheService();

  @override
  Future<List<Goal>> getGoals() async {
    const cacheKey = 'goals_list';
    
    // Try to get from cache first
    final cachedGoals = cacheService.get<List<Goal>>(cacheKey);
    if (cachedGoals != null) {
      return cachedGoals;
    }

    try {
      // Read from "Goals" sheet
      final goalsData = await sheetsService.readSheet('Goals');

      if (goalsData.isEmpty) {
        return [];
      }

      // Read donations to calculate current amounts dynamically
      final donationsData = await sheetsService.readSheet('Donations');
      
      // Calculate total donations per goal
      final donationsByGoal = <String, double>{};
      if (donationsData.length > 1) {
        // Skip header row (index 0)
        for (int i = 1; i < donationsData.length; i++) {
          try {
            final row = donationsData[i];
            if (row.length > 2) {
              final amount = _parseDouble(row[2]); // Column 2 = Amount
              final goalName = row.length > 5 && row[5] != null && row[5].toString().isNotEmpty
                  ? row[5].toString().trim()
                  : null; // Column 5 = Goal Name
              
              if (goalName != null && goalName.isNotEmpty) {
                donationsByGoal[goalName] = (donationsByGoal[goalName] ?? 0.0) + amount;
              }
            }
          } catch (e) {
            // Skip invalid donation rows
            print('Warning: Skipped invalid donation row at index $i: $e');
          }
        }
      }

      // Parse goals and update currentAmount from donations
      final goals = <Goal>[];
      for (int i = 1; i < goalsData.length; i++) {
        try {
          final goal = GoalModel.fromSheetRow(goalsData[i]);
          
          // Update currentAmount from actual donations
          final actualCurrentAmount = donationsByGoal[goal.name] ?? 0.0;
          
          // Create goal with recalculated currentAmount
          final updatedGoal = Goal(
            name: goal.name,
            targetAmount: goal.targetAmount,
            currentAmount: actualCurrentAmount, // Use calculated amount
            deadline: goal.deadline,
            description: goal.description,
          );
          
          goals.add(updatedGoal);
        } catch (e) {
          // Skip invalid rows
          print('Warning: Skipped invalid goal row at index $i: $e');
        }
      }

      // Cache the results
      cacheService.set(cacheKey, goals);

      return goals;
    } on SheetsFailure {
      rethrow;
    } catch (e) {
      throw SheetsFailure('Ошибка загрузки целей: ${e.toString()}');
    }
  }

  /// Helper to parse double from dynamic value.
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  @override
  Future<double> getTotalCollected() async {
    const cacheKey = 'total_collected';
    
    // Try to get from cache first
    final cachedTotal = cacheService.get<double>(cacheKey);
    if (cachedTotal != null) {
      return cachedTotal;
    }

    try {
      // Calculate sum of "Amount" column (index 2) from "Donations" sheet
      // Starting from row 2 (index 1 is header, index 2 is first data row)
      final total = await sheetsService.calculateColumnSum(
        'Donations',
        2, // Column index for "Amount" (0=Full Name, 1=Study Group, 2=Amount)
        startRow: 2,
      );

      // Cache the result
      cacheService.set(cacheKey, total);

      return total;
    } on SheetsFailure {
      rethrow;
    } catch (e) {
      throw SheetsFailure('Ошибка подсчета общей суммы: ${e.toString()}');
    }
  }
  
  /// Invalidate cache for goals-related data.
  /// Call this when goals or donations are updated.
  void invalidateCache() {
    cacheService.remove('goals_list');
    cacheService.remove('total_collected');
  }
}

