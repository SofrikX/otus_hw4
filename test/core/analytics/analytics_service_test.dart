import 'package:flutter_test/flutter_test.dart';
import 'package:petconnect/core/analytics/analytics_event.dart';
import 'package:petconnect/core/analytics/analytics_service.dart';
import 'package:petconnect/core/network/api_error.dart';

void main() {
  test('disabled analytics does not dispatch events', () async {
    final calls = <_AnalyticsCall>[];
    final service = AnalyticsService(
      config: const AnalyticsConfig(
        enabled: false,
        provider: AnalyticsProvider.yandexMetrica,
        analyticsId: '109987921',
      ),
      dispatcher: ({
        required provider,
        required analyticsId,
        required eventName,
        required params,
      }) {
        calls.add(
          _AnalyticsCall(
            provider: provider,
            analyticsId: analyticsId,
            eventName: eventName,
            params: params,
          ),
        );
      },
    );

    await service.track(AnalyticsEvent.appOpen);

    expect(calls, isEmpty);
  });

  test('enabled analytics dispatches sanitized event params', () async {
    final calls = <_AnalyticsCall>[];
    final service = AnalyticsService(
      config: const AnalyticsConfig(
        enabled: true,
        provider: AnalyticsProvider.yandexMetrica,
        analyticsId: '109987921',
      ),
      dispatcher: ({
        required provider,
        required analyticsId,
        required eventName,
        required params,
      }) {
        calls.add(
          _AnalyticsCall(
            provider: provider,
            analyticsId: analyticsId,
            eventName: eventName,
            params: params,
          ),
        );
      },
    );

    await service.track(
      AnalyticsEvent.postCreated,
      params: const {
        'text_length': 'short',
        'email': 'owner@example.com',
        'user_id': 'user-1',
        'token': 'secret-token',
      },
    );

    expect(calls, hasLength(1));
    expect(calls.single.provider, AnalyticsProvider.yandexMetrica);
    expect(calls.single.analyticsId, '109987921');
    expect(calls.single.eventName, AnalyticsEvent.postCreated.name);
    expect(calls.single.params, {'text_length': 'short'});
  });

  test('backend errors are tracked without raw exception text', () async {
    final calls = <_AnalyticsCall>[];
    final service = AnalyticsService(
      config: const AnalyticsConfig(
        enabled: true,
        provider: AnalyticsProvider.yandexMetrica,
        analyticsId: '109987921',
      ),
      dispatcher: ({
        required provider,
        required analyticsId,
        required eventName,
        required params,
      }) {
        calls.add(
          _AnalyticsCall(
            provider: provider,
            analyticsId: analyticsId,
            eventName: eventName,
            params: params,
          ),
        );
      },
    );

    await service.trackBackendError(
      operation: 'feed_refresh',
      error: const ApiServerException(message: 'Internal stack detail'),
    );

    expect(calls, hasLength(1));
    expect(calls.single.eventName, AnalyticsEvent.backendError.name);
    expect(calls.single.params, {
      'operation': 'feed_refresh',
      'error_type': 'internal-error',
      'status_code': 500,
      'error_code': 'internal-error',
    });
  });
}

class _AnalyticsCall {
  const _AnalyticsCall({
    required this.provider,
    required this.analyticsId,
    required this.eventName,
    required this.params,
  });

  final String provider;
  final String analyticsId;
  final String eventName;
  final Map<String, Object?> params;
}
