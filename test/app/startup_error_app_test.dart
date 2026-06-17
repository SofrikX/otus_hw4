import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petconnect/app/startup_error_app.dart';

void main() {
  testWidgets('StartupErrorApp shows Supabase configuration error', (
    tester,
  ) async {
    await tester.pumpWidget(
      const StartupErrorApp(
        message: 'SUPABASE_URL is required when USE_SUPABASE_BACKEND=true.',
      ),
    );

    expect(find.text('Не удалось подключить Supabase'), findsOneWidget);
    expect(
      find.text('SUPABASE_URL is required when USE_SUPABASE_BACKEND=true.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
  });
}
