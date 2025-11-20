import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class FeedLikeService {
  Future<void> likeFeed(String feedId, String userId, String token) async {
    final res = await http.post(
      Uri.parse('$apiUrl/feeds/$feedId/likes'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'userId': userId}),
    );
    print('Like response: ${res.statusCode} - ${res.body}');
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('Erro ao dar like: ${res.body}');
    }
  }

  Future<void> unlikeFeed(String feedId, String userId, String token) async {
    final res = await http.delete(
      Uri.parse('$apiUrl/feeds/$feedId/likes'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'userId': userId}),
    );
    print('Like response: ${res.statusCode} - ${res.body}');
    if (res.statusCode != 200) {
      throw Exception('Erro ao remover like');
    }
  }

  Future<int> countLikes(String feedId, String token) async {
    final res = await http.get(
      Uri.parse('$apiUrl/feeds/$feedId/likes/count'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return data['count'] ?? 0;
    }
    throw Exception('Erro ao contar likes');
  }
}
