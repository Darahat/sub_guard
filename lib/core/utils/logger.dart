import 'package:logger/logger.dart';

class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();
  
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );
  
  // Debug logging
  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }
  
  // Info logging
  void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }
  
  // Warning logging
  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }
  
  // Error logging
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
  
  // Verbose logging
  void verbose(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.t(message, error: error, stackTrace: stackTrace);
  }
  
  // Fatal logging
  void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }
  
  // API logging
  void apiRequest(String method, String endpoint, {Map<String, dynamic>? data}) {
    _logger.i('API Request: $method $endpoint', error: data);
  }
  
  void apiResponse(String method, String endpoint, int statusCode, {dynamic data}) {
    _logger.i('API Response: $method $endpoint - Status: $statusCode', error: data);
  }
  
  void apiError(String method, String endpoint, dynamic error) {
    _logger.e('API Error: $method $endpoint', error: error);
  }
}

// Global logger instance
final logger = AppLogger();
