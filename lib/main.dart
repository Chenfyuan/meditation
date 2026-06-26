import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/explore_provider.dart';
import 'providers/home_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/player_provider.dart';
import 'providers/breathing_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/sleep_provider.dart';
import 'repositories/content_repository.dart';
import 'repositories/mock_content_repository.dart';
import 'repositories/practice_history_repository.dart';
import 'repositories/remote_content_repository.dart';
import 'theme/app_theme.dart';

void main() {
  final contentRepository = _createContentRepository();

  runApp(
    MultiProvider(
      providers: [
        Provider<ContentRepository>.value(value: contentRepository),
        ChangeNotifierProvider<PracticeHistoryRepository>(
          create: (_) => SharedPreferencesPracticeHistoryRepository(),
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
        title: '静',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MeditationApp(),
      ),
    ),
  );
}

ContentRepository _createContentRepository() {
  const useRemoteContent = bool.fromEnvironment('USE_REMOTE_CONTENT');
  const remoteBaseUrl = String.fromEnvironment('CONTENT_API_BASE_URL');

  if (useRemoteContent) {
    final normalizedBaseUrl = remoteBaseUrl.trim().isNotEmpty
        ? remoteBaseUrl.trim()
        : 'http://127.0.0.1:3000';

    return RemoteContentRepository(baseUrl: normalizedBaseUrl);
  }

  return MockContentRepository();
}
