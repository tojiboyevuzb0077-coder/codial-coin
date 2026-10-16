import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:coin/main.dart';
import 'package:coin/repositories/app_repository.dart';
import 'package:coin/providers/app_providers.dart';

void main() {
  testWidgets('CodialCoinApp smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final repo = AppRepository();
    await repo.init();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appRepositoryProvider.overrideWithValue(repo),
        ],
        child: const CodialCoinApp(),
      ),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
