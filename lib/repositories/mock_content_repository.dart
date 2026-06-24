import '../models/home_data.dart';
import '../models/meditation.dart';
import '../models/sleep_content.dart';
import '../models/user_stats.dart';
import 'content_repository.dart';

class MockContentRepository implements ContentRepository {
  static const _networkDelay = Duration(milliseconds: 350);

  @override
  Future<HomeData> fetchHomeData() async {
    await Future<void>.delayed(_networkDelay);
    return HomeData(
      dateText: _buildDateText(DateTime.now()),
      greetingName: '林溪',
      greetingLine: '愿你今晚拥有平静的睡前时光',
      featuredSession: const HomeSession(
        id: 'home-featured-1',
        title: '海边的黄昏',
        subtitle: '舒缓放松',
        instructor: 'Sarah',
        durationMinutes: 10,
        themeKey: 'bronze',
      ),
      continueSession: const ContinueSession(
        id: 'home-continue-1',
        title: '雨林深处',
        instructor: 'Mei',
        durationMinutes: 12,
        remainingSeconds: 200,
        themeKey: 'sage',
      ),
      topicSummaries: const [
        TopicSummary(name: '放松', sessionCount: 12, themeKey: 'rose'),
        TopicSummary(name: '专注', sessionCount: 8, themeKey: 'sand'),
        TopicSummary(name: '睡眠', sessionCount: 15, themeKey: 'sage'),
        TopicSummary(name: '减压', sessionCount: 10, themeKey: 'bronze'),
      ],
    );
  }

  @override
  Future<List<Meditation>> fetchMeditations({
    String? category,
    String? query,
  }) async {
    await Future<void>.delayed(_networkDelay);

    final meditations = const [
      Meditation(
        id: 'meditation-1',
        title: '晨间唤醒',
        instructor: 'Sarah',
        subtitle: '平静开启一天',
        durationMinutes: 8,
        category: '放松',
        themeKey: 'sand',
      ),
      Meditation(
        id: 'meditation-2',
        title: '深度放松',
        instructor: 'Liam',
        subtitle: '释放身体紧张',
        durationMinutes: 15,
        category: '放松',
        themeKey: 'rose',
      ),
      Meditation(
        id: 'meditation-3',
        title: '专注当下',
        instructor: 'Mei',
        subtitle: '提升专注力',
        durationMinutes: 12,
        category: '专注',
        themeKey: 'sage',
      ),
      Meditation(
        id: 'meditation-4',
        title: '释放焦虑',
        instructor: 'Sarah',
        subtitle: '缓解日间压力',
        durationMinutes: 10,
        category: '减压',
        themeKey: 'bronze',
      ),
      Meditation(
        id: 'meditation-5',
        title: '身体扫描',
        instructor: 'Noah',
        subtitle: '睡前深度练习',
        durationMinutes: 20,
        category: '睡眠',
        themeKey: 'twilight',
      ),
    ];

    final normalizedCategory = category?.trim();
    final normalizedQuery = query?.trim().toLowerCase();

    return meditations
        .where((meditation) {
          final matchesCategory =
              normalizedCategory == null ||
              normalizedCategory.isEmpty ||
              normalizedCategory == '全部' ||
              meditation.category == normalizedCategory;

          final searchableText = [
            meditation.title,
            meditation.subtitle,
            meditation.instructor,
            meditation.category,
          ].join(' ').toLowerCase();

          final matchesQuery =
              normalizedQuery == null ||
              normalizedQuery.isEmpty ||
              searchableText.contains(normalizedQuery);

          return matchesCategory && matchesQuery;
        })
        .toList(growable: false);
  }

  @override
  Future<SleepContent> fetchSleepContent() async {
    await Future<void>.delayed(_networkDelay);
    return const SleepContent(
      featuredStory: SleepStory(
        id: 'sleep-featured-1',
        title: '雨夜森林',
        descriptor: '轻柔雨声',
        durationMinutes: 45,
        themeKey: 'cocoa',
      ),
      ambientSounds: [
        AmbientSound(
          id: 'ambient-1',
          title: '雨声',
          themeKey: 'moss',
          isFeatured: true,
        ),
        AmbientSound(id: 'ambient-2', title: '海浪', themeKey: 'ocean'),
        AmbientSound(id: 'ambient-3', title: '篝火', themeKey: 'fire'),
        AmbientSound(id: 'ambient-4', title: '白噪', themeKey: 'stone'),
      ],
      sleepItems: [
        SleepItem(
          id: 'sleep-item-1',
          title: '海浪轻语',
          type: '声景',
          durationMinutes: 30,
          themeKey: 'ocean',
        ),
        SleepItem(
          id: 'sleep-item-2',
          title: '星空之下',
          type: '睡前故事',
          durationMinutes: 18,
          themeKey: 'violet',
        ),
      ],
    );
  }

  @override
  Future<UserStats> fetchUserStats() async {
    await Future<void>.delayed(_networkDelay);
    return const UserStats(
      streakDays: 12,
      totalMinutes: 320,
      totalSessions: 28,
      weeklyCompleted: 5,
      weeklyMinutes: [14, 20, 10, 25, 18, 30, 8],
    );
  }

  String _buildDateText(DateTime date) {
    const weekdays = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
    final weekday = weekdays[date.weekday - 1];
    return '${date.month} 月 ${date.day} 日 · $weekday';
  }
}
