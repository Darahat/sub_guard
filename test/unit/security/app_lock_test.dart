import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:sub_guard/core/security/app_lock_notifier.dart';
import 'package:sub_guard/core/security/app_lock_state.dart';
import 'package:sub_guard/core/services/biometric_service.dart';

class FakeBiometricService implements BiometricService {
  bool isAvailable = true;
  List<BiometricType> biometrics = [BiometricType.fingerprint];
  bool isLockEnabled = false;
  bool shouldAuthSucceed = true;
  bool setLockEnabledCalled = false;
  DateTime? lastActiveTime;

  @override
  Future<bool> isBiometricsAvailable() async => isAvailable;

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async => biometrics;

  @override
  Future<bool> isAppLockEnabled() async => isLockEnabled;

  @override
  Future<bool> authenticate({String localizedReason = 'Authenticate'}) async =>
      shouldAuthSucceed;

  @override
  Future<void> setAppLockEnabled(bool enabled) async {
    setLockEnabledCalled = true;
    isLockEnabled = enabled;
  }

  @override
  Future<void> recordLastActiveTime() async {
    lastActiveTime = DateTime.now();
  }

  @override
  Future<DateTime?> getLastActiveTime() async => lastActiveTime;
}

void main() {
  late FakeBiometricService fakeBiometricService;
  late AppLockNotifier appLockNotifier;

  setUp(() {
    fakeBiometricService = FakeBiometricService();
  });

  group('AppLockState Model', () {
    test('should correctly identify Face ID vs Fingerprint', () {
      const faceIdState = AppLockState(
        isDeviceSupported: true,
        availableBiometrics: [BiometricType.face],
      );
      expect(faceIdState.hasFaceId, isTrue);
      expect(faceIdState.hasFingerprint, isFalse);
      expect(faceIdState.biometricName, equals('Face ID'));

      const fingerprintState = AppLockState(
        isDeviceSupported: true,
        availableBiometrics: [BiometricType.fingerprint],
      );
      expect(fingerprintState.hasFaceId, isFalse);
      expect(fingerprintState.hasFingerprint, isTrue);
      expect(fingerprintState.biometricName, equals('Fingerprint / Touch ID'));
    });
  });

  group('AppLockNotifier Workflow', () {
    test('initialization with enabled lock should unlock on successful auth', () async {
      fakeBiometricService.isAvailable = true;
      fakeBiometricService.biometrics = [BiometricType.fingerprint];
      fakeBiometricService.isLockEnabled = true;
      fakeBiometricService.shouldAuthSucceed = true;

      appLockNotifier = AppLockNotifier(fakeBiometricService);
      await appLockNotifier.initialize();

      expect(appLockNotifier.state.isEnabled, isTrue);
      expect(appLockNotifier.state.isLocked, isFalse);
    });

    test('failed authentication should leave app locked with error message', () async {
      fakeBiometricService.isAvailable = true;
      fakeBiometricService.biometrics = [BiometricType.face];
      fakeBiometricService.isLockEnabled = true;
      fakeBiometricService.shouldAuthSucceed = false;

      appLockNotifier = AppLockNotifier(fakeBiometricService);
      await appLockNotifier.initialize();

      expect(appLockNotifier.state.isEnabled, isTrue);
      expect(appLockNotifier.state.isLocked, isTrue);
      expect(appLockNotifier.state.errorMessage, isNotNull);
    });

    test('toggleAppLock enables lock when user authenticates', () async {
      fakeBiometricService.isAvailable = true;
      fakeBiometricService.biometrics = [BiometricType.fingerprint];
      fakeBiometricService.isLockEnabled = false;
      fakeBiometricService.shouldAuthSucceed = true;

      appLockNotifier = AppLockNotifier(fakeBiometricService);
      await appLockNotifier.initialize();

      final result = await appLockNotifier.toggleAppLock(true);
      expect(result, isTrue);
      expect(appLockNotifier.state.isEnabled, isTrue);
      expect(fakeBiometricService.setLockEnabledCalled, isTrue);
    });
  });
}
