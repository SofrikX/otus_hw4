import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petconnect/features/pets/presentation/screens/pet_profile_screen.dart';

void main() {
  testWidgets('PetProfileScreen shows not found state for unknown pet',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: PetProfileScreen(petId: 'unknown-pet'),
        ),
      ),
    );

    expect(find.text('Питомец не найден'), findsOneWidget);
  });
}
