import 'package:flutter/material.dart';
import '../theme/app_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/player_provider.dart';
import '../theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '6 月 24 日 · 星期二',
                  style: AppFonts.sans(
                    fontSize: 13,
                    letterSpacing: 2,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: AppFonts.serif(
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    children: const [
                      TextSpan(text: '晚上好，'),
                      TextSpan(
                        text: '林溪',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '愿你今晚拥有平静的睡前时光',
                  style: AppFonts.sans(
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _buildRecommendationCard(context),
          const SizedBox(height: 18),
          _buildContinueListening(context),
          const SizedBox(height: 26),
          _buildTopics(context),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: GestureDetector(
        onTap: () {
          context.read<PlayerProvider>().play('海边的黄昏', 'Sarah', 10);
        },
        child: Container(
          width: double.infinity,
          height: 222,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE0BD97), Color(0xFFB8865F)],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x99966941),
                blurRadius: 40,
                offset: Offset(0, 20),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -70,
                right: -50,
                child: Container(
                  width: 210,
                  height: 210,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlpha(41),
                  ),
                ),
              ),
              Positioned(
                bottom: -90,
                left: -40,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlpha(26),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(56),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '今日推荐',
                        style: AppFonts.sans(
                          fontSize: 12,
                          letterSpacing: 2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '海边的黄昏',
                      style: AppFonts.serif(
                        fontSize: 27,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      '10 分钟 · 舒缓放松',
                      style: AppFonts.sans(
                        fontSize: 14,
                        color: Colors.white.withAlpha(217),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 26,
                bottom: 26,
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x40000000),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.play_arrow,
                        color: AppColors.primary, size: 28),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinueListening(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0x0D383127)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFC1C4A2), Color(0xFF94A07A)],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '继续聆听',
                    style: AppFonts.sans(
                      fontSize: 12,
                      letterSpacing: 1,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '雨林深处',
                    style: AppFonts.serif(
                      fontSize: 17,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '剩 03:20',
              style: AppFonts.sans(
                fontSize: 13,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.dark,
              ),
              child: const Center(
                child: Icon(Icons.play_arrow, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopics(BuildContext context) {
    final topics = [
      ('放松', '12 个练习', AppColors.accentRose),
      ('专注', '8 个练习', AppColors.primaryDark),
      ('睡眠', '15 个练习', AppColors.accentGreen),
      ('减压', '10 个练习', AppColors.primary),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '探索主题',
                style: AppFonts.serif(
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => context.read<NavigationProvider>().setIndex(1),
                child: Text(
                  '查看全部',
                  style: AppFonts.sans(
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.2,
            children: topics.map((t) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: t.$3,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          t.$1,
                          style: AppFonts.serif(
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          t.$2,
                          style: AppFonts.sans(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
