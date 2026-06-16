import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petconnect/core/data/mock_data.dart';
import 'package:petconnect/features/walks/application/walks_controller.dart';
import 'package:petconnect/features/walks/domain/walk.dart';
import 'package:petconnect/features/walks/presentation/screens/walks_screen.dart';

void main() {
  testWidgets('WalksScreen shows walk list', (tester) async {
    final walk = mockWalks.first.copyWith(isJoined: false, participantCount: 1);

    await tester.pumpWidget(
      _buildWalksScreen(
        controller: WalksController(
          initialState: AsyncValue<List<Walk>>.data([walk]),
        ),
      ),
    );

    expect(find.text(walk.title), findsOneWidget);
    expect(find.text(walk.place), findsOneWidget);
    expect(find.text('1 участников'), findsOneWidget);
    expect(find.text('Присоединиться'), findsOneWidget);
  });

  testWidgets('WalksScreen allows user to join walk', (tester) async {
    final walk = mockWalks.first.copyWith(isJoined: false, participantCount: 1);

    await tester.pumpWidget(
      _buildWalksScreen(
        controller: WalksController(
          initialState: AsyncValue<List<Walk>>.data([walk]),
        ),
      ),
    );

    await tester.tap(find.byKey(Key('join-${walk.id}')));
    await tester.pumpAndSettle();

    expect(find.text('Вы участвуете'), findsOneWidget);
    expect(find.text('2 участников'), findsOneWidget);
    expect(find.text('1 участников'), findsNothing);
    expect(find.text('Вы присоединились: ${walk.title}'), findsOneWidget);
  });

  testWidgets('WalksScreen shows error state with retry', (tester) async {
    await tester.pumpWidget(
      _buildWalksScreen(
        controller: WalksController(
          initialState: AsyncValue<List<Walk>>.error(
            Exception('Не удалось загрузить прогулки рядом.'),
            StackTrace.current,
          ),
        ),
      ),
    );

    expect(find.text('Не удалось загрузить данные'), findsOneWidget);
    expect(find.text('Не удалось загрузить прогулки рядом.'), findsOneWidget);
    expect(find.text('Повторить'), findsOneWidget);
  });
}

Widget _buildWalksScreen({WalksController? controller}) {
  return ProviderScope(
    overrides: [
      if (controller != null)
        walksControllerProvider.overrideWith(
          (ref) => controller,
        ),
    ],
    child: const MaterialApp(
      home: Scaffold(body: WalksScreen()),
    ),
  );
}
