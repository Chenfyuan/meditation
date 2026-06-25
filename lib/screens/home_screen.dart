import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/home_data.dart';
import '../providers/home_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/player_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';
import '../widgets/page_status_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();

    if (homeProvider.isLoading && homeProvider.homeData == null) {
      return const PageStatusView.loading(message: '正在准备今日内容…');
    }

    if (homeProvider.errorMessage != null && homeProvider.homeData == null) {
      return PageStatusView.error(
        message: homeProvider.errorMessage!,
        onRetry: () {
          homeProvider.retry();
        },
      );
    }

    final homeData = homeProvider.homeData;
    if (homeData == null) {
      return PageStatusView.error(
        message: '首页内容暂时不可用',
        onRetry: () {
          homeProvider.retry();
        },
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final horizontalPadding = constraints.maxWidth >= 1100 ? 42.0 : 30.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
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
                      homeData.dateText,
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
                          fontSize: isWide ? 34 : 30,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        children: [
                          const TextSpan(text: '晚上好，'),
                          TextSpan(
                            text: homeData.greetingName,
                            style: const TextStyle(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      homeData.greetingLine,
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
                        flex: 6,
                        child: Column(
                          children: [
                            _buildRecommendationCard(
                              context,
                              homeData.featuredSession,
                              horizontalPadding: 0,
                            ),
                            const SizedBox(height: 18),
                            if (homeData.continueSession != null)
                              _buildContinueListening(
                                context,
                                homeData.continueSession!,
                                horizontalPadding: 0,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 5,
                        child: _buildTopicsSection(
                          context,
                          homeData.topicSummaries,
                          isWide: true,
                          horizontalPadding: 0,
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                _buildRecommendationCard(
                  context,
                  homeData.featuredSession,
                  horizontalPadding: horizontalPadding,
                ),
                const SizedBox(height: 18),
                if (homeData.continueSession != null)
                  _buildContinueListening(
                    context,
                    homeData.continueSession!,
                    horizontalPadding: horizontalPadding,
                  ),
                const SizedBox(height: 26),
                _buildTopicsSection(
                  context,
                  homeData.topicSummaries,
                  isWide: false,
                  horizontalPadding: horizontalPadding,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecommendationCard(
    BuildContext context,
    HomeSession session, {
    double horizontalPadding = 30,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: GestureDetector(
        onTap: () {
          context.read<PlayerProvider>().play(
            session.title,
            session.instructor,
            session.durationMinutes,
            audioUrl: session.audioUrl,
          );
        },
        child: Container(
          width: double.infinity,
          height: 222,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.meditationGradientFor(session.themeKey),
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
                        horizontal: 14,
                        vertical: 7,
                      ),
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
                      session.title,
                      style: AppFonts.serif(
                        fontSize: 27,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      '${session.durationMinutes} 分钟 · ${session.subtitle}',
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
                    child: Icon(
                      Icons.play_arrow,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinueListening(
    BuildContext context,
    ContinueSession session, {
    double horizontalPadding = 30,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: GestureDetector(
        onTap: () {
          context.read<PlayerProvider>().play(
            session.title,
            session.instructor,
            session.durationMinutes,
            audioUrl: session.audioUrl,
          );
        },
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
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppColors.meditationGradientFor(session.themeKey),
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
                      session.title,
                      style: AppFonts.serif(
                        fontSize: 17,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                session.remainingLabel,
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
      ),
    );
  }

  Widget _buildTopicsSection(
    BuildContext context,
    List<TopicSummary> topics, {
    required bool isWide,
    required double horizontalPadding,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  style: AppFonts.sans(fontSize: 13, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth >= 760 ? 4 : 2;
              final childAspectRatio = isWide ? 1.55 : 2.2;

              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: childAspectRatio,
                children: topics.map((t) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
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
                            color: AppColors.accentForTheme(t.themeKey),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              t.name,
                              style: AppFonts.serif(
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${t.sessionCount} 个练习',
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
              );
            },
          ),
        ],
      ),
    );
  }
}
