import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/cache_service.dart';

/// Provider for CacheService singleton.
final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService(defaultTTL: const Duration(minutes: 5));
});

