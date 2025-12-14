import 'dart:convert';

/// Service for caching data with TTL (Time To Live).
///
/// Stores data in memory with expiration timestamps.
/// Automatically invalidates expired entries.
class CacheService {
  static const Duration defaultTTL = Duration(minutes: 5);

  final Map<String, _CacheEntry> _cache = {};
  final Duration defaultCacheTTL;

  CacheService({Duration? defaultTTL})
      : defaultCacheTTL = defaultTTL ?? CacheService.defaultTTL;

  /// Get cached value by key.
  ///
  /// Returns `null` if key doesn't exist or entry is expired.
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    // Check if expired
    if (entry.expiresAt.isBefore(DateTime.now())) {
      _cache.remove(key);
      return null;
    }

    // For primitive types, return as-is
    if (entry.value is T) {
      return entry.value as T;
    }

    // For String values that might be JSON
    if (entry.value is String) {
      try {
        final decoded = jsonDecode(entry.value as String);
        // If decoded is a List, try to cast it
        if (decoded is List && T.toString().contains('List')) {
          return decoded as T;
        }
        return decoded as T;
      } catch (e) {
        // If not JSON, return as String if T is String
        if (T == String) {
          return entry.value as T;
        }
        return null;
      }
    }

    // For Map/List, try direct cast
    try {
      return entry.value as T;
    } catch (e) {
      // If deserialization fails, remove entry
      _cache.remove(key);
      return null;
    }
  }

  /// Store value in cache with optional TTL.
  ///
  /// If [ttl] is not provided, uses [defaultCacheTTL].
  void set<T>(String key, T value, {Duration? ttl}) {
    final expiresAt = DateTime.now().add(ttl ?? defaultCacheTTL);

    // Serialize if needed
    dynamic serializedValue = value;
    
    // For primitive types, store as-is
    if (value is String || value is num || value is bool || value == null) {
      serializedValue = value;
    } else if (value is List || value is Map) {
      // For Lists and Maps, try JSON encoding
      try {
        serializedValue = jsonEncode(value);
      } catch (e) {
        // If serialization fails, store as-is (for objects with toJson)
        serializedValue = value;
      }
    } else {
      // For custom objects, try to convert to JSON if they have toJson
      try {
        // Try JSON encoding for custom objects
        serializedValue = jsonEncode(value);
      } catch (e) {
        // If serialization fails, store as-is (objects will be handled by repository layer)
        serializedValue = value;
      }
    }

    _cache[key] = _CacheEntry(
      value: serializedValue,
      expiresAt: expiresAt,
    );
  }

  /// Check if key exists and is not expired.
  bool contains(String key) {
    final entry = _cache[key];
    if (entry == null) return false;

    if (entry.expiresAt.isBefore(DateTime.now())) {
      _cache.remove(key);
      return false;
    }

    return true;
  }

  /// Remove entry from cache.
  void remove(String key) {
    _cache.remove(key);
  }

  /// Remove all entries matching a prefix.
  ///
  /// Useful for invalidating related cache entries.
  void removeByPrefix(String prefix) {
    _cache.removeWhere((key, _) => key.startsWith(prefix));
  }

  /// Clear all cache entries.
  void clear() {
    _cache.clear();
  }

  /// Get cache statistics.
  CacheStats getStats() {
    final now = DateTime.now();
    int valid = 0;
    int expired = 0;

    for (final entry in _cache.values) {
      if (entry.expiresAt.isBefore(now)) {
        expired++;
      } else {
        valid++;
      }
    }

    return CacheStats(
      totalEntries: _cache.length,
      validEntries: valid,
      expiredEntries: expired,
    );
  }

  /// Clean up expired entries.
  ///
  /// Call this periodically to free memory.
  void cleanup() {
    final now = DateTime.now();
    _cache.removeWhere((_, entry) => entry.expiresAt.isBefore(now));
  }
}

/// Internal cache entry with expiration timestamp.
class _CacheEntry {
  final dynamic value;
  final DateTime expiresAt;

  _CacheEntry({
    required this.value,
    required this.expiresAt,
  });
}

/// Cache statistics.
class CacheStats {
  final int totalEntries;
  final int validEntries;
  final int expiredEntries;

  CacheStats({
    required this.totalEntries,
    required this.validEntries,
    required this.expiredEntries,
  });

  @override
  String toString() =>
      'CacheStats(total: $totalEntries, valid: $validEntries, expired: $expiredEntries)';
}


