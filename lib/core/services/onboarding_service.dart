import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../utils/logger.dart';

/// Service to track whether the user has completed the onboarding flow
class OnboardingService {
  final FlutterSecureStorage _storage;
  static const String _onboardingKey = 'subguard_has_completed_onboarding';

  OnboardingService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// Check if the user has already seen and completed onboarding
  Future<bool> hasCompletedOnboarding() async {
    try {
      final value = await _storage.read(key: _onboardingKey);
      return value == 'true';
    } catch (e) {
      logger.error('Error reading onboarding status: $e');
      return false;
    }
  }

  /// Mark onboarding as completed
  Future<void> setOnboardingCompleted() async {
    try {
      await _storage.write(key: _onboardingKey, value: 'true');
    } catch (e) {
      logger.error('Error saving onboarding status: $e');
    }
  }

  /// Reset onboarding status (useful for replaying tour from settings)
  Future<void> resetOnboarding() async {
    try {
      await _storage.delete(key: _onboardingKey);
    } catch (e) {
      logger.error('Error resetting onboarding status: $e');
    }
  }
}

/// Provider for OnboardingService
final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  return OnboardingService();
});
