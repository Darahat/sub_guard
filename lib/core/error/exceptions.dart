class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException({required this.message, this.statusCode});

  @override
  String toString() =>
      'ServerException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

class NetworkException implements Exception {
  final String message;

  NetworkException([this.message = 'No internet connection']);

  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;

  CacheException([this.message = 'Cache operation failed']);

  @override
  String toString() => 'CacheException: $message';
}

class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException({required this.message, this.code});

  @override
  String toString() =>
      'AuthException: $message${code != null ? ' (Code: $code)' : ''}';
}

class ValidationException implements Exception {
  final Map<String, List<String>> errors;

  ValidationException({required this.errors});

  @override
  String toString() => 'ValidationException: $errors';

  String get firstError {
    if (errors.isEmpty) return 'Validation failed';
    return errors.values.first.first;
  }
}

class TimeoutException implements Exception {
  final String message;

  TimeoutException({this.message = 'Request timeout'});

  @override
  String toString() => 'TimeoutException: $message';
}

class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException({this.message = 'Unauthorized access'});

  @override
  String toString() => 'UnauthorizedException: $message';
}

class NotFoundException implements Exception {
  final String message;

  NotFoundException({this.message = 'Resource not found'});

  @override
  String toString() => 'NotFoundException: $message';
}

class PaymentException implements Exception {
  final String message;
  final String? code;

  PaymentException({required this.message, this.code});

  @override
  String toString() =>
      'PaymentException: $message${code != null ? ' (Code: $code)' : ''}';
}

class BiometricException implements Exception {
  final String message;
  final String? code;

  BiometricException({required this.message, this.code});

  @override
  String toString() =>
      'BiometricException: $message${code != null ? ' (Code: $code)' : ''}';
}
