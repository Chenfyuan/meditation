import 'package:flutter/material.dart';
import '../theme/app_fonts.dart';
import '../theme/app_colors.dart';

class SleepScreen extends StatelessWidget {
  const SleepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF3A2F2A),
            Color(0xFF251D19),
            Color(0xFF1B1512),
          ],
          stops: [0.0, 0.6, 1.0],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '晚安时光',
                      style: AppFonts.sans(
                        fontSize: 13,
                        letterSpacing: 2,
                        color: AppColors.white.withAlpha(140),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '准备入睡了吗？',
                      style: AppFonts.serif(
                        fontSize: 29,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFF7EFE5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              // Sleep story card
              _buildSleepStoryCard(),
              const SizedBox(height: 26),
              // Ambient sounds
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '环境音景',
                      style: AppFonts.sans(
                        fontSize: 13,
                        letterSpacing: 1,
                        color: AppColors.white.withAlpha(140),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildAmbientSoundsRow(),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // List items
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    _buildSleepListItem(
                      '海浪轻语',
                      '声景 · 30 分钟',
                      const [Color(0xFF7A92A0), Color(0xFF4A5D68)],
                    ),
                    _buildSleepListItem(
                      '星空之下',
                      '睡前故事 · 18 分钟',
                      const [Color(0xFF6A5E7A), Color(0xFF3E3550)],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSleepStoryCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        height: 188,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6A5444), Color(0xFF3C2D24)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x99000000),
              blurRadius: 36,
              offset: Offset(0, 18),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -50,
              right: -30,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentRose.withAlpha(46),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(41),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      '睡眠故事',
                      style: AppFonts.sans(
                        fontSize: 12,
                        letterSpacing: 2,
                        color: Colors.white.withAlpha(204),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '雨夜森林',
                    style: AppFonts.serif(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '轻柔雨声 · 45 分钟',
                    style: AppFonts.sans(
                      fontSize: 13,
                      color: Colors.white.withAlpha(191),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 24,
              bottom: 24,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(235),
                ),
                child: const Center(
                  child: Icon(Icons.play_arrow,
                      color: Color(0xFF3C2D24), size: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmbientSoundsRow() {
    final sounds = [
      ('雨声', const [Color(0xFF7A8A6A), Color(0xFF4D5A40)], true),
      ('海浪', const [Color(0xFF7A92A0), Color(0xFF4A5D68)], false),
      ('篝火', const [Color(0xFFC08D62), Color(0xFF8A5E3E)], false),
      ('白噪', const [Color(0xFF8A8278), Color(0xFF56504A)], false),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: sounds.map((s) {
        return Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: s.$2,
                ),
                border: s.$3
                    ? Border.all(
                        color: AppColors.white.withAlpha(128), width: 1.5)
                    : null,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              s.$1,
              style: AppFonts.sans(
                fontSize: 13,
                color: s.$3
                    ? AppColors.white.withAlpha(204)
                    : AppColors.white.withAlpha(140),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSleepListItem(
      String title, String subtitle, List<Color> colors) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.white.withAlpha(20), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFonts.serif(
                    fontSize: 17,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: AppFonts.sans(
                    fontSize: 12,
                    color: AppColors.white.withAlpha(128),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '播放',
            style: AppFonts.sans(
              fontSize: 12,
              color: AppColors.sleepAccent.withAlpha(230),
            ),
          ),
        ],
      ),
    );
  }
}
