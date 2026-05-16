import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vyra/core/theme/app_theme.dart';
import 'package:vyra/features/home/presentation/widgets/comments_bottom_sheet.dart';
import 'package:vyra/features/profile/presentation/screens/profile_screen.dart';
import 'package:vyra/features/profile/presentation/screens/profile_unknown_screen.dart';
import 'package:vyra/features/search/presentation/screens/search_screen.dart';
import 'package:vyra/services/post_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  final Set<String> _followingUsers = {};
  Set<String> _likedPosts = {};

  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _feedRevision = 0;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    try {
      final posts = await PostService().getFeedPosts();
      final likedIds = posts
          .where((p) => p['is_liked'] == true)
          .map((p) => p['id'] as String)
          .toSet();
      if (mounted) {
        setState(() {
          _posts = posts;
          _likedPosts = likedIds;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _timeAgo(String? createdAt) {
    if (createdAt == null) return 'Ahora';
    final date = DateTime.tryParse(createdAt);
    if (date == null) return 'Ahora';
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'Ahora';
  }

  String _extractUsername(Map<String, dynamic> post) {
    final profiles = post['profiles'] as Map<String, dynamic>?;
    final username = profiles?['username'] as String?;
    if (username != null && username.isNotEmpty) {
      return username.startsWith('@') ? username : '@$username';
    }
    return '@usuario';
  }

  String _extractAvatarLetter(Map<String, dynamic> post) {
    final profiles = post['profiles'] as Map<String, dynamic>?;
    final username = profiles?['username'] as String?;
    if (username != null && username.isNotEmpty) {
      return username[0].toUpperCase();
    }
    return 'U';
  }

  String? _extractAvatarUrl(Map<String, dynamic> post) {
    final profiles = post['profiles'] as Map<String, dynamic>?;
    final url = profiles?['avatar_url'] as String?;
    return (url != null && url.isNotEmpty) ? url : null;
  }

  String _extractImage(Map<String, dynamic> post) {
    final imageUrls = post['image_urls'] as List<dynamic>?;
    if (imageUrls != null && imageUrls.isNotEmpty) {
      return imageUrls.first as String;
    }
    return '';
  }

  String _extractTitle(Map<String, dynamic> post) {
    final desc = post['descripcion'] as String?;
    return desc ?? '';
  }

  void _toggleFollow(String username) {
    setState(() {
      if (_followingUsers.contains(username)) {
        _followingUsers.remove(username);
      } else {
        _followingUsers.add(username);
      }
    });
  }

  void _toggleLike(String postId) {
    final previouslyLiked = _likedPosts.contains(postId);
    setState(() {
      if (previouslyLiked) {
        _likedPosts.remove(postId);
      } else {
        _likedPosts.add(postId);
      }
      // Actualizar contador local optimista
      final index = _posts.indexWhere((p) => p['id'] == postId);
      if (index != -1) {
        final current = _posts[index]['likes_count'] as int? ?? 0;
        _posts[index] = {
          ..._posts[index],
          'likes_count': previouslyLiked ? current - 1 : current + 1,
        };
      }
    });

    // Llamar al backend en background
    PostService().toggleLike(postId).catchError((e) {
      // Revertir en caso de error
      if (mounted) {
        setState(() {
          if (previouslyLiked) {
            _likedPosts.add(postId);
          } else {
            _likedPosts.remove(postId);
          }
          final index = _posts.indexWhere((p) => p['id'] == postId);
          if (index != -1) {
            final current = _posts[index]['likes_count'] as int? ?? 0;
            _posts[index] = {
              ..._posts[index],
              'likes_count': previouslyLiked ? current + 1 : current - 1,
            };
          }
        });
      }
      return false;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryBlue),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadFeed,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_posts.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'Aún no hay publicaciones',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        key: ValueKey(_feedRevision),
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          return _buildFullScreenPost(_posts[index]);
        },
      ),
    );
  }

  Widget _buildFullScreenPost(Map<String, dynamic> post) {
    final postId = post['id'] as String? ?? '';
    final username = _extractUsername(post);
    final avatarLetter = _extractAvatarLetter(post);
    final avatarUrl = _extractAvatarUrl(post);
    final title = _extractTitle(post);
    final imageUrl = _extractImage(post);
    final timeAgo = _timeAgo(post['created_at'] as String?);
    final likes = (post['likes_count'] as int?) ?? 0;
    final comments = (post['comentarios_count'] as int?) ?? 0;
    final isLiked = _likedPosts.contains(postId);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Imagen de fondo
        imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: const Color(0xFF0D0D0D),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryBlue,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
              )
            : Container(
                color: const Color(0xFF0D0D0D),
                child: const Center(
                  child: Icon(Icons.image, color: Colors.white54, size: 64),
                ),
              ),

        // Icono de búsqueda
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 8,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(77),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                );
              },
              icon: const Icon(
                Icons.search,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),

        // Header flotante
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          right: 8,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(77),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
              icon: const Icon(
                Icons.person_outline,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),

        // Info y botones en la parte inferior
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withAlpha(230),
                  Colors.black.withAlpha(150),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Usuario con botón Seguir
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProfileUnknownScreen(
                                userId: (post['user_id'] as String?) ?? '',
                              ),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: AppTheme.buttonGradient,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withAlpha(128),
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: avatarUrl != null
                                  ? Image.network(
                                      avatarUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Text(
                                        avatarLetter,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      avatarLetter,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  username,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  timeAgo,
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(180),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Botón Seguir estilo pill
                      GestureDetector(
                        onTap: () => _toggleFollow(username),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: _followingUsers.contains(post['username'])
                                ? null
                                : AppTheme.buttonGradient,
                            color: _followingUsers.contains(post['username'])
                                ? Colors.white.withAlpha(51)
                                : null,
                            borderRadius: BorderRadius.circular(20),
                            border: _followingUsers.contains(post['username'])
                                ? Border.all(
                                    color: Colors.white.withAlpha(128),
                                    width: 1,
                                  )
                                : null,
                          ),
                          child: Text(
                            _followingUsers.contains(username)
                                ? 'Siguiendo'
                                : 'Seguir',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Título
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Botones de acción
                  Row(
                    children: [
                      // Like con estilo pill
                      GestureDetector(
                        onTap: () => _toggleLike(postId),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isLiked
                                ? AppTheme.primaryBlue.withAlpha(204)
                                : Colors.white.withAlpha(51),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isLiked ? Colors.white : Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formatNumber(likes),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // Comentarios
                      GestureDetector(
                        onTap: () {
                          CommentsBottomSheet.show(
                            context,
                            postId: postId,
                            commentCount: comments,
                            postUsername: username,
                            onCommentAdded: (newCount) {
                              if (!mounted) return;
                              setState(() {
                                _feedRevision++;
                                final index = _posts.indexWhere(
                                  (p) => p['id'] == postId,
                                );
                                if (index != -1) {
                                  _posts[index] = {
                                    ..._posts[index],
                                    'comentarios_count': newCount,
                                  };
                                }
                              });
                            },
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(51),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.chat_bubble_outline,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$comments',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // Compartir
                      GestureDetector(
                        onTap: () async {
                          try {
                            await Share.share(
                              'Mira esta publicación de $username: $title',
                              subject: 'Compartir publicación',
                            );
                          } catch (e) {
                            debugPrint('Error al compartir: $e');
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(51),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.share_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Menú
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          color: Colors.white,
                          size: 24,
                        ),
                        color: const Color(0xFF2A2A2A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onSelected: (value) async {
                          switch (value) {
                            case 'download':
                              break;
                            case 'share':
                              try {
                                debugPrint('Compartir presionado');
                                await Share.share(
                                  'Mira esta publicación de $username: $title',
                                  subject: 'Compartir publicación',
                                );
                              } catch (e) {
                                debugPrint('Error al compartir: $e');
                              }
                              break;
                            case 'not_interested':
                              break;
                            case 'report':
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'download',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.download,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Descargar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'share',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.share,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Compartir',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'not_interested',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.not_interested,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'No me interesa',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'report',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.flag_outlined,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Reportar',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
