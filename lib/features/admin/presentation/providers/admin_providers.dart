import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/google_sheets_provider.dart';
import '../../../../core/providers/cache_provider.dart';
import '../../data/repositories/admin_repository_impl.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../domain/usecases/create_goal_usecase.dart';
import '../../domain/usecases/update_goal_usecase.dart';
import '../../domain/usecases/delete_goal_usecase.dart';
import '../../domain/usecases/delete_donation_usecase.dart';
import '../../domain/usecases/delete_user_usecase.dart';
import '../../domain/usecases/update_donation_status_usecase.dart';

/// Provider for admin repository.
final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final sheetsService = ref.watch(googleSheetsServiceProvider);
  final cacheService = ref.watch(cacheServiceProvider);
  return AdminRepositoryImpl(sheetsService, cacheService);
});

/// Provider for create goal use case.
final createGoalUseCaseProvider = Provider<CreateGoalUseCase>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return CreateGoalUseCase(repository);
});

/// Provider for update goal use case.
final updateGoalUseCaseProvider = Provider<UpdateGoalUseCase>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return UpdateGoalUseCase(repository);
});

/// Provider for delete goal use case.
final deleteGoalUseCaseProvider = Provider<DeleteGoalUseCase>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return DeleteGoalUseCase(repository);
});

/// Provider for delete donation use case.
final deleteDonationUseCaseProvider = Provider<DeleteDonationUseCase>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return DeleteDonationUseCase(repository);
});

/// Provider for delete user use case.
final deleteUserUseCaseProvider = Provider<DeleteUserUseCase>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return DeleteUserUseCase(repository);
});

/// Provider for update donation status use case.
final updateDonationStatusUseCaseProvider = Provider((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return UpdateDonationStatusUseCase(repository);
});

