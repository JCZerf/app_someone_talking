import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../config/api_config.dart';
import '../models/FeedModel.dart';

class FeedService {
  Future<List<FeedModel>> getFeeds(String token) async {
    final res = await http.get(
      Uri.parse('$apiUrl/feeds'),
      headers: {'Authorization': 'Bearer $token'},
    );
    debugPrint('getFeeds response: ${res.body}');
    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      return data.map((e) => FeedModel.fromJson(e)).toList();
    }
    throw Exception('Erro ao buscar feeds');
  }

  Future<FeedModel> getFeedById(String id, String token) async {
    final res = await http.get(
      Uri.parse('$apiUrl/feeds/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    debugPrint('getFeedById response: ${res.body}');
    if (res.statusCode == 200) {
      return FeedModel.fromJson(json.decode(res.body));
    }
    throw Exception('Feed não encontrado');
  }

  Future<FeedModel> createFeed(String caption, String? imagePath, String token) async {
    var uri = Uri.parse('$apiUrl/feeds');
    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['caption'] = caption;
    if (imagePath != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        imagePath,
        contentType: MediaType('image', 'jpeg'),
      ));
    }
    final streamedResponse = await request.send();
    final res = await http.Response.fromStream(streamedResponse);
    if (res.statusCode == 201) {
      return FeedModel.fromJson(json.decode(res.body));
    }
    throw Exception('Erro ao criar feed');
  }

  Future<FeedModel> updateFeed(
    String id,
    String caption,
    String token, {
    bool removeImage = false,
    String? imagePath,
  }) async {
    if (imagePath != null) {
      var uri = Uri.parse('$apiUrl/feeds/$id');
      var request = http.MultipartRequest('PUT', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['caption'] = caption;
      if (removeImage) request.fields['removeImage'] = 'true';
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        imagePath,
        contentType: MediaType('image', 'jpeg'),
      ));
      final streamedResponse = await request.send();
      final res = await http.Response.fromStream(streamedResponse);
      if (res.statusCode == 200) {
        return FeedModel.fromJson(json.decode(res.body));
      }
      throw Exception('Erro ao atualizar feed');
    } else {
      final body = {
        'caption': caption,
        if (removeImage) 'removeImage': true,
      };
      final res = await http.put(
        Uri.parse('$apiUrl/feeds/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );
      if (res.statusCode == 200) {
        return FeedModel.fromJson(json.decode(res.body));
      }
      throw Exception('Erro ao atualizar feed');
    }
  }

  Future<void> deleteFeed(String id, String token) async {
    final res = await http.delete(
      Uri.parse('$apiUrl/feeds/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) {
      throw Exception('Erro ao remover feed');
    }
  }
}
