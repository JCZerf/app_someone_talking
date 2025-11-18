import 'UsersModel.dart';

class FeedCommentModel {
  final String id;
  final String text;
  final User user;
  final DateTime createdAt;

  FeedCommentModel({
    required this.id,
    required this.text,
    required this.user,
    required this.createdAt,
  });

  factory FeedCommentModel.fromJson(Map<String, dynamic> json) {
    return FeedCommentModel(
      id: json['id'],
      text: json['text'],
      user: User.fromJson(json['user']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
