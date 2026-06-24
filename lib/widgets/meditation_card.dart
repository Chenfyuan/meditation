import 'package:flutter/material.dart';

import '../models/meditation.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';

class MeditationCard extends StatelessWidget {
  final Meditation meditation;
  final VoidCallback? onTap;
  final bool compact;

  const MeditationCard({
    super.key,
    required this.meditation,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0x10383127)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: meditation.gradientColors,
                  ),
                ),
                child: const Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Icon(
                      Icons.play_circle_fill_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                meditation.title,
                style: AppFonts.serif(
                  fontSize: 22,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                meditation.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.sans(
                  fontSize: 13,
                  height: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      meditation.instructor,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.sans(
                        fontSize: 13,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${meditation.durationMinutes} 分钟',
                    style: AppFonts.sans(
                      fontSize: 13,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0x12383127), width: 1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: meditation.gradientColors,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.white70,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meditation.title,
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${meditation.instructor} · ${meditation.subtitle}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${meditation.durationMinutes} 分钟',
                style: const TextStyle(fontSize: 13, color: AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
