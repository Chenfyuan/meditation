import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/sleep_content.dart';
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
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
            _buildSleepStoryCard(sleepContent.featuredStory),
            const SizedBox(height: 26),
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
                  _buildAmbientSoundsRow(sleepContent.ambientSounds),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: sleepContent.sleepItems.map((item) {
                  return _buildSleepListItem(item);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDarkState({required Widget child}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF3A2F2A), Color(0xFF251D19), Color(0xFF1B1512)],
          stops: [0.0, 0.6, 1.0],
        ),
      ),
      child: SafeArea(child: child),
    );
  }

  Widget _buildSleepStoryCard(SleepStory story) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        width: double.infinity,
        height: 188,
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
    );
  }

  Widget _buildAmbientSoundsRow(List<AmbientSound> sounds) {
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
                  colors: AppColors.sleepGradientFor(s.themeKey),
                ),
                border: s.isFeatured
                    ? Border.all(
                        color: AppColors.white.withAlpha(128),
                        width: 1.5,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              s.title,
              style: AppFonts.sans(
                fontSize: 13,
                color: s.isFeatured
                    ? AppColors.white.withAlpha(204)
                    : AppColors.white.withAlpha(140),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSleepListItem(SleepItem item) {
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
                  style: AppFonts.serif(fontSize: 17, color: AppColors.white),
                ),
                const SizedBox(height: 3),
                Text(
                  item.metadata,
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
