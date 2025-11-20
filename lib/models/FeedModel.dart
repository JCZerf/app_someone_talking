import 'FeedCommentModel.dart';
import 'FeedLikeModel.dart';
import 'UsersModel.dart';

class FeedModel {
  final String id;
  final String caption;
  final String? mediaUrl;
  final User user;
  final int likeCount;
  final bool likedByMe;
  final List<FeedLikeModel> likes;
  final List<FeedCommentModel> comments;
  final DateTime createdAt;
  final DateTime updatedAt;

  FeedModel({
    required this.id,
    required this.caption,
    this.mediaUrl,
    required this.user,
    required this.likeCount,
    required this.likedByMe,
    required this.likes,
    required this.comments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FeedModel.fromJson(Map<String, dynamic> json) {
    return FeedModel(
      id: json['id']?.toString() ?? '',
      caption: json['caption']?.toString() ?? '',
      mediaUrl: json['mediaUrl']?.toString(),
      user: json['user'] != null
          ? User.fromJson(json['user'])
          : User(
              id: '',
              name: '',
              password: '',
              email: '',
              birthDate: DateTime.now(),
              phone: '',
            ),
      likeCount: json['likeCount'] ?? 0,
      likedByMe: json['likedByMe'] ?? false,
      likes: (json['likes'] as List<dynamic>? ?? [])
          .map((e) => FeedLikeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      comments: (json['comments'] as List<dynamic>? ?? [])
          .map((e) => FeedCommentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
