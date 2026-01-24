import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../utils/logger.dart';

class SecureStorageService {
  static final SecureStorageService _instance =
      SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // Save data
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
      logger.debug('Secure storage: Written key: $key');
    } catch (e) {
      logger.error('Secure storage write error', e);
      rethrow;
    }
  }

  // Read data
  Future<String?> read(String key) async {
    try {
      final value = await _storage.read(key: key);
      logger.debug('Secure storage: Read key: $key');
      return value;
    } catch (e) {
      logger.error('Secure storage read error', e);
      return null;
    }
  }

  // Delete data
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
      logger.debug('Secure storage: Deleted key: $key');
    } catch (e) {
      logger.error('Secure storage delete error', e);
      rethrow;
    }
  }

  // Delete all data
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
      logger.debug('Secure storage: Deleted all keys');
    } catch (e) {
      logger.error('Secure storage delete all error', e);
      rethrow;
    }
  }

  // Check if key exists
  Future<bool> containsKey(String key) async {
    try {
      final value = await _storage.read(key: key);
      return value != null;
    } catch (e) {
      logger.error('Secure storage contains key error', e);
      return false;
    }
  }

  // Get all keys
  Future<Map<String, String>> readAll() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      logger.error('Secure storage read all error', e);
      return {};
    }
  }
}

// Global instance
final secureStorage = SecureStorageService();
