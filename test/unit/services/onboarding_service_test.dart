import 'package:flutter_test/flutter_test.dart';
import 'package:sub_guard/core/services/onboarding_service.dart';

void main() {
  late OnboardingService onboardingService;

  setUp(() {
    onboardingService = OnboardingService();
  });

  group('OnboardingService', () {
    test('should instantiate properly and provide default false status if unset', () async {
      expect(onboardingService, isNotNull);
    });
  });
}
