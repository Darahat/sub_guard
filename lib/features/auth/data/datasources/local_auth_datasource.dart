import 'dart:convert';
import 'package:hive_ce/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

/// Local authentication data source using Hive
abstract class LocalAuthDataSource {
  /// Get cached user
  Future<UserModel?> getCachedUser();

  /// Cache user data
  Future<void> cacheUser(UserModel user);

  /// Clear cached user
  Future<void> clearCache();
}

class LocalAuthDataSourceImpl implements LocalAuthDataSource {
  final Box<String> box;

  LocalAuthDataSourceImpl({required this.box});

  static const String _cachedUserKey = 'current_cached_user';

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final jsonStr = box.get(_cachedUserKey);
      if (jsonStr == null) {
        // Fallback check if any user is stored
        if (box.isNotEmpty) {
          final first = box.values.first;
          return UserModel.fromJson(json.decode(first) as Map<String, dynamic>);
        }
        return null;
      }
      return UserModel.fromJson(json.decode(jsonStr) as Map<String, dynamic>);
    } catch (e) {
      throw CacheException('Failed to get cached user: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await box.put(_cachedUserKey, json.encode(user.toJson()));
      await box.put(user.uid, json.encode(user.toJson()));
    } catch (e) {
      throw CacheException('Failed to cache user: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await box.clear();
    } catch (e) {
      throw CacheException('Failed to clear cache: ${e.toString()}');
    }
  }
}
