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
import 'widgets/desktop_navigation_panel.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/mini_player_bar.dart';

class MeditationApp extends StatelessWidget {
  const MeditationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppShell();
  }
}

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  static const _tabletBreakpoint = 700.0;
  static const _desktopBreakpoint = 1080.0;

  @override
  Widget build(BuildContext context) {
    final currentIndex = context.watch<NavigationProvider>().currentIndex;
    final player = context.watch<PlayerProvider>();
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isDesktop = width >= _desktopBreakpoint;
        final isTablet = width >= _tabletBreakpoint;

        if (isDesktop) {
          return _buildDesktopShell(currentIndex, player);
        }

        return _buildCompactShell(
          currentIndex: currentIndex,
          player: player,
          maxWidth: isTablet ? 820 : 430,
          miniPlayerBottom: 86,
        );
      },
    );
  }

  Color _getBackground(int index) {
    if (index == 3) return AppColors.darkBgSleep;
    return AppColors.background;
  }

  Widget _buildCompactShell({
    required int currentIndex,
    required PlayerProvider player,
    required double maxWidth,
    required double miniPlayerBottom,
  }) {
    return Container(
      color: _getBackground(currentIndex),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: _buildPageStack(
            currentIndex: currentIndex,
            player: player,
            showBottomNav: true,
            miniPlayerBottom: miniPlayerBottom,
            contentBorderRadius: BorderRadius.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopShell(int currentIndex, PlayerProvider player) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF7F1E8), Color(0xFFEEE4D7)],
        ),
      ),
      child: SafeArea(
        minimum: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1380),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(width: 248, child: DesktopNavigationPanel()),
                const SizedBox(width: 24),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getBackground(currentIndex),
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 40,
                          offset: Offset(0, 20),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildPageStack(
                      currentIndex: currentIndex,
                      player: player,
                      showBottomNav: false,
                      miniPlayerBottom: 24,
                      contentBorderRadius: BorderRadius.circular(40),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageStack({
    required int currentIndex,
    required PlayerProvider player,
    required bool showBottomNav,
    required double miniPlayerBottom,
    required BorderRadius contentBorderRadius,
  }) {
    return Stack(
      children: [
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
          bottomNavigationBar: showBottomNav
              ? _buildBottomNav(currentIndex)
              : null,
        ),
        if (player.hasActiveSession && player.isExpanded)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: contentBorderRadius,
              child: const PlayerScreen(),
            ),
          ),
        if (player.hasActiveSession && !player.isExpanded)
          Positioned(
            left: 16,
            right: 16,
            bottom: miniPlayerBottom,
            child: const MiniPlayerBar(),
          ),
      ],
    );
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
