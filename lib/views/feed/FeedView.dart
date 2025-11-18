import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:someone_talking/config/api_config.dart';

import '../../models/FeedModel.dart';
import '../../viewmodels/feed/FeedViewModel.dart';

class FeedView extends StatefulWidget {
  const FeedView({super.key});

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  String? userName;
  String? userPhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadFeeds();
    _loadUser();
  }

  Future<void> _loadFeeds() async {
    final prefs = await SharedPreferences.getInstance();
    final jwtToken = prefs.getString('jwtToken');
    if (jwtToken != null) {
      Provider.of<FeedViewModel>(context, listen: false).fetchFeeds(jwtToken);
    }
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? 'Você';
      userPhotoUrl = prefs.getString('userPhotoUrl');
    });
  }

  String getFullImageUrl(String? mediaUrl) {
    if (mediaUrl == null || mediaUrl.isEmpty) return '';
    if (mediaUrl.startsWith('http')) return mediaUrl;
    return '$apiUrl$mediaUrl';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        elevation: 0,
        title: const Text(
          'Feed',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: Column(
        children: [
          // Card de postagem estilo Facebook
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    // Foto do usuário
                    userPhotoUrl != null && userPhotoUrl!.isNotEmpty
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(userPhotoUrl!),
                            radius: 22,
                          )
                        : CircleAvatar(
                            backgroundColor: Colors.cyan,
                            radius: 22,
                            child: Text(
                              userName != null && userName!.isNotEmpty
                                  ? userName![0].toUpperCase()
                                  : 'V',
                              style: const TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),
                    const SizedBox(width: 12),
                    // Input desabilitado
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showCreatePostModal(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: const Text(
                            'No que você está pensando?',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Feed
          Expanded(
            child: Consumer<FeedViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (viewModel.error != null) {
                  return Center(
                      child: Text('Erro: ${viewModel.error}',
                          style: TextStyle(color: Colors.red, fontSize: 18)));
                }
                if (viewModel.feeds.isEmpty) {
                  return const Center(child: Text('Nenhuma publicação encontrada.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  itemCount: viewModel.feeds.length,
                  itemBuilder: (context, index) {
                    final FeedModel feed = viewModel.feeds[index];
                    return _buildPost(feed);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPost(FeedModel feed) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.cyan,
              child: Text(feed.user.name[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white)),
            ),
            title: Text(feed.user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              '${feed.createdAt.day.toString().padLeft(2, '0')}/${feed.createdAt.month.toString().padLeft(2, '0')}/${feed.createdAt.year}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          if (feed.mediaUrl != null && feed.mediaUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                getFullImageUrl(feed.mediaUrl),
                fit: BoxFit.cover,
                width: double.infinity,
                height: 220,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 220,
                  color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.broken_image, size: 48)),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(feed.caption, style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showCreatePostModal(BuildContext context) {
    final captionController = TextEditingController();
    File? imageFile;

    final parentContext = context;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                children: [
                  // Header do modal
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancelar',
                              style: TextStyle(color: Colors.grey, fontSize: 16)),
                        ),
                        const Text(
                          'Nova publicação',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        TextButton(
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            final jwtToken = prefs.getString('jwtToken');
                            final caption = captionController.text.trim();

                            if (jwtToken != null && (caption.isNotEmpty || imageFile != null)) {
                              await Provider.of<FeedViewModel>(parentContext, listen: false)
                                  .createFeed(caption, imageFile?.path, jwtToken);
                              Navigator.of(context).pop();
                              _loadFeeds();
                            } else {
                              ScaffoldMessenger.of(parentContext).showSnackBar(
                                const SnackBar(content: Text('Adicione uma legenda ou imagem!')),
                              );
                            }
                          },
                          child: const Text(
                            'Compartilhar',
                            style: TextStyle(
                                color: Colors.cyan, fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Campo de texto para legenda
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: captionController,
                              maxLines: null,
                              expands: true,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: const InputDecoration(
                                hintText: 'Escreva uma legenda...',
                                hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),

                          // Preview da imagem selecionada
                          if (imageFile != null) ...[
                            const SizedBox(height: 20),
                            Expanded(
                              flex: 3,
                              child: Stack(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.file(
                                        imageFile!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: GestureDetector(
                                      onTap: () => setModalState(() => imageFile = null),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.7),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Bottom section com opções
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.grey, width: 0.2)),
                    ),
                    child: Row(
                      children: [
                        // Botão para adicionar foto
                        GestureDetector(
                          onTap: () async {
                            final picker = ImagePicker();
                            final picked = await picker.pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 85,
                            );
                            if (picked != null) {
                              setModalState(() => imageFile = File(picked.path));
                            }
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: const Icon(
                              Icons.photo_library_outlined,
                              color: Colors.cyan,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),

                        // Botão para tirar foto
                        GestureDetector(
                          onTap: () async {
                            final picker = ImagePicker();
                            final picked = await picker.pickImage(
                              source: ImageSource.camera,
                              imageQuality: 85,
                            );
                            if (picked != null) {
                              setModalState(() => imageFile = File(picked.path));
                            }
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.cyan,
                              size: 24,
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Contador de caracteres
                        Text(
                          '${captionController.text.length}/280',
                          style: TextStyle(
                            color: captionController.text.length > 280 ? Colors.red : Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
