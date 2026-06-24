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
      color: AppColors.background,
      padding: const EdgeInsets.only(top: 12, bottom: 24, left: 22, right: 22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_labels.length, (i) {
          final isActive = nav.currentIndex == i;
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
                    style: AppFonts.sans(
                      fontSize: 14,
                      color: isActive ? AppColors.primary : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
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
            ),
          );
        }),
      ),
    );
  }
}
