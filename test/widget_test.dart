// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteflow/main.dart';
import 'package:noteflow/providers/theme_provider.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('NoteFlow app loads', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const NoteFlowApp(),
      ),
    );

    // Le splash contient une animation continue ; il ne doit pas être attendu
    // avec pumpAndSettle dans ce test de chargement.
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 3));
  });
}
