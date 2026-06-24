import 'package:flutter/material.dart';
import '../theme/app_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import '../theme/app_colors.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  static const _labels = ['首页', '探索', '呼吸', '睡眠', '我的'];

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 30, left: 22, right: 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background.withAlpha(0),
            AppColors.background,
          ],
          stops: const [0.0, 0.4],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_labels.length, (i) {
          final isActive = nav.currentIndex == i;
          return GestureDetector(
            onTap: () => nav.setIndex(i),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _labels[i],
                  style: AppFonts.sans(
                    fontSize: 14,
                    color: isActive ? AppColors.primary : AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 7),
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? AppColors.primary : Colors.transparent,
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
