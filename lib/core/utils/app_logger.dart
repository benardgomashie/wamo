import 'package:flutter/foundation.dart';

class AppLogger {
  static void info(String scope, String message) {
    debugPrint('[INFO][$scope] $message');
  }

  static void warn(String scope, String message) {
    debugPrint('[WARN][$scope] $message');
  }

  static void error(String scope, String message,
      [Object? error, StackTrace? stackTrace]) {
    debugPrint('[ERROR][$scope] $message');
    if (error != null) {
      debugPrint('[ERROR][$scope] Details: $error');
    }
    if (stackTrace != null) {
      debugPrint('[ERROR][$scope] Stack: $stackTrace');
    }
  }
}
