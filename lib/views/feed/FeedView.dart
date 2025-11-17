import 'package:flutter/material.dart';

class FeedView extends StatelessWidget {
  const FeedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
        backgroundColor: Colors.cyan,
      ),
      body: ListView(
        children: [
          _buildPost(
            user: 'john_doe',
            imageUrl: 'https://picsum.photos/400/300',
            description: 'Primeira publicação no feed!',
          ),
          _buildPost(
            user: 'jane_smith',
            imageUrl: 'https://picsum.photos/400/301',
            description: 'Curtindo o dia :)',
          ),
        ],
      ),
    );
  }

  Widget _buildPost({required String user, required String imageUrl, required String description}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(child: Text(user[0].toUpperCase())),
            title: Text(user),
          ),
          Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity, height: 200),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(description),
          ),
        ],
      ),
    );
  }
}
