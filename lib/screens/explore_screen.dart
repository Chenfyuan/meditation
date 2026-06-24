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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final horizontalPadding = constraints.maxWidth >= 1100 ? 42.0 : 30.0;
        final crossAxisCount = constraints.maxWidth >= 1280 ? 3 : 2;

        return SingleChildScrollView(
          padding: EdgeInsets.only(bottom: isWide ? 34 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: isWide ? 42 : 60),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildHeader()),
                          const SizedBox(width: 24),
                          SizedBox(
                            width: 280,
                            child: _buildSummaryCard(exploreProvider),
                          ),
                        ],
                      )
                    : _buildHeader(),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: _buildSearchBar(exploreProvider),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  itemCount: exploreProvider.filters.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 9),
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
              const SizedBox(height: 12),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: meditations.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 56),
                        child: Text(
                          '暂时没有匹配的内容，试试别的关键词。',
                          style: AppFonts.sans(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : isWide
                    ? GridView.builder(
                        itemCount: meditations.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 1.05,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemBuilder: (context, index) {
                          final meditation = meditations[index];
                          return MeditationCard(
                            meditation: meditation,
                            compact: true,
                            onTap: () {
                              context.read<PlayerProvider>().play(
                                meditation.title,
                                meditation.instructor,
                                meditation.durationMinutes,
                              );
                            },
                          );
                        },
                      )
                    : Column(
                        children: meditations.map((meditation) {
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
                        }).toList(),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
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
    );
  }

  Widget _buildSearchBar(ExploreProvider exploreProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x0F383127)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.textTertiary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: exploreProvider.setSearchQuery,
              cursorColor: AppColors.primary,
              style: AppFonts.sans(fontSize: 14, color: AppColors.textPrimary),
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
    );
  }

  Widget _buildSummaryCard(ExploreProvider exploreProvider) {
    final filterLabel = exploreProvider.selectedFilter == '全部'
        ? '全部主题'
        : exploreProvider.selectedFilter;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '当前探索',
            style: AppFonts.sans(
              fontSize: 12,
              letterSpacing: 1.6,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${exploreProvider.meditations.length} 个练习',
            style: AppFonts.serif(fontSize: 26, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            '主题：$filterLabel',
            style: AppFonts.sans(fontSize: 13, color: AppColors.textSecondary),
          ),
          if (exploreProvider.searchQuery.isNotEmpty) const SizedBox(height: 4),
          if (exploreProvider.searchQuery.isNotEmpty)
            Text(
              '关键词：${exploreProvider.searchQuery}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.sans(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}
