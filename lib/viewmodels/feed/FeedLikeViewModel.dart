import 'package:flutter/material.dart';

import '../../service/FeedLikeService.dart';

class FeedLikeViewModel extends ChangeNotifier {
  final FeedLikeService _service = FeedLikeService();
  bool isLiking = false;
  int likeCount = 0;

  Future<void> likeFeed(String feedId, String userId, String token) async {
    isLiking = true;
    notifyListeners();
    await _service.likeFeed(feedId, userId, token);
    isLiking = false;
    notifyListeners();
  }

  Future<void> unlikeFeed(String feedId, String userId, String token) async {
    isLiking = true;
    notifyListeners();
    await _service.unlikeFeed(feedId, userId, token);
    isLiking = false;
    notifyListeners();
  }

  Future<void> fetchLikeCount(String feedId, String token) async {
    likeCount = await _service.countLikes(feedId, token);
    notifyListeners();
  }
}
