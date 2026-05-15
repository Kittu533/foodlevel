import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodlevel/app/app.dart';

void main() {
  testWidgets('home screen renders FoodLevel dashboard', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: FoodLevelApp()));

    expect(find.text('FoodLevel'), findsOneWidget);
    expect(find.text('Scan makanan'), findsOneWidget);
    expect(find.byIcon(Icons.photo_camera_outlined), findsOneWidget);
    expect(find.byIcon(Icons.photo_library_outlined), findsOneWidget);
  });
}
