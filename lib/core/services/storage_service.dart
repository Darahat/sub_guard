import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/logger.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  Isar? _isar;

  // Initialize Isar database
  Future<void> init(List<CollectionSchema> schemas) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      _isar = await Isar.open(
        schemas,
        directory: dir.path,
        name: 'subguard_db',
      );
      logger.info('Isar database initialized');
    } catch (e) {
      logger.error('Failed to initialize Isar database', e);
      rethrow;
    }
  }

  // Get Isar instance
  Isar get isar {
    if (_isar == null) {
      throw Exception('Isar not initialized. Call init() first.');
    }
    return _isar!;
  }

  // Close database
  Future<void> close() async {
    await _isar?.close();
    _isar = null;
    logger.info('Isar database closed');
  }

  // Clear all data
  Future<void> clearAll() async {
    try {
      await isar.writeTxn(() async {
        await isar.clear();
      });
      logger.info('All Isar data cleared');
    } catch (e) {
      logger.error('Failed to clear Isar data', e);
      rethrow;
    }
  }
}

// Global instance
final storage = StorageService();
