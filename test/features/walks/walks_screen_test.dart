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
        'Активные встречи появятся здесь. Создайте первую прогулку.',
      ),
      findsOneWidget,
    );
    expect(find.text('Создать прогулку'), findsOneWidget);
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

  testWidgets('WalksScreen shows empty state for unmatched filters',
      (tester) async {
    final walk = mockWalks.first.copyWith(
      startsAt: DateTime.now().add(const Duration(days: 1)),
    );

    await tester.pumpWidget(
      _buildWalksScreen(
        controller: WalksController(
          initialState: AsyncValue<List<Walk>>.data([walk]),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('walk-status-completed')));
    await tester.pumpAndSettle();

    expect(find.text('Подходящих прогулок нет'), findsOneWidget);
    expect(find.text('Сбросить фильтры'), findsOneWidget);
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

    await _scrollToJoinButton(tester, walk);
    await tester.tap(find.byKey(Key('join-${walk.id}')));
    await tester.pumpAndSettle();

    expect(find.text('Выйти'), findsOneWidget);
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

    await _scrollToJoinButton(tester, walk);
    await tester.tap(find.byKey(Key('join-${walk.id}')));
    await tester.pumpAndSettle();

    expect(find.text('Выйти'), findsOneWidget);
    expect(find.text('Вы уже участвуете: ${walk.title}'), findsOneWidget);
  });

  testWidgets('WalksScreen allows user to leave joined walk', (tester) async {
    final walk = mockWalks.first.copyWith(isJoined: true, participantCount: 2);

    await tester.pumpWidget(
      _buildWalksScreen(
        controller: WalksController(
          initialState: AsyncValue<List<Walk>>.data([walk]),
        ),
      ),
    );

    await _scrollToJoinButton(tester, walk);
    await tester.tap(find.byKey(Key('join-${walk.id}')));
    await tester.pumpAndSettle();

    expect(find.text('Присоединиться'), findsOneWidget);
    expect(find.text('1 участников'), findsOneWidget);
    expect(find.text('Вы вышли из прогулки: ${walk.title}'), findsOneWidget);
  });

  testWidgets('WalksScreen validates create walk form', (tester) async {
    await tester.pumpWidget(_buildWalksScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('add-walk-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('save-walk-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('walk-form-error')), findsOneWidget);
    expect(find.text('Укажите название прогулки.'), findsOneWidget);
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

Future<void> _scrollToJoinButton(WidgetTester tester, Walk walk) async {
  await tester.scrollUntilVisible(
    find.byKey(Key('join-${walk.id}')),
    320,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

class _AlreadyJoinedWalksRepository implements WalksRepository {
  const _AlreadyJoinedWalksRepository(this._walks);

  final List<Walk> _walks;

  @override
  Future<List<Walk>> fetchWalks({
    int limit = 20,
    WalkFilters filters = const WalkFilters(),
  }) async {
    return _walks.where(filters.matches).take(limit).toList(growable: false);
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
