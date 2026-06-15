import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petconnect/features/feed/application/feed_controller.dart';
import 'package:petconnect/features/feed/domain/pet_post.dart';
import 'package:petconnect/features/feed/presentation/screens/feed_screen.dart';

void main() {
  testWidgets('FeedScreen shows friendly error state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          feedControllerProvider.overrideWith(
            (ref) => FeedController(
              initialState: AsyncValue<List<PetPost>>.error(
                Exception('Тестовая ошибка загрузки'),
                StackTrace.current,
              ),
            ),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: FeedScreen()),
        ),
      ),
    );

    expect(find.text('Не удалось загрузить данные'), findsOneWidget);
    expect(find.text('Тестовая ошибка загрузки'), findsOneWidget);
    expect(find.text('Повторить'), findsOneWidget);
  });
}
