import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

class ApiClient {
  final String baseUrl;
  final http.Client _httpClient;

  ApiClient({required this.baseUrl, http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  Future<dynamic> getJson(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final uri = _buildUri(path, queryParameters);

    try {
      final response = await _httpClient.get(
        uri,
        headers: const {'Accept': 'application/json'},
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException('请求失败，请稍后重试', statusCode: response.statusCode);
      }

      if (response.bodyBytes.isEmpty) {
        throw const ApiException('响应内容为空');
      }

      try {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } on FormatException {
        throw const ApiException('响应不是有效的 JSON');
      }
    } on SocketException {
      throw const ApiException('网络连接失败，请检查网络设置');
    } on http.ClientException catch (error) {
      throw ApiException('请求失败: ${error.message}');
    }
  }

  Uri _buildUri(String path, Map<String, String>? queryParameters) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final resolvedUri = Uri.parse(baseUrl).resolve(normalizedPath);
    if (queryParameters == null || queryParameters.isEmpty) {
      return resolvedUri;
    }
    return resolvedUri.replace(queryParameters: queryParameters);
  }
}
