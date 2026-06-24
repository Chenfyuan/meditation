import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meditation/app.dart';
import 'package:meditation/providers/explore_provider.dart';
import 'package:meditation/providers/home_provider.dart';
import 'package:meditation/providers/navigation_provider.dart';
import 'package:meditation/providers/player_provider.dart';
import 'package:meditation/providers/breathing_provider.dart';
import 'package:meditation/providers/profile_provider.dart';
import 'package:meditation/providers/sleep_provider.dart';
import 'package:meditation/repositories/content_repository.dart';
import 'package:meditation/repositories/mock_content_repository.dart';
import 'package:meditation/theme/app_theme.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    final contentRepository = MockContentRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ContentRepository>.value(value: contentRepository),
          ChangeNotifierProvider(create: (_) => NavigationProvider()),
          ChangeNotifierProvider(create: (_) => PlayerProvider()),
          ChangeNotifierProvider(create: (_) => BreathingProvider()),
          ChangeNotifierProvider(
            create: (context) =>
                HomeProvider(repository: context.read<ContentRepository>())
                  ..load(),
          ),
          ChangeNotifierProvider(
            create: (context) =>
                ExploreProvider(repository: context.read<ContentRepository>())
                  ..load(),
          ),
          ChangeNotifierProvider(
            create: (context) =>
                SleepProvider(repository: context.read<ContentRepository>())
                  ..load(),
          ),
          ChangeNotifierProvider(
            create: (context) =>
                ProfileProvider(repository: context.read<ContentRepository>())
                  ..load(),
          ),
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
