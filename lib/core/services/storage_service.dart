import '../database/hive_service.dart';
import '../utils/logger.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  /// Initialize database
  Future<void> init() async {
    try {
      await hiveService.init();
    } catch (e) {
      logger.error('Failed to initialize database', e);
      rethrow;
    }
  }

  /// Close database
  Future<void> close() async {
    await hiveService.close();
  }

  /// Clear all data
  Future<void> clearAll() async {
    try {
      await hiveService.clearAll();
      logger.info('All local data cleared');
    } catch (e) {
      logger.error('Failed to clear data', e);
      rethrow;
    }
  }
}

// Global instance
final storage = StorageService();
