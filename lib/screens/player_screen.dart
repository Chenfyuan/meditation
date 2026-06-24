import 'package:flutter/material.dart';
import '../theme/app_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/player_orb.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final posMin = player.position.inMinutes.toString().padLeft(2, '0');
    final posSec = (player.position.inSeconds % 60).toString().padLeft(2, '0');
    final durMin = player.duration.inMinutes.toString().padLeft(2, '0');
    final durSec = (player.duration.inSeconds % 60).toString().padLeft(2, '0');

    return Material(
      type: MaterialType.transparency,
      child: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF5A463A),
            Color(0xFF33271F),
            Color(0xFF241B15),
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            // Glow behind orb
            Positioned(
              top: 90,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 340,
                  height: 340,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFCAA074).withAlpha(120),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.68],
                    ),
                  ),
                ),
              ),
            ),
            Column(
              children: [
                // Top bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.keyboard_arrow_down,
                          color: AppColors.white, size: 24),
                      Text(
                        '正在播放',
                        style: AppFonts.sans(
                          fontSize: 13,
                          letterSpacing: 3,
                          color: AppColors.white.withAlpha(179),
                        ),
                      ),
                      const Icon(Icons.more_horiz,
                          color: AppColors.white, size: 24),
                    ],
                  ),
                ),
                const SizedBox(height: 64),
                // Orb
                PlayerOrb(isPlaying: player.isPlaying),
                const SizedBox(height: 54),
                // Title
                Text(
                  player.currentTitle,
                  style: AppFonts.serif(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${player.currentInstructor} · 引导冥想',
                  style: AppFonts.sans(
                    fontSize: 14,
                    color: AppColors.white.withAlpha(166),
                  ),
                ),
                const SizedBox(height: 40),
                // Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: Column(
                    children: [
                      SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 4,
                          activeTrackColor: AppColors.white,
                          inactiveTrackColor: AppColors.white.withAlpha(51),
                          thumbColor: Colors.white,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6.5),
                          overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 14),
                        ),
                        child: Slider(
                          value: player.progress.clamp(0.0, 1.0),
                          onChanged: (v) => player.seekTo(v),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$posMin:$posSec',
                              style: AppFonts.sans(
                                fontSize: 13,
                                color: AppColors.white.withAlpha(153),
                              ),
                            ),
                            Text(
                              '$durMin:$durSec',
                              style: AppFonts.sans(
                                fontSize: 13,
                                color: AppColors.white.withAlpha(153),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 34),
                // Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.skip_previous,
                        color: AppColors.white.withAlpha(217), size: 32),
                    const SizedBox(width: 40),
                    GestureDetector(
                      onTap: player.togglePlay,
                      child: Container(
                        width: 74,
                        height: 74,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x66000000),
                              blurRadius: 28,
                              offset: Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            player.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: AppColors.darkBg,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                    Icon(Icons.skip_next,
                        color: AppColors.white.withAlpha(217), size: 32),
                  ],
                ),
                const Spacer(),
                // Ambient sound badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.white.withAlpha(31),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accentGreen,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '背景音景 · ${player.ambientSound}',
                        style: AppFonts.sans(
                          fontSize: 13,
                          color: AppColors.white.withAlpha(217),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 34),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }
}
