import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_error.dart';
import 'analytics_event.dart';
import 'analytics_dispatcher_stub.dart'
    if (dart.library.html) 'analytics_dispatcher_web.dart';

final analyticsConfigProvider = Provider<AnalyticsConfig>((ref) {
  return AnalyticsConfig.fromEnvironment();
});

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService(config: ref.watch(analyticsConfigProvider));
});

typedef AnalyticsDispatcher = void Function({
  required String provider,
  required String analyticsId,
  required String eventName,
  required Map<String, Object?> params,
});

class AnalyticsConfig {
  const AnalyticsConfig({
    required this.enabled,
    required this.provider,
    required this.analyticsId,
  });

  factory AnalyticsConfig.fromEnvironment() {
    return const AnalyticsConfig(
      enabled: bool.fromEnvironment('ANALYTICS_ENABLED'),
      provider: String.fromEnvironment('ANALYTICS_PROVIDER'),
      analyticsId: String.fromEnvironment('ANALYTICS_ID'),
    );
  }

  final bool enabled;
  final String provider;
  final String analyticsId;

  bool get isReady {
    return enabled &&
        provider.trim().toLowerCase() == AnalyticsProvider.yandexMetrica &&
        analyticsId.trim().isNotEmpty;
  }
}

class AnalyticsProvider {
  static const yandexMetrica = 'yandex_metrica';
}

class AnalyticsService {
  const AnalyticsService({
    required this.config,
    AnalyticsDispatcher dispatcher = dispatchAnalyticsEvent,
  }) : _dispatcher = dispatcher;

  final AnalyticsConfig config;
  final AnalyticsDispatcher _dispatcher;

  Future<void> track(
    AnalyticsEvent event, {
    Map<String, Object?> params = const {},
  }) async {
    final safeParams = _safeParams(params);
    if (!config.isReady) {
      _logLocal(event, safeParams);
      return;
    }

    try {
      _dispatcher(
        provider: config.provider.trim().toLowerCase(),
        analyticsId: config.analyticsId.trim(),
        eventName: event.name,
        params: safeParams,
      );
    } on Object catch (error) {
      debugPrint('Analytics dispatch skipped: ${error.runtimeType}');
    }
  }

  Future<void> trackBackendError({
    required String operation,
    required Object error,
  }) {
    return track(
      AnalyticsEvent.backendError,
      params: {
        'operation': operation,
        'error_type': _errorType(error),
        if (error is ApiException) 'status_code': error.statusCode,
        if (error is ApiException) 'error_code': error.code,
      },
    );
  }

  Future<void> trackAuthError({
    required String operation,
    required Object error,
  }) {
    return track(
      AnalyticsEvent.authError,
      params: {
        'operation': operation,
        'error_type': _errorType(error),
        if (error is ApiException) 'status_code': error.statusCode,
        if (error is ApiException) 'error_code': error.code,
      },
    );
  }

  static String textLengthBucket(String text) {
    final length = text.trim().length;
    if (length == 0) {
      return 'empty';
    }
    if (length <= 80) {
      return 'short';
    }
    if (length <= 280) {
      return 'medium';
    }
    return 'long';
  }

  Map<String, Object?> _safeParams(Map<String, Object?> params) {
    final result = <String, Object?>{};
    for (final entry in params.entries) {
      if (_isSensitiveKey(entry.key)) {
        continue;
      }

      final value = entry.value;
      if (value == null || value is String || value is num || value is bool) {
        result[entry.key] = value;
      }
    }
    return Map<String, Object?>.unmodifiable(result);
  }

  bool _isSensitiveKey(String key) {
    final normalized = key.toLowerCase();
    return normalized.contains('email') ||
        normalized.contains('user_id') ||
        normalized.contains('userid') ||
        normalized.contains('token') ||
        normalized.contains('password') ||
        normalized.contains('secret');
  }

  String _errorType(Object error) {
    if (error is ApiException) {
      return error.code;
    }
    return error.runtimeType.toString();
  }

  void _logLocal(AnalyticsEvent event, Map<String, Object?> params) {
    if (kDebugMode) {
      debugPrint('Analytics disabled: ${event.name} $params');
    }
  }
}
