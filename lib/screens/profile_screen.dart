import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_stats.dart';
import '../providers/profile_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';
import '../widgets/page_status_view.dart';
import '../widgets/weekly_chart.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();

    if (profileProvider.isLoading && profileProvider.userStats == null) {
      return const PageStatusView.loading(message: '正在整理你的旅程数据…');
    }

    if (profileProvider.errorMessage != null &&
        profileProvider.userStats == null) {
      return PageStatusView.error(
        message: profileProvider.errorMessage!,
        onRetry: () {
          profileProvider.retry();
        },
      );
    }

    final stats = profileProvider.userStats;
    if (stats == null) {
      return PageStatusView.error(
        message: '个人统计暂时不可用',
        onRetry: () {
          profileProvider.retry();
        },
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final horizontalPadding = constraints.maxWidth >= 1100 ? 42.0 : 30.0;

        return SingleChildScrollView(
          padding: EdgeInsets.only(bottom: isWide ? 34 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: isWide ? 42 : 60),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '我的旅程',
                      style: AppFonts.serif(
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '每一次静心，都在累积',
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
              if (isWide)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: _buildStreakCard(stats, horizontalPadding: 0),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 6,
                        child: Column(
                          children: [
                            _buildStatsRow(stats, horizontalPadding: 0),
                            const SizedBox(height: 16),
                            _buildWeeklySection(stats, horizontalPadding: 0),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                _buildStreakCard(stats),
                const SizedBox(height: 14),
                _buildStatsRow(stats),
                const SizedBox(height: 16),
                _buildWeeklySection(stats),
              ],
              const SizedBox(height: 18),
              _buildAchievements(horizontalPadding: horizontalPadding),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStreakCard(UserStats stats, {double horizontalPadding = 30}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE0BD97), Color(0xFFB8865F)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x8C966945),
              blurRadius: 38,
              offset: Offset(0, 18),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -50,
              right: -40,
              child: Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(41),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '连续冥想',
                    style: AppFonts.sans(
                      fontSize: 13,
                      letterSpacing: 2,
                      color: Colors.white.withAlpha(217),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${stats.streakDays}',
                        style: AppFonts.sans(
                          fontSize: 54,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '天',
                        style: AppFonts.serif(
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '本周已完成 ${stats.weeklyCompleted} 次练习',
                    style: AppFonts.sans(
                      fontSize: 13,
                      color: Colors.white.withAlpha(204),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(UserStats stats, {double horizontalPadding = 30}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        children: [
          Expanded(child: _buildStatBox('总时长', '${stats.totalMinutes}', '分钟')),
          const SizedBox(width: 14),
          Expanded(child: _buildStatBox('累计练习', '${stats.totalSessions}', '次')),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, String unit) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x0D383127)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppFonts.sans(fontSize: 13, color: AppColors.textTertiary),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: AppFonts.sans(
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: AppFonts.serif(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySection(UserStats stats, {double horizontalPadding = 30}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0x0D383127)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '本周',
                  style: AppFonts.serif(
                    fontSize: 17,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '分钟',
                  style: AppFonts.sans(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 110,
              child: WeeklyChart(data: stats.weeklyMinutes),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievements({double horizontalPadding = 30}) {
    final achievements = [
      ('七', '七日坚持', const [Color(0xFFE0BD97), Color(0xFFC49A72)], true),
      ('晨', '早起鸟', const [Color(0xFFC1C4A2), Color(0xFF94A07A)], true),
      ('静', '静心者', <Color>[], false),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: achievements.map((a) {
          return Column(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: a.$4
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: a.$3,
                        )
                      : null,
                  color: a.$4 ? null : AppColors.cardBackground,
                  border: a.$4
                      ? null
                      : Border.all(
                          color: const Color(0xFFCBBFAA),
                          width: 1.5,
                          strokeAlign: BorderSide.strokeAlignInside,
                        ),
                ),
                child: Center(
                  child: Text(
                    a.$1,
                    style: AppFonts.serif(
                      fontSize: 20,
                      color: a.$4 ? Colors.white : const Color(0xFFBDB09C),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 9),
              Text(
                a.$2,
                style: AppFonts.sans(
                  fontSize: 12,
                  color: a.$4
                      ? AppColors.textSecondary
                      : const Color(0xFFBDB09C),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
