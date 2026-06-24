import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/navigation_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';

class DesktopNavigationPanel extends StatelessWidget {
  const DesktopNavigationPanel({super.key});

  static const _items = [
    (Icons.home_rounded, '首页'),
    (Icons.explore_rounded, '探索'),
    (Icons.air_rounded, '呼吸'),
    (Icons.nightlight_round_rounded, '睡眠'),
    (Icons.person_rounded, '我的'),
  ];

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight.withAlpha(245),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: const Color(0x12000000)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 34,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '静',
                  style: AppFonts.serif(
                    fontSize: 36,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '桌面静心空间',
                  style: AppFonts.sans(
                    fontSize: 13,
                    letterSpacing: 1.2,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          ...List.generate(_items.length, (index) {
            final item = _items[index];
            final isActive = nav.currentIndex == index;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => nav.setIndex(index),
                  borderRadius: BorderRadius.circular(22),
                  child: Ink(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      color: isActive
                          ? AppColors.primary.withAlpha(28)
                          : Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item.$1,
                          size: 20,
                          color: isActive
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          item.$2,
                          style: AppFonts.sans(
                            fontSize: 15,
                            fontWeight: isActive
                                ? FontWeight.w500
                                : FontWeight.w400,
                            color: isActive
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '慢下来',
                  style: AppFonts.serif(
                    fontSize: 20,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '桌面端会保留更宽的留白，让内容阅读和呼吸节奏都更从容。',
                  style: AppFonts.sans(
                    fontSize: 13,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
