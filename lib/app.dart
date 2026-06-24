import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/player_provider.dart';
import 'screens/home_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/player_screen.dart';
import 'screens/breathing_screen.dart';
import 'screens/sleep_screen.dart';
import 'screens/profile_screen.dart';
import 'theme/app_colors.dart';
import 'widgets/bottom_nav.dart';

class MeditationApp extends StatelessWidget {
  const MeditationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppShell();
  }
}

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final currentIndex = context.watch<NavigationProvider>().currentIndex;
    final player = context.watch<PlayerProvider>();

    // Player screen shown as overlay when playing
    if (player.isPlaying || player.position > Duration.zero) {
      return const PlayerScreen();
    }

    return Scaffold(
      backgroundColor: _getBackground(currentIndex),
      body: Stack(
        children: [
          IndexedStack(
            index: currentIndex,
            children: const [
              HomeScreen(),
              ExploreScreen(),
              BreathingScreen(),
              SleepScreen(),
              ProfileScreen(),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomNav(currentIndex),
          ),
        ],
      ),
    );
  }

  Color _getBackground(int index) {
    if (index == 3) return AppColors.darkBgSleep;
    return AppColors.background;
  }

  Widget _buildBottomNav(int index) {
    if (index == 3) {
      return _DarkBottomNav(currentIndex: index);
    }
    return const BottomNav();
  }
}

class _DarkBottomNav extends StatelessWidget {
  final int currentIndex;
  const _DarkBottomNav({required this.currentIndex});

  static const _labels = ['首页', '探索', '呼吸', '睡眠', '我的'];

  @override
  Widget build(BuildContext context) {
    final nav = context.read<NavigationProvider>();
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 30, left: 22, right: 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.darkBgSleep.withAlpha(0),
            AppColors.darkBgSleep,
          ],
          stops: const [0.0, 0.4],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_labels.length, (i) {
          final isActive = currentIndex == i;
          return GestureDetector(
            onTap: () => nav.setIndex(i),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _labels[i],
                  style: TextStyle(
                    fontSize: 14,
                    color: isActive
                        ? AppColors.sleepAccent
                        : AppColors.white.withAlpha(115),
                  ),
                ),
                const SizedBox(height: 7),
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        isActive ? AppColors.sleepAccent : Colors.transparent,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
