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
      return _wrapWithMaxWidth(const PlayerScreen(), AppColors.darkBgDeep);
    }

    return _wrapWithMaxWidth(
      Scaffold(
        backgroundColor: _getBackground(currentIndex),
        body: IndexedStack(
          index: currentIndex,
          children: const [
            HomeScreen(),
            ExploreScreen(),
            BreathingScreen(),
            SleepScreen(),
            ProfileScreen(),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(currentIndex),
      ),
      _getBackground(currentIndex),
    );
  }

  Widget _wrapWithMaxWidth(Widget child, Color bgColor) {
    return Container(
      color: bgColor,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: child,
        ),
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
      color: AppColors.darkBgSleep,
      padding: const EdgeInsets.only(top: 12, bottom: 24, left: 22, right: 22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_labels.length, (i) {
          final isActive = currentIndex == i;
          return GestureDetector(
            onTap: () => nav.setIndex(i),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                  const SizedBox(height: 6),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? AppColors.sleepAccent
                          : Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
