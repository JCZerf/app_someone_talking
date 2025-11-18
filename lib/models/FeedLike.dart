import 'UsersModel.dart';

class FeedLikeModel {
  final String id;
  final User user;
  final DateTime createdAt;

  FeedLikeModel({
    required this.id,
    required this.user,
    required this.createdAt,
  });

  factory FeedLikeModel.fromJson(Map<String, dynamic> json) {
    return FeedLikeModel(
      id: json['id'],
      user: User.fromJson(json['user']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
