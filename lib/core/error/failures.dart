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
  const ServerFailure([String message = 'Server error occurred']) : super(message);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([String message = 'Unauthorized access']) : super(message);
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure([String message = 'Access forbidden']) : super(message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([String message = 'Resource not found']) : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure([String message = 'Validation failed']) : super(message);
}

// Network Failures
class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'No internet connection']) : super(message);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([String message = 'Request timeout']) : super(message);
}

// Cache Failures
class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache error occurred']) : super(message);
}

// Auth Failures
class AuthFailure extends Failure {
  const AuthFailure([String message = 'Authentication failed']) : super(message);
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure([String message = 'Invalid email or password']) 
      : super(message);
}

class EmailAlreadyInUseFailure extends AuthFailure {
  const EmailAlreadyInUseFailure([String message = 'Email already in use']) 
      : super(message);
}

class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure([String message = 'Password is too weak']) 
      : super(message);
}

class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure([String message = 'User not found']) 
      : super(message);
}

class AccountLockedFailure extends AuthFailure {
  const AccountLockedFailure([String message = 'Account locked. Please try again later']) 
      : super(message);
}

// Payment Failures
class PaymentFailure extends Failure {
  const PaymentFailure([String message = 'Payment failed']) : super(message);
}

class SubscriptionFailure extends Failure {
  const SubscriptionFailure([String message = 'Subscription operation failed']) 
      : super(message);
}

// Email Failures
class EmailSyncFailure extends Failure {
  const EmailSyncFailure([String message = 'Email sync failed']) : super(message);
}

class EmailPermissionFailure extends Failure {
  const EmailPermissionFailure([String message = 'Email permission denied']) 
      : super(message);
}

// Unknown Failure
class UnknownFailure extends Failure {
  const UnknownFailure([String message = 'An unknown error occurred']) : super(message);
}

// Biometric Failures
class BiometricFailure extends Failure {
  const BiometricFailure([String message = 'Biometric authentication failed']) 
      : super(message);
}

class BiometricNotAvailableFailure extends BiometricFailure {
  const BiometricNotAvailableFailure(
      [String message = 'Biometric authentication not available']) 
      : super(message);
}

class BiometricNotEnrolledFailure extends BiometricFailure {
  const BiometricNotEnrolledFailure(
      [String message = 'No biometric credentials enrolled']) 
      : super(message);
}
