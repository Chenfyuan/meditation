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
    return const BottomNav();
  }
}
