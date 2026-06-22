import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logging/app_logger.dart';
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
      analyticsId: String.fromEnvironment('YANDEX_METRICA_COUNTER_ID'),
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
    AppLogger logger = const AppLogger(component: 'analytics'),
  })  : _dispatcher = dispatcher,
        _logger = logger;

  final AnalyticsConfig config;
  final AnalyticsDispatcher _dispatcher;
  final AppLogger _logger;

  Future<void> track(
    AnalyticsEvent event, {
    Map<String, Object?> params = const {},
  }) async {
    if (!config.isReady) {
      if (config.enabled) {
        _logger.warning(
          'analytics_not_configured',
          message:
              'Analytics event was not dispatched because analytics is not configured.',
          details: {
            'event': event.name,
            'provider_configured': config.provider.trim().isNotEmpty,
            'analytics_id_configured': config.analyticsId.trim().isNotEmpty,
          },
        );
      }
      return;
    }

    try {
      _dispatcher(
        provider: config.provider.trim().toLowerCase(),
        analyticsId: config.analyticsId.trim(),
        eventName: event.name,
        params: _safeParams(params),
      );
    } on Object catch (error) {
      _logger.error(
        'analytics_dispatch_error',
        message: 'Analytics event dispatch failed.',
        details: {
          'event': event.name,
          'error_type': error.runtimeType.toString(),
        },
      );
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
}
