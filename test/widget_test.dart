import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meditation/app.dart';
import 'package:meditation/providers/navigation_provider.dart';
import 'package:meditation/providers/player_provider.dart';
import 'package:meditation/providers/breathing_provider.dart';
import 'package:meditation/theme/app_theme.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => NavigationProvider()),
          ChangeNotifierProvider(create: (_) => PlayerProvider()),
          ChangeNotifierProvider(create: (_) => BreathingProvider()),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const MeditationApp(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('今日推荐'), findsOneWidget);
    expect(find.text('首页'), findsOneWidget);
  });
}
