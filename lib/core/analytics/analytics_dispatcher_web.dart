import 'dart:convert';
import 'dart:js_interop';

@JS('petconnectTrackAnalytics')
external void _trackAnalytics(
  String provider,
  String analyticsId,
  String eventName,
  String paramsJson,
);

void dispatchAnalyticsEvent({
  required String provider,
  required String analyticsId,
  required String eventName,
  required Map<String, Object?> params,
}) {
  _trackAnalytics(provider, analyticsId, eventName, jsonEncode(params));
}
