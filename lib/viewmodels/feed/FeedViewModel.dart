import 'package:flutter/material.dart';
import 'package:someone_talking/service/FeedService.dart';

import '../../models/FeedModel.dart';

class FeedViewModel extends ChangeNotifier {
  final FeedService _service = FeedService();
  List<FeedModel> feeds = [];
  FeedModel? selectedFeed;
  bool isLoading = false;
  String? error;

  Future<void> fetchFeeds(String token) async {
    isLoading = true;
    notifyListeners();
    try {
      feeds = await _service.getFeeds(token);
      debugPrint('Feeds recebidos: $feeds');
      error = null;
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> getFeedById(String id, String token) async {
    isLoading = true;
    notifyListeners();
    try {
      selectedFeed = await _service.getFeedById(id, token);
      error = null;
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<String?> createFeed(String caption, String? imagePath, String token) async {
    isLoading = true;
    notifyListeners();
    try {
      final newFeed = await _service.createFeed(caption, imagePath, token);
      feeds.add(newFeed);
      error = null;
      return newFeed.id;
    } catch (e) {
      error = e.toString();
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateFeed(
    String id,
    String caption,
    String token, {
    bool removeImage = false,
    String? imagePath,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      final updatedFeed = await _service.updateFeed(
        id,
        caption,
        token,
        removeImage: removeImage,
        imagePath: imagePath,
      );
      final index = feeds.indexWhere((f) => f.id == id);
      if (index != -1) feeds[index] = updatedFeed;
      error = null;
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteFeed(String id, String token) async {
    isLoading = true;
    notifyListeners();
    try {
      await _service.deleteFeed(id, token);
      feeds.removeWhere((f) => f.id == id);
      error = null;
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
