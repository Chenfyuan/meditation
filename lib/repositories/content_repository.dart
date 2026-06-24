import '../models/home_data.dart';
import '../models/meditation.dart';
import '../models/sleep_content.dart';
import '../models/user_stats.dart';

abstract class ContentRepository {
  Future<HomeData> fetchHomeData();

  Future<List<Meditation>> fetchMeditations({String? category, String? query});

  Future<SleepContent> fetchSleepContent();

  Future<UserStats> fetchUserStats();
}
