import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/practice_session_record.dart';
import '../models/sleep_content.dart';
import '../providers/player_provider.dart';
import '../providers/sleep_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';
import '../widgets/page_status_view.dart';

class SleepScreen extends StatelessWidget {
  const SleepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sleepProvider = context.watch<SleepProvider>();

    if (sleepProvider.isLoading && sleepProvider.sleepContent == null) {
      return _buildDarkState(
        child: const PageStatusView.loading(message: '正在准备晚安内容…', isDark: true),
      );
    }

    if (sleepProvider.errorMessage != null &&
        sleepProvider.sleepContent == null) {
      return _buildDarkState(
        child: PageStatusView.error(
          message: sleepProvider.errorMessage!,
          onRetry: () {
            sleepProvider.retry();
          },
          isDark: true,
        ),
      );
    }

    final sleepContent = sleepProvider.sleepContent;
    if (sleepContent == null) {
      return _buildDarkState(
        child: PageStatusView.error(
          message: '睡眠内容暂时不可用',
          onRetry: () {
            sleepProvider.retry();
          },
          isDark: true,
        ),
      );
    }

    return _buildDarkState(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          final horizontalPadding = constraints.maxWidth >= 1100 ? 42.0 : 30.0;

          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: isWide ? 34 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: isWide ? 32 : 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '晚安时光',
                        style: AppFonts.sans(
                          fontSize: 13,
                          letterSpacing: 2,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '准备入睡了吗？',
                        style: AppFonts.serif(
                          fontSize: 29,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                if (isWide)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: _buildSleepStoryCard(
                            context,
                            sleepContent.featuredStory,
                            height: 280,
                            horizontalPadding: 0,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildAmbientSection(
                                context,
                                sleepContent.ambientSounds,
                                horizontalPadding: 0,
                                isWide: true,
                              ),
                              const SizedBox(height: 24),
                              _buildSleepListSection(
                                context,
                                sleepContent.sleepItems,
                                horizontalPadding: 0,
                                isWide: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  _buildSleepStoryCard(context, sleepContent.featuredStory),
                  const SizedBox(height: 26),
                  _buildAmbientSection(
                    context,
                    sleepContent.ambientSounds,
                    horizontalPadding: horizontalPadding,
                    isWide: false,
                  ),
                  const SizedBox(height: 24),
                  _buildSleepListSection(
                    context,
                    sleepContent.sleepItems,
                    horizontalPadding: horizontalPadding,
                    isWide: false,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDarkState({required Widget child}) {
    return child;
  }

  Widget _buildSleepStoryCard(
    BuildContext context,
    SleepStory story, {
    double horizontalPadding = 30,
    double height = 188,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: GestureDetector(
        onTap: () {
          context.read<PlayerProvider>().play(
            story.title,
            '睡眠故事',
            story.durationMinutes,
            audioUrl: story.audioUrl,
            source: PracticeSource.sleepStory,
          );
        },
        child: Container(
          width: double.infinity,
          height: height,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.sleepGradientFor(story.themeKey),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 6,
                      ),
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
                      story.title,
                      style: AppFonts.serif(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      story.metadata,
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
                    child: Icon(
                      Icons.play_arrow,
                      color: Color(0xFF3C2D24),
                      size: 24,
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

  Widget _buildAmbientSection(
    BuildContext context,
    List<AmbientSound> sounds, {
    required double horizontalPadding,
    required bool isWide,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: const Color(0x0D383127)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '环境音景',
              style: AppFonts.sans(
                fontSize: 13,
                letterSpacing: 1,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 16),
            if (isWide)
              Wrap(
                spacing: 12,
                runSpacing: 14,
                children: sounds.map((sound) {
                  return SizedBox(
                    width: 112,
                    child: _buildAmbientSoundItem(context, sound),
                  );
                }).toList(),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: sounds
                    .map((sound) => _buildAmbientSoundItem(context, sound))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmbientSoundItem(BuildContext context, AmbientSound sound) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        context.read<PlayerProvider>().play(
          sound.title,
          '自然音景',
          30,
          audioUrl: sound.audioUrl,
          source: PracticeSource.soundscape,
        );
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.sleepGradientFor(sound.themeKey),
              ),
              border: sound.isFeatured
                  ? Border.all(color: AppColors.primary, width: 1.5)
                  : null,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            sound.title,
            style: AppFonts.sans(
              fontSize: 13,
              color: sound.isFeatured
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepListSection(
    BuildContext context,
    List<SleepItem> items, {
    required double horizontalPadding,
    required bool isWide,
  }) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isWide)
          Text(
            '入睡列表',
            style: AppFonts.sans(
              fontSize: 13,
              letterSpacing: 1,
              color: AppColors.textTertiary,
            ),
          ),
        if (isWide) const SizedBox(height: 12),
        ...items.map((item) => _buildSleepListItem(context, item)),
      ],
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: isWide
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: const Color(0x0D383127)),
              ),
              child: content,
            )
          : content,
    );
  }

  Widget _buildSleepListItem(BuildContext context, SleepItem item) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        context.read<PlayerProvider>().play(
          item.title,
          item.type,
          item.durationMinutes,
          audioUrl: item.audioUrl,
          source: item.type == '睡前故事'
              ? PracticeSource.sleepStory
              : PracticeSource.soundscape,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: const Color(0x12383127), width: 1),
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
                  colors: AppColors.sleepGradientFor(item.themeKey),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppFonts.serif(
                      fontSize: 17,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.metadata,
                    style: AppFonts.sans(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '播放',
              style: AppFonts.sans(fontSize: 12, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
