import 'package:isar/isar.dart';

import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

/// Local authentication data source using Isar
abstract class LocalAuthDataSource {
  /// Get cached user
  Future<UserModel?> getCachedUser();

  /// Cache user data
  Future<void> cacheUser(UserModel user);

  /// Clear cached user
  Future<void> clearCache();
}

class LocalAuthDataSourceImpl implements LocalAuthDataSource {
  final Isar isar;

  LocalAuthDataSourceImpl({required this.isar});

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final users = await isar.userModels.where().findAll();
      return users.isEmpty ? null : users.first;
    } catch (e) {
      throw CacheException('Failed to get cached user: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await isar.writeTxn(() async {
        // Clear existing users first
        await isar.userModels.clear();
        // Cache new user
        await isar.userModels.put(user);
      });
    } catch (e) {
      throw CacheException('Failed to cache user: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await isar.writeTxn(() async {
        await isar.userModels.clear();
      });
    } catch (e) {
      throw CacheException('Failed to clear cache: ${e.toString()}');
    }
  }
}
