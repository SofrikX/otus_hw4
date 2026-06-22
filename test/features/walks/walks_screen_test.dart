import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petconnect/core/data/mock_data.dart';
import 'package:petconnect/features/walks/application/walks_controller.dart';
import 'package:petconnect/features/walks/domain/walk.dart';
import 'package:petconnect/features/walks/domain/walks_repository.dart';
import 'package:petconnect/features/walks/presentation/screens/walks_screen.dart';

void main() {
  testWidgets('WalksScreen shows loading state', (tester) async {
    await tester.pumpWidget(
      _buildWalksScreen(
        controller: WalksController(
          initialState: const AsyncValue<List<Walk>>.loading(),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('WalksScreen shows empty state', (tester) async {
    await tester.pumpWidget(
      _buildWalksScreen(
        controller: WalksController(
          initialState: const AsyncValue<List<Walk>>.data([]),
        ),
      ),
    );

    expect(find.text('Прогулок пока нет'), findsOneWidget);
    expect(
      find.text(
        'Активные встречи появятся здесь. Обновите список перед прогулкой.',
      ),
      findsOneWidget,
    );
    expect(find.text('Обновить прогулки'), findsOneWidget);
  });

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

  testWidgets('WalksScreen shows already joined state from repository',
      (tester) async {
    final walk = mockWalks.first.copyWith(isJoined: false, participantCount: 1);

    await tester.pumpWidget(
      _buildWalksScreen(
        controller: WalksController(
          repository: _AlreadyJoinedWalksRepository([walk]),
          initialState: AsyncValue<List<Walk>>.data([walk]),
        ),
      ),
    );

    await tester.tap(find.byKey(Key('join-${walk.id}')));
    await tester.pumpAndSettle();

    expect(find.text('Вы участвуете'), findsOneWidget);
    expect(find.text('Вы уже участвуете: ${walk.title}'), findsOneWidget);
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

class _AlreadyJoinedWalksRepository implements WalksRepository {
  const _AlreadyJoinedWalksRepository(this._walks);

  final List<Walk> _walks;

  @override
  Future<List<Walk>> fetchWalks({int limit = 20}) async {
    return _walks.take(limit).toList(growable: false);
  }

  @override
  Future<Walk> createWalk(CreateWalkInput input) async {
    return Walk(
      id: 'walk-new',
      title: input.title,
      place: input.place,
      startsAt: input.startsAt,
      description: input.description,
      organizerName: input.organizerName ?? 'Вы',
      participantCount: 0,
      isJoined: false,
    );
  }

  @override
  Future<WalkJoinResult> joinWalk(String walkId) async {
    final walk = _walks.firstWhere((walk) => walk.id == walkId);
    return WalkJoinResult(
      walkId: walk.id,
      isJoined: true,
      participantsCount: walk.participantCount,
      alreadyJoined: true,
    );
  }

  @override
  Future<WalkJoinResult> leaveWalk(String walkId) async {
    final walk = _walks.firstWhere((walk) => walk.id == walkId);
    return WalkJoinResult(
      walkId: walk.id,
      isJoined: false,
      participantsCount: walk.participantCount,
    );
  }
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
