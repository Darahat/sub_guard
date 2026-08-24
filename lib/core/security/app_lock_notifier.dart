import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/biometric_service.dart';
import 'app_lock_state.dart';

/// Provider for BiometricService
final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

/// StateNotifier for Biometric App Lock
class AppLockNotifier extends StateNotifier<AppLockState> {
  final BiometricService _biometricService;
  static const int _gracePeriodSeconds = 15;

  AppLockNotifier(this._biometricService) : super(const AppLockState()) {
    initialize();
  }

  /// Initialize lock state from hardware and secure storage
  Future<void> initialize() async {
    final isSupported = await _biometricService.isBiometricsAvailable();
    final biometrics = await _biometricService.getAvailableBiometrics();
    final isEnabled = await _biometricService.isAppLockEnabled();

    state = state.copyWith(
      isDeviceSupported: isSupported,
      availableBiometrics: biometrics,
      isEnabled: isEnabled,
      isLocked: isEnabled, // Lock immediately if enabled on launch
    );

    if (isEnabled) {
      // Auto-prompt on cold start
      await authenticateAndUnlock();
    }
  }

  /// Trigger biometric prompt and unlock if successful
  Future<bool> authenticateAndUnlock() async {
    if (state.isAuthenticating || !state.isEnabled) {
      return false;
    }

    state = state.copyWith(isAuthenticating: true, clearError: true);

    try {
      final success = await _biometricService.authenticate(
        localizedReason: 'Scan your ${state.biometricName} to unlock SubGuard',
      );

      if (success) {
        state = state.copyWith(
          isLocked: false,
          isAuthenticating: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isAuthenticating: false,
          errorMessage: 'Authentication failed. Please try again.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isAuthenticating: false,
        errorMessage: 'An error occurred during authentication.',
      );
      return false;
    }
  }

  /// Toggle Biometric Lock setting in preferences
  Future<bool> toggleAppLock(bool enable) async {
    // Require biometric confirmation before enabling or disabling
    final authenticated = await _biometricService.authenticate(
      localizedReason: enable
          ? 'Authenticate to enable ${state.biometricName} lock'
          : 'Authenticate to disable ${state.biometricName} lock',
    );

    if (!authenticated) {
      return false;
    }

    await _biometricService.setAppLockEnabled(enable);
    state = state.copyWith(
      isEnabled: enable,
      isLocked: false,
    );
    return true;
  }

  /// Called when the app enters background
  Future<void> onAppPaused() async {
    if (state.isEnabled) {
      await _biometricService.recordLastActiveTime();
    }
  }

  /// Called when the app returns to foreground
  Future<void> onAppResumed() async {
    if (!state.isEnabled || state.isLocked) {
      return;
    }

    final lastActive = await _biometricService.getLastActiveTime();
    if (lastActive != null) {
      final elapsedSeconds = DateTime.now().difference(lastActive).inSeconds;
      if (elapsedSeconds >= _gracePeriodSeconds) {
        state = state.copyWith(isLocked: true);
        authenticateAndUnlock();
      }
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Provider for AppLockNotifier
final appLockNotifierProvider =
    StateNotifierProvider<AppLockNotifier, AppLockState>((ref) {
      final service = ref.watch(biometricServiceProvider);
      return AppLockNotifier(service);
    });
