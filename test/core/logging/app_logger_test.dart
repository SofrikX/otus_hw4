import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:petconnect/core/logging/app_logger.dart';

void main() {
  test('logger writes structured json with safe technical fields', () {
    final lines = <String>[];
    final logger = AppLogger(
      component: 'test',
      debugPrinter: (message, {wrapWidth}) {
        if (message != null) {
          lines.add(message);
        }
      },
    );

    logger.warning(
      'supabase_request_error',
      message: 'Supabase request failed.',
      details: const {
        'operation': 'feed.load',
        'status_code': 403,
        'error_code': '42501',
      },
    );

    expect(lines, hasLength(1));
    final payload = jsonDecode(lines.single) as Map<String, dynamic>;
    expect(payload['level'], 'warning');
    expect(payload['component'], 'test');
    expect(payload['event'], 'supabase_request_error');
    expect(payload['message'], 'Supabase request failed.');
    expect(payload['details'], {
      'operation': 'feed.load',
      'status_code': 403,
      'error_code': '42501',
    });
  });

  test('logger removes secrets, personal data and user content', () {
    final safe = AppLogger.sanitize(const {
      'operation': 'auth.signIn',
      'email': 'owner@example.com',
      'user_id': 'user-1',
      'post_id': 'post-1',
      'token': 'secret-token',
      'password': 'secret-password',
      'comment_text': 'private comment',
      'display_name': 'Alex',
      'status_code': 401,
    });

    expect(safe, {
      'operation': 'auth.signIn',
      'status_code': 401,
    });
  });
}
