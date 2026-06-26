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
import 'package:meditation/repositories/practice_history_repository.dart';
import 'package:meditation/theme/app_theme.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    final contentRepository = MockContentRepository();
    final historyRepository = InMemoryPracticeHistoryRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ContentRepository>.value(value: contentRepository),
          ChangeNotifierProvider<PracticeHistoryRepository>.value(
            value: historyRepository,
          ),
          ChangeNotifierProvider(create: (_) => NavigationProvider()),
          ChangeNotifierProvider(
            create: (context) => PlayerProvider(
              historyRepository: context.read<PracticeHistoryRepository>(),
            ),
          ),
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
            create: (context) => ProfileProvider(
              repository: context.read<ContentRepository>(),
              historyRepository: context.read<PracticeHistoryRepository>(),
            )..load(),
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
