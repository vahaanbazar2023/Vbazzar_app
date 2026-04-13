import 'package:flutter/foundation.dart';

class LoggerService {
  LoggerService._();
  static final LoggerService instance = LoggerService._();
  static LoggerService get to => instance;

  void debug(String msg) => _log('DEBUG', msg);
  void info(String msg) => _log('INFO', msg);
  void warning(String msg) => _log('WARN', msg);
  void error(String msg, [Object? error, StackTrace? stack]) {
    _log('ERROR', msg);
    if (error != null) _log('ERROR', '  ↳ $error');
    if (stack != null && kDebugMode) debugPrint('$stack');
  }

  void _log(String level, String msg) {
    if (kDebugMode) {
      final ts = DateTime.now().toIso8601String();
      debugPrint('[$ts][$level] $msg');
    }
  }
}
