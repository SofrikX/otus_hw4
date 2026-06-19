import 'dart:convert';

import 'package:flutter/foundation.dart';

enum AppLogLevel {
  info,
  warning,
  error,
}

typedef AppDebugPrinter = void Function(String? message, {int? wrapWidth});

class AppLogger {
  const AppLogger({
    this.component = 'app',
    this.debugPrinter,
  });

  final String component;
  final AppDebugPrinter? debugPrinter;

  void info(
    String event, {
    String? message,
    Map<String, Object?> details = const {},
  }) {
    log(
      AppLogLevel.info,
      event,
      message: message,
      details: details,
    );
  }

  void warning(
    String event, {
    String? message,
    Map<String, Object?> details = const {},
  }) {
    log(
      AppLogLevel.warning,
      event,
      message: message,
      details: details,
    );
  }

  void error(
    String event, {
    String? message,
    Map<String, Object?> details = const {},
  }) {
    log(
      AppLogLevel.error,
      event,
      message: message,
      details: details,
    );
  }

  void log(
    AppLogLevel level,
    String event, {
    String? message,
    Map<String, Object?> details = const {},
  }) {
    final payload = <String, Object?>{
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'level': level.name,
      'component': component,
      'event': _safeString(event),
      if (message != null) 'message': _safeString(message),
      if (details.isNotEmpty) 'details': sanitize(details),
    };

    (debugPrinter ?? debugPrint)(jsonEncode(payload));
  }

  static Map<String, Object?> sanitize(Map<String, Object?> details) {
    final result = <String, Object?>{};
    for (final entry in details.entries) {
      final key = entry.key.trim();
      if (key.isEmpty || _isBlockedKey(key)) {
        continue;
      }

      final value = entry.value;
      if (value == null || value is num || value is bool) {
        result[key] = value;
      } else if (value is String) {
        result[key] = _safeString(value);
      } else if (value is Enum) {
        result[key] = value.name;
      } else {
        result[key] = value.runtimeType.toString();
      }
    }

    return Map<String, Object?>.unmodifiable(result);
  }

  static bool _isBlockedKey(String key) {
    final normalized = key.toLowerCase();
    return normalized.contains('email') ||
        normalized.contains('phone') ||
        normalized.contains('name') ||
        normalized.contains('address') ||
        normalized.contains('city') ||
        normalized.contains('bio') ||
        normalized.contains('text') ||
        normalized.contains('message_body') ||
        normalized.contains('content') ||
        normalized.contains('user_id') ||
        normalized.contains('userid') ||
        normalized == 'user' ||
        normalized.endsWith('_id') ||
        normalized.contains('token') ||
        normalized.contains('password') ||
        normalized.contains('secret') ||
        normalized.contains('apikey') ||
        normalized.contains('api_key') ||
        normalized.contains('authorization') ||
        normalized.contains('cookie') ||
        normalized.contains('supabase_url') ||
        normalized.contains('publishable_key') ||
        normalized.contains('service_role');
  }

  static String _safeString(String value) {
    final trimmed = value.trim();
    if (trimmed.length <= 120) {
      return trimmed;
    }
    return '${trimmed.substring(0, 120)}...';
  }
}
