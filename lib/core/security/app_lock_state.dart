import 'package:local_auth/local_auth.dart';

/// State representing Biometric App Lock
class AppLockState {
  final bool isEnabled;
  final bool isLocked;
  final bool isAuthenticating;
  final bool isDeviceSupported;
  final List<BiometricType> availableBiometrics;
  final String? errorMessage;

  const AppLockState({
    this.isEnabled = false,
    this.isLocked = false,
    this.isAuthenticating = false,
    this.isDeviceSupported = false,
    this.availableBiometrics = const [],
    this.errorMessage,
  });

  AppLockState copyWith({
    bool? isEnabled,
    bool? isLocked,
    bool? isAuthenticating,
    bool? isDeviceSupported,
    List<BiometricType>? availableBiometrics,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AppLockState(
      isEnabled: isEnabled ?? this.isEnabled,
      isLocked: isLocked ?? this.isLocked,
      isAuthenticating: isAuthenticating ?? this.isAuthenticating,
      isDeviceSupported: isDeviceSupported ?? this.isDeviceSupported,
      availableBiometrics: availableBiometrics ?? this.availableBiometrics,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  /// Check if Face ID is available
  bool get hasFaceId => availableBiometrics.contains(BiometricType.face);

  /// Check if Fingerprint is available
  bool get hasFingerprint =>
      availableBiometrics.contains(BiometricType.fingerprint) ||
      availableBiometrics.contains(BiometricType.strong) ||
      availableBiometrics.contains(BiometricType.weak);

  /// Descriptive label for biometric hardware
  String get biometricName {
    if (hasFaceId) return 'Face ID';
    if (hasFingerprint) return 'Fingerprint / Touch ID';
    return 'Biometrics';
  }
}
