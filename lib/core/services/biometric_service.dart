import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import '../utils/logger.dart';

/// Service for managing device biometric hardware and secure lock settings
class BiometricService {
  final LocalAuthentication _localAuth;
  final FlutterSecureStorage _secureStorage;

  static const String _appLockKey = 'subguard_biometric_app_lock_enabled';
  static const String _lastActiveKey = 'subguard_last_active_timestamp';

  BiometricService({
    LocalAuthentication? localAuth,
    FlutterSecureStorage? secureStorage,
  })  : _localAuth = localAuth ?? LocalAuthentication(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Check if the device hardware supports biometrics and has enrolled credentials
  Future<bool> isBiometricsAvailable() async {
    try {
      final canAuthenticateWithBiometrics =
          await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canAuthenticateWithBiometrics || isDeviceSupported;
    } on PlatformException catch (e) {
      logger.error('Error checking biometrics availability: ${e.message}');
      return false;
    }
  }

  /// Get list of available biometric sensors (fingerprint, face, iris)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      logger.error('Error fetching available biometrics: ${e.message}');
      return [];
    }
  }

  /// Trigger native OS biometric authentication prompt
  Future<bool> authenticate({
    String localizedReason = 'Authenticate to access SubGuard',
  }) async {
    try {
      final isAvailable = await isBiometricsAvailable();
      if (!isAvailable) {
        logger.warning('Biometrics not available on this device.');
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allows device PIN/Passcode fallback
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (e) {
      logger.error('Authentication error: ${e.message} (code: ${e.code})');
      return false;
    } catch (e) {
      logger.error('Unexpected biometric error: $e');
      return false;
    }
  }

  /// Check if the user has enabled Biometric App Lock in SubGuard settings
  Future<bool> isAppLockEnabled() async {
    try {
      final value = await _secureStorage.read(key: _appLockKey);
      return value == 'true';
    } catch (e) {
      logger.error('Error reading app lock setting: $e');
      return false;
    }
  }

  /// Enable or disable Biometric App Lock
  Future<void> setAppLockEnabled(bool enabled) async {
    try {
      await _secureStorage.write(
        key: _appLockKey,
        value: enabled ? 'true' : 'false',
      );
    } catch (e) {
      logger.error('Error saving app lock setting: $e');
      rethrow;
    }
  }

  /// Save timestamp when the app was last active (used for grace period)
  Future<void> recordLastActiveTime() async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch.toString();
      await _secureStorage.write(key: _lastActiveKey, value: now);
    } catch (_) {}
  }

  /// Get timestamp when the app was last active
  Future<DateTime?> getLastActiveTime() async {
    try {
      final val = await _secureStorage.read(key: _lastActiveKey);
      if (val != null) {
        final millis = int.tryParse(val);
        if (millis != null) {
          return DateTime.fromMillisecondsSinceEpoch(millis);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
