import 'dart:developer' as developer;

/// Utilidad centralizada para logging
class AppLogger {
  static const String _tag = 'CLARA';

  /// Log de información general
  static void info(String message, [String? tag]) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 800, // INFO level
    );
  }

  /// Log de advertencias
  static void warning(String message, [String? tag]) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 900, // WARNING level
    );
  }

  /// Log de errores
  static void error(String message,
      [Object? error, StackTrace? stackTrace, String? tag]) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 1000, // ERROR level
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log de debug (solo en modo debug)
  static void debug(String message, [String? tag]) {
    assert(() {
      developer.log(
        message,
        name: tag ?? _tag,
        level: 700, // DEBUG level
      );
      return true;
    }());
  }

  /// Log específico para operaciones de datos
  static void data(String operation, String details) {
    info('DATA: $operation - $details', 'DATA');
  }

  /// Log específico para UI
  static void ui(String event, String details) {
    debug('UI: $event - $details', 'UI');
  }

  /// Log específico para BLoC
  static void bloc(String event, String state) {
    debug('BLOC: $event -> $state', 'BLOC');
  }
}
