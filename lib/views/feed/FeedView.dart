import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:someone_talking/config/api_config.dart';
import 'package:someone_talking/viewmodels/feed/FeedLikeViewModel.dart';

import '../../models/FeedModel.dart';
import '../../viewmodels/feed/FeedViewModel.dart';

class FeedView extends StatefulWidget {
  const FeedView({super.key});

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  String? userId;
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
      await Provider.of<FeedViewModel>(context, listen: false).fetchFeeds(jwtToken);
      final feeds = Provider.of<FeedViewModel>(context, listen: false).feeds;

      feeds.sort((a, b) {
        final dateCompare = b.createdAt.compareTo(a.createdAt);
        if (dateCompare != 0) return dateCompare;
        return b.likeCount.compareTo(a.likeCount);
      });
    }
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
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
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.cyan.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                child: Row(
                  children: [
                    userPhotoUrl != null && userPhotoUrl!.isNotEmpty
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(getFullImageUrl(userPhotoUrl)),
                            radius: 22,
                          )
                        : CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 22,
                            child: Text(
                              userName != null && userName!.isNotEmpty
                                  ? userName![0].toUpperCase()
                                  : 'V',
                              style: const TextStyle(color: Colors.cyan, fontSize: 20),
                            ),
                          ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showCreatePostModal(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white),
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
    final isMyPost = userId != null && feed.user.id == userId;
    final hasLiked = feed.likedByMe;

    const Color appCyan = Colors.cyan;
    const Color appBlack = Colors.black87;
    const Color appGrey = Colors.black54;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.cyan.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            child: Row(
              children: [
                feed.user.profilePhotoUrl.isNotEmpty
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(getFullImageUrl(feed.user.profilePhotoUrl)),
                        radius: 20,
                      )
                    : CircleAvatar(
                        backgroundColor: appCyan,
                        radius: 20,
                        child: Text(
                          feed.user.name.isNotEmpty ? feed.user.name[0].toUpperCase() : 'U',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feed.user.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: appBlack,
                        ),
                      ),
                      Text(
                        '${feed.createdAt.day.toString().padLeft(2, '0')}/${feed.createdAt.month.toString().padLeft(2, '0')}/${feed.createdAt.year}',
                        style: const TextStyle(fontSize: 11, color: appGrey),
                      ),
                    ],
                  ),
                ),
                if (isMyPost)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz, color: appGrey), //
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onSelected: (value) async {
                      if (value == 'edit') {
                        _showEditPostModal(context, feed);
                      } else if (value == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Apagar publicação'),
                            content: const Text('Tem certeza que deseja apagar esta publicação?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text('Apagar', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          final prefs = await SharedPreferences.getInstance();
                          final jwtToken = prefs.getString('jwtToken');
                          if (jwtToken != null) {
                            await Provider.of<FeedViewModel>(context, listen: false)
                                .deleteFeed(feed.id, jwtToken);
                            _loadFeeds();
                          }
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                          value: 'edit',
                          child: Row(children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Editar')
                          ])),
                      const PopupMenuItem(
                          value: 'delete',
                          child: Row(children: [
                            Icon(Icons.delete, color: Colors.red, size: 18),
                            SizedBox(width: 8),
                            Text('Apagar', style: TextStyle(color: Colors.red))
                          ])),
                    ],
                  )
              ],
            ),
          ),
          if (feed.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 12.0),
              child: Text(
                feed.caption,
                style: const TextStyle(fontSize: 15, color: appBlack, height: 1.4),
              ),
            ),
          if (feed.mediaUrl != null && feed.mediaUrl!.isNotEmpty)
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 400),
              child: Image.network(
                getFullImageUrl(feed.mediaUrl),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey[100],
                  child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: [
                // Botão Like
                Consumer<FeedLikeViewModel>(
                  builder: (context, likeViewModel, child) {
                    return IconButton(
                      icon: Icon(
                        hasLiked ? Icons.favorite : Icons.favorite_border,
                        color: hasLiked ? Colors.red : appBlack,
                        size: 26,
                      ),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        final jwtToken = prefs.getString('jwtToken');
                        if (jwtToken != null && userId != null) {
                          if (hasLiked) {
                            await likeViewModel.unlikeFeed(feed.id, userId!, jwtToken);
                          } else {
                            await likeViewModel.likeFeed(feed.id, userId!, jwtToken);
                          }
                          _loadFeeds();
                        }
                      },
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline, color: appBlack, size: 24),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined, color: appBlack, size: 24),
                  onPressed: () {},
                ),
                const Spacer(),
                if (feed.likeCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Text(
                      '${feed.likeCount} curtidas',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: appCyan,
                  child: const Icon(Icons.person, size: 16, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      'Adicione um comentário...',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Enviar',
                  style: TextStyle(
                    color: appCyan.withOpacity(0.5),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                )
              ],
            ),
          ),
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

  void _showEditPostModal(BuildContext context, FeedModel feed) {
    final captionController = TextEditingController(text: feed.caption);
    String? imageUrl = feed.mediaUrl;
    File? newImageFile;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                        ),
                        const Text('Editar publicação',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                        TextButton(
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            final jwtToken = prefs.getString('jwtToken');
                            final caption = captionController.text.trim();
                            if (jwtToken != null && caption.isNotEmpty) {
                              await Provider.of<FeedViewModel>(this.context, listen: false)
                                  .updateFeed(
                                feed.id,
                                caption,
                                jwtToken,
                                removeImage: (imageUrl == null && newImageFile == null),
                                imagePath: newImageFile?.path,
                              );
                              Navigator.of(context).pop();
                              _loadFeeds();
                            }
                          },
                          child: const Text('Salvar',
                              style: TextStyle(color: Colors.cyan, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: captionController,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'Edite sua legenda...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (newImageFile != null)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              newImageFile!,
                              width: double.infinity,
                              height: 180,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  newImageFile = null;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(8),
                                child: const Icon(Icons.delete, color: Colors.white, size: 22),
                              ),
                            ),
                          ),
                        ],
                      )
                    else if (imageUrl != null && (imageUrl?.isNotEmpty ?? false))
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              getFullImageUrl(imageUrl),
                              width: double.infinity,
                              height: 180,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  imageUrl = null;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(8),
                                child: const Icon(Icons.delete, color: Colors.white, size: 22),
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // Botão para selecionar nova imagem da galeria
                        GestureDetector(
                          onTap: () async {
                            final picker = ImagePicker();
                            final picked = await picker.pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 85,
                            );
                            if (picked != null) {
                              setModalState(() {
                                newImageFile = File(picked.path);
                                imageUrl = null; // Oculta imagem antiga
                              });
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
                              setModalState(() {
                                newImageFile = File(picked.path);
                                imageUrl = null;
                              });
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
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
