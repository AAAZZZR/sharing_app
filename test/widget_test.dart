import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_vault/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: LearningVaultApp()),
    );
    // Bottom nav is always present regardless of locale — check for home icon
    expect(find.byIcon(Icons.home), findsWidgets);
  });
}
