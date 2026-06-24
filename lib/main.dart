import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/navigation_provider.dart';
import 'providers/player_provider.dart';
import 'providers/breathing_provider.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => BreathingProvider()),
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
