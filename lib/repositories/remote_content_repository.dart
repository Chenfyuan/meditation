import '../models/home_data.dart';
import '../models/meditation.dart';
import '../models/sleep_content.dart';
import '../models/user_stats.dart';
import '../services/api_client.dart';
import '../services/api_exception.dart';
import 'content_repository.dart';

class RemoteContentRepository implements ContentRepository {
  final ApiClient _apiClient;

  RemoteContentRepository({required String baseUrl, ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient(baseUrl: baseUrl);

  @override
  Future<HomeData> fetchHomeData() async {
    final json = await _apiClient.getJson('/home');
    if (json is! Map) {
      throw const ApiException('首页接口返回格式不正确');
    }
    return HomeData.fromJson(Map<String, dynamic>.from(json));
  }

  @override
  Future<List<Meditation>> fetchMeditations({
    String? category,
    String? query,
  }) async {
    final queryParameters = <String, String>{};
    if (category != null && category.isNotEmpty && category != '全部') {
      queryParameters['category'] = category;
    }
    if (query != null && query.trim().isNotEmpty) {
      queryParameters['q'] = query.trim();
    }

    final json = await _apiClient.getJson(
      '/meditations',
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );

    if (json is! List) {
      throw const ApiException('探索接口返回格式不正确');
    }

    return json
        .map((item) => Meditation.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  @override
  Future<SleepContent> fetchSleepContent() async {
    final json = await _apiClient.getJson('/sleep');
    if (json is! Map) {
      throw const ApiException('睡眠接口返回格式不正确');
    }
    return SleepContent.fromJson(Map<String, dynamic>.from(json));
  }

  @override
  Future<UserStats> fetchUserStats() async {
    final json = await _apiClient.getJson('/user/stats');
    if (json is! Map) {
      throw const ApiException('统计接口返回格式不正确');
    }
    return UserStats.fromJson(Map<String, dynamic>.from(json));
  }
}
