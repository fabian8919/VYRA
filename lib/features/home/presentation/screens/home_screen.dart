import 'package:flutter/material.dart';
import 'package:vyra/core/theme/app_theme.dart';
import 'package:vyra/features/profile/presentation/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  final Set<String> _followingUsers = {};
  final Set<String> _likedPosts = {};

  final List<Map<String, dynamic>> _posts = [
    {
      'username': '@photography_lover',
      'avatar': 'P',
      'title': 'Atardecer en la playa de Cartagena 🌅',
      'image':
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
      'likes': 1240,
      'comments': 89,
      'timeAgo': '2h',
    },
    {
      'username': '@nature_wild',
      'avatar': 'N',
      'title': 'Bosque encantado en la Amazonía',
      'image':
          'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800',
      'likes': 892,
      'comments': 45,
      'timeAgo': '4h',
    },
    {
      'username': '@city_explorer',
      'avatar': 'C',
      'title': 'Arquitectura moderna en Medellín',
      'image':
          'https://images.unsplash.com/photo-1518005020951-eccb494ad742?w=800',
      'likes': 2156,
      'comments': 156,
      'timeAgo': '6h',
    },
    {
      'username': '@portrait_master',
      'avatar': 'M',
      'title': 'Retrato natural con luz dorada ✨',
      'image':
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800',
      'likes': 3421,
      'comments': 234,
      'timeAgo': '8h',
    },
    {
      'username': '@mountain_hiker',
      'avatar': 'H',
      'title': 'Caminata en los Andes colombianos',
      'image':
          'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800',
      'likes': 1567,
      'comments': 112,
      'timeAgo': '12h',
    },
  ];

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
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

  void _toggleLike(String username) {
    setState(() {
      if (_likedPosts.contains(username)) {
        _likedPosts.remove(username);
      } else {
        _likedPosts.add(username);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
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
    final isLiked = _likedPosts.contains(post['username']);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Imagen de fondo
        Image.network(
          post['image'],
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
                          child: Text(
                            post['avatar'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post['username'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              post['timeAgo'],
                              style: TextStyle(
                                color: Colors.white.withAlpha(180),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Botón Seguir estilo pill
                      GestureDetector(
                        onTap: () => _toggleFollow(post['username']),
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
                            _followingUsers.contains(post['username'])
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
                    post['title'],
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
                        onTap: () => _toggleLike(post['username']),
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
                                _formatNumber(
                                  post['likes'] + (isLiked ? 1 : 0),
                                ),
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
                        onTap: () {},
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
                                '${post['comments']}',
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
                        onTap: () {},
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
                        onSelected: (value) {
                          switch (value) {
                            case 'download':
                              break;
                            case 'share':
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
