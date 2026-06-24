import 'package:flutter/material.dart';
import '../theme/app_fonts.dart';
import 'package:provider/provider.dart';
import '../models/meditation.dart';
import '../providers/player_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/meditation_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _selectedFilter = '全部';
  static const _filters = ['全部', '放松', '专注', '睡眠', '呼吸'];

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedFilter == '全部'
        ? sampleMeditations
        : sampleMeditations
            .where((m) => m.category == _selectedFilter)
            .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x0F383127)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.textTertiary, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    '搜索冥想、声音…',
                    style: AppFonts.sans(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          // Filter chips
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 30),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 9),
              itemBuilder: (context, i) {
                final isActive = _filters[i] == _selectedFilter;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = _filters[i]),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary
                          : AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      _filters[i],
                      style: AppFonts.sans(
                        fontSize: 13,
                        color:
                            isActive ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Meditation list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: filtered.map((m) {
                return MeditationCard(
                  meditation: m,
                  onTap: () {
                    context
                        .read<PlayerProvider>()
                        .play(m.title, m.instructor, m.durationMinutes);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
