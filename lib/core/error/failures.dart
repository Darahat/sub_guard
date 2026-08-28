import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);
  
  @override
  List<Object> get props => [message];
  
  @override
  String toString() => message;
}

// Server Failures
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Unauthorized access']);
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure([super.message = 'Access forbidden']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation failed']);
}

// Network Failures
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Request timeout']);
}

// Cache Failures
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred']);
}

// Auth Failures
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed']);
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure([super.message = 'Invalid email or password']);
}

class EmailAlreadyInUseFailure extends AuthFailure {
  const EmailAlreadyInUseFailure([super.message = 'Email already in use']);
}

class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure([super.message = 'Password is too weak']);
}

class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure([super.message = 'User not found']);
}

class AccountLockedFailure extends AuthFailure {
  const AccountLockedFailure([super.message = 'Account locked. Please try again later']);
}

// Payment Failures
class PaymentFailure extends Failure {
  const PaymentFailure([super.message = 'Payment failed']);
}

class SubscriptionFailure extends Failure {
  const SubscriptionFailure([super.message = 'Subscription operation failed']);
}

// Email Failures
class EmailSyncFailure extends Failure {
  const EmailSyncFailure([super.message = 'Email sync failed']);
}

class EmailPermissionFailure extends Failure {
  const EmailPermissionFailure([super.message = 'Email permission denied']);
}

// Unknown Failure
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unknown error occurred']);
}

// Biometric Failures
class BiometricFailure extends Failure {
  const BiometricFailure([super.message = 'Biometric authentication failed']);
}

class BiometricNotAvailableFailure extends BiometricFailure {
  const BiometricNotAvailableFailure([super.message = 'Biometric authentication not available']);
}

class BiometricNotEnrolledFailure extends BiometricFailure {
  const BiometricNotEnrolledFailure([super.message = 'No biometric credentials enrolled']);
}
