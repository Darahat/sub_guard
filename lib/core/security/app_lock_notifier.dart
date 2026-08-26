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
  DateTime? _lastPausedTime;

  AppLockNotifier(this._biometricService, {bool autoInit = true})
      : super(const AppLockState()) {
    if (autoInit) {
      initialize();
    }
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
        // Reset pause timers and record fresh active time so resume doesn't re-lock
        _lastPausedTime = null;
        await _biometricService.recordLastActiveTime();

        state = state.copyWith(isLocked: false, isAuthenticating: false);
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
    state = state.copyWith(isAuthenticating: true);
    // Require biometric confirmation before enabling or disabling
    final authenticated = await _biometricService.authenticate(
      localizedReason: enable
          ? 'Authenticate to enable ${state.biometricName} lock'
          : 'Authenticate to disable ${state.biometricName} lock',
    );

    state = state.copyWith(isAuthenticating: false);

    if (!authenticated) {
      return false;
    }

    await _biometricService.setAppLockEnabled(enable);
    _lastPausedTime = null;
    await _biometricService.recordLastActiveTime();

    state = state.copyWith(isEnabled: enable, isLocked: false);
    return true;
  }

  /// Called when the app enters background
  Future<void> onAppPaused() async {
    // Ignore pause events triggered by the biometric prompt dialog itself
    if (!state.isEnabled || state.isAuthenticating) {
      return;
    }
    _lastPausedTime = DateTime.now();
    await _biometricService.recordLastActiveTime();
  }

  /// Called when the app returns to foreground
  Future<void> onAppResumed() async {
    // Ignore resume events if disabled, currently authenticating, or already locked
    if (!state.isEnabled || state.isAuthenticating || state.isLocked) {
      return;
    }

    final pauseTime = _lastPausedTime;
    if (pauseTime != null) {
      final elapsedSeconds = DateTime.now().difference(pauseTime).inSeconds;
      if (elapsedSeconds >= _gracePeriodSeconds) {
        _lastPausedTime = null;
        state = state.copyWith(isLocked: true);
        authenticateAndUnlock();
      }
    } else {
      // Check stored timestamp as fallback
      final lastActive = await _biometricService.getLastActiveTime();
      if (lastActive != null) {
        final elapsedSeconds = DateTime.now().difference(lastActive).inSeconds;
        if (elapsedSeconds >= _gracePeriodSeconds) {
          state = state.copyWith(isLocked: true);
          authenticateAndUnlock();
        }
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
