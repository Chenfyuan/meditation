import 'package:flutter/material.dart';
import '../theme/app_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/breathing_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/breathing_circle.dart';

class BreathingScreen extends StatelessWidget {
  const BreathingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final breathing = context.watch<BreathingProvider>();

    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.1),
          radius: 1.2,
          colors: [Color(0xFFF4EDE2), Color(0xFFE9E0D4)],
          stops: [0.0, 1.0],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 60),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '呼吸练习',
                    style: AppFonts.serif(
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '4 · 7 · 8 呼吸法 · 第 ${breathing.currentRound} / ${breathing.totalRounds} 轮',
                    style: AppFonts.sans(
                      fontSize: 15,
                      fontWeight: FontWeight.w300,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Breathing circle - takes flexible space
          Expanded(
            flex: 3,
            child: Center(
              child: BreathingCircle(
                label: breathing.phaseLabel,
                countdown: breathing.countdown,
                isRunning: breathing.isRunning,
              ),
            ),
          ),
          // Bottom section
          Text(
            breathing.phaseHint,
            style: AppFonts.sans(
              fontSize: 15,
              fontWeight: FontWeight.w300,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '剩余时间',
            style: AppFonts.sans(
              fontSize: 13,
              letterSpacing: 2,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            breathing.remainingFormatted,
            style: AppFonts.sans(
              fontSize: 44,
              fontWeight: FontWeight.w300,
              color: AppColors.textPrimary,
              letterSpacing: 1,
            ),
          ),
          const Spacer(flex: 1),
          // Pause/Start button
          GestureDetector(
            onTap: breathing.toggleRunning,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 34, vertical: 15),
              decoration: BoxDecoration(
                color: AppColors.dark,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    breathing.isRunning ? Icons.pause : Icons.play_arrow,
                    color: AppColors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    breathing.isRunning ? '暂停' : '开始',
                    style: AppFonts.sans(
                      fontSize: 15,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
