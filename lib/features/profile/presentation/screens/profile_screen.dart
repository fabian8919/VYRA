import 'package:flutter/material.dart';
import 'package:vyra/core/theme/app_theme.dart';
import 'package:vyra/services/auth_service.dart';

// Colores del nuevo diseño
class _ProfileColors {
  static const Color background = Color(0xFFF0F0FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF2563EB);
  static const Color onSurface = Color(0xFF292B51);
  static const Color onSurfaceVariant = Color(0xFF565881);
  static const Color outline = Color(0xFF71739E);
  static const Color outlineVariant = Color(0xFFC4C4E0);

  static const LinearGradient vibrantBlue = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
  );
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  bool _isGridView = true;
  final ScrollController _scrollController = ScrollController();

  final Map<String, dynamic> _userData = {
    'name': 'Andrés Felipe',
    'username': '@andres_f',
    'avatar': 'A',
    'bio':
        '📸 Fotógrafo apasionado por los paisajes y la naturaleza.\n🌍 Viajando por el mundo una foto a la vez.',
    'totalLikes': 12547,
    'totalViews': 89234,
    'postsCount': 156,
  };

  final List<Map<String, dynamic>> _userPosts = [
    {
      'image':
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
      'likes': 1234,
      'views': 5678,
    },
    {
      'image':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      'likes': 892,
      'views': 3456,
    },
    {
      'image':
          'https://images.unsplash.com/photo-1518005020951-eccb494ad742?w=400',
      'likes': 2156,
      'views': 8901,
    },
    {
      'image':
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
      'likes': 3421,
      'views': 12345,
    },
    {
      'image':
          'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?w=400',
      'likes': 567,
      'views': 2345,
    },
    {
      'image':
          'https://images.unsplash.com/photo-1447752875215-b2761acb3c5d?w=400',
      'likes': 1890,
      'views': 6789,
    },
    {
      'image':
          'https://images.unsplash.com/photo-1433086966358-54859d0ed716?w=400',
      'likes': 2341,
      'views': 8765,
    },
    {
      'image':
          'https://images.unsplash.com/photo-1501854140801-50d01698950b?w=400',
      'likes': 445,
      'views': 1890,
    },
    {
      'image':
          'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=400',
      'likes': 1567,
      'views': 5432,
    },
    {
      'image':
          'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=400',
      'likes': 2100,
      'views': 8900,
    },
    {
      'image':
          'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=400',
      'likes': 1800,
      'views': 7200,
    },
    {
      'image':
          'https://images.unsplash.com/photo-1426604966848-d7adac402bff?w=400',
      'likes': 3200,
      'views': 15000,
    },
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await _authService.signOut();
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final userName =
        user?.userMetadata?['full_name'] as String? ?? _userData['name'];

    return Scaffold(
      backgroundColor: _ProfileColors.background,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Header con gradiente
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.backgroundGradient,
                ),
                child: Column(
                  children: [
                    // AppBar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _ProfileColors.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: _ProfileColors.outlineVariant.withAlpha(100),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.arrow_back,
                                color: _ProfileColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _ProfileColors.surfaceContainerLowest,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _ProfileColors.outlineVariant.withAlpha(100),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.more_vert,
                                    color: _ProfileColors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: _logout,
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _ProfileColors.surfaceContainerLowest,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _ProfileColors.outlineVariant.withAlpha(100),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.logout,
                                    color: _ProfileColors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Avatar
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        gradient: AppTheme.buttonGradient,
                        borderRadius: BorderRadius.circular(55),
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: AppTheme.buttonShadow,
                      ),
                      child: Center(
                        child: Text(
                          userName.toString().isNotEmpty
                              ? userName.toString()[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Nombre
                    Text(
                      userName,
                      style: const TextStyle(
                        color: _ProfileColors.onSurface,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Username
                    Text(
                      _userData['username'],
                      style: const TextStyle(
                        color: _ProfileColors.onSurfaceVariant,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Bio
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        _userData['bio'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: _ProfileColors.onSurfaceVariant,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Stats Card
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _ProfileColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat(
                      'Posts',
                      _userData['postsCount'].toString(),
                      Icons.grid_on,
                    ),
                    _buildDivider(),
                    _buildStat(
                      'Likes',
                      _formatNumber(_userData['totalLikes']),
                      Icons.favorite,
                    ),
                    _buildDivider(),
                    _buildStat(
                      'Vistas',
                      _formatNumber(_userData['totalViews']),
                      Icons.visibility,
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Botón editar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: _ProfileColors.vibrantBlue,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withAlpha(60),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Editar perfil',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Tabs
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: _ProfileColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isGridView = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: _isGridView
                                ? _ProfileColors.vibrantBlue
                                : null,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.grid_on,
                            color: _isGridView
                                ? Colors.white
                                : _ProfileColors.outline,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isGridView = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: !_isGridView
                                ? _ProfileColors.vibrantBlue
                                : null,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.view_list,
                            color: !_isGridView
                                ? Colors.white
                                : _ProfileColors.outline,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Grid de imágenes
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  return _buildImageCard(_userPosts[index]);
                }, childCount: _userPosts.length),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: _ProfileColors.primary, size: 22),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: _ProfileColors.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: _ProfileColors.outline, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 40, color: _ProfileColors.outlineVariant);
  }

  Widget _buildImageCard(Map<String, dynamic> post) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _ProfileColors.outlineVariant.withAlpha(100),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                post['image'],
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey.shade100,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: _ProfileColors.primary,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black.withAlpha(179), Colors.transparent],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.favorite, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        _formatNumber(post['likes']),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.visibility,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatNumber(post['views']),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
