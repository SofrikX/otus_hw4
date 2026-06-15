import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petconnect/core/data/mock_data.dart';
import 'package:petconnect/features/walks/application/walks_controller.dart';
import 'package:petconnect/features/walks/domain/walk.dart';
import 'package:petconnect/features/walks/presentation/screens/walks_screen.dart';

void main() {
  testWidgets('WalksScreen allows user to join a walk', (tester) async {
    final walk = mockWalks.first.copyWith(isJoined: false, participantCount: 1);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          walksControllerProvider.overrideWith(
            (ref) => WalksController(
              initialState: AsyncValue<List<Walk>>.data([walk]),
            ),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: WalksScreen()),
        ),
      ),
    );

    expect(find.text('Присоединиться'), findsOneWidget);

    await tester.tap(find.byKey(Key('join-${walk.id}')));
    await tester.pump();

    expect(find.text('Вы участвуете'), findsOneWidget);
    expect(find.text('2 участников'), findsOneWidget);
  });
}
