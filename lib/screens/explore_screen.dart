import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/explore_provider.dart';
import '../providers/player_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';
import '../widgets/meditation_card.dart';
import '../widgets/page_status_view.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exploreProvider = context.watch<ExploreProvider>();
    final meditations = exploreProvider.meditations;

    if (exploreProvider.isLoading && meditations.isEmpty) {
      return const PageStatusView.loading(message: '正在探索静心内容…');
    }

    if (exploreProvider.errorMessage != null && meditations.isEmpty) {
      return PageStatusView.error(
        message: exploreProvider.errorMessage!,
        onRetry: () {
          exploreProvider.retry();
        },
      );
    }

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
                  '探索',
                  style: AppFonts.serif(
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '找到适合此刻的练习',
                  style: AppFonts.sans(
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x0F383127)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search,
                    color: AppColors.textTertiary,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      onChanged: exploreProvider.setSearchQuery,
                      cursorColor: AppColors.primary,
                      style: AppFonts.sans(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: '搜索冥想、声音…',
                        hintStyle: AppFonts.sans(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          color: AppColors.textTertiary,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 30),
              itemCount: exploreProvider.filters.length,
              separatorBuilder: (context, index) => const SizedBox(width: 9),
              itemBuilder: (context, i) {
                final filter = exploreProvider.filters[i];
                final isActive = filter == exploreProvider.selectedFilter;
                return GestureDetector(
                  onTap: () => exploreProvider.setFilter(filter),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary
                          : AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      filter,
                      style: AppFonts.sans(
                        fontSize: 13,
                        color: isActive
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                if (meditations.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 56),
                    child: Text(
                      '暂时没有匹配的内容，试试别的关键词。',
                      style: AppFonts.sans(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ...meditations.map((meditation) {
                  return MeditationCard(
                    meditation: meditation,
                    onTap: () {
                      context.read<PlayerProvider>().play(
                        meditation.title,
                        meditation.instructor,
                        meditation.durationMinutes,
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
