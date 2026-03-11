import 'package:flutter/material.dart';
import 'package:vyra/core/theme/app_theme.dart';
import 'package:vyra/services/auth_service.dart';

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
    'bio': '📸 Fotógrafo apasionado por los paisajes y la naturaleza.\n🌍 Viajando por el mundo una foto a la vez.',
    'totalLikes': 12547,
    'totalViews': 89234,
    'postsCount': 156,
  };
  
  final List<Map<String, dynamic>> _userPosts = [
    {'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400', 'likes': 1234, 'views': 5678},
    {'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400', 'likes': 892, 'views': 3456},
    {'image': 'https://images.unsplash.com/photo-1518005020951-eccb494ad742?w=400', 'likes': 2156, 'views': 8901},
    {'image': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400', 'likes': 3421, 'views': 12345},
    {'image': 'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?w=400', 'likes': 567, 'views': 2345},
    {'image': 'https://images.unsplash.com/photo-1447752875215-b2761acb3c5d?w=400', 'likes': 1890, 'views': 6789},
    {'image': 'https://images.unsplash.com/photo-1433086966358-54859d0ed716?w=400', 'likes': 2341, 'views': 8765},
    {'image': 'https://images.unsplash.com/photo-1501854140801-50d01698950b?w=400', 'likes': 445, 'views': 1890},
    {'image': 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=400', 'likes': 1567, 'views': 5432},
    {'image': 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=400', 'likes': 2100, 'views': 8900},
    {'image': 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=400', 'likes': 1800, 'views': 7200},
    {'image': 'https://images.unsplash.com/photo-1426604966848-d7adac402bff?w=400', 'likes': 3200, 'views': 15000},
    {'image': 'https://images.unsplash.com/photo-1505118380757-91f5f5632de0?w=400', 'likes': 950, 'views': 4100},
    {'image': 'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=400', 'likes': 2750, 'views': 9800},
    {'image': 'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=400', 'likes': 1450, 'views': 6200},
    {'image': 'https://images.unsplash.com/photo-1490730141103-6cac27abb6f4?w=400', 'likes': 3300, 'views': 12000},
    {'image': 'https://images.unsplash.com/photo-1518173946687-a4c036bc0b55?w=400', 'likes': 890, 'views': 3800},
    {'image': 'https://images.unsplash.com/photo-1475924156734-496f6cac6ec1?w=400', 'likes': 1950, 'views': 7600},
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await _authService.signOut();
    // No navegamos manualmente - AuthWrapper detectará el cambio automáticamente
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
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    final user = _authService.currentUser;
    final userName = user?.userMetadata?['full_name'] as String? ?? 
                     _userData['name'];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        top: false,
        bottom: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con gradiente
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
                child: Column(
                  children: [
                    // Espacio para el notch/status bar
                    SizedBox(height: MediaQuery.of(context).padding.top),
                    
                    // Botones superiores
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.more_vert,
                                  color: Colors.white,
                                ),
                              ),
                              IconButton(
                                onPressed: _logout,
                                icon: const Icon(
                                  Icons.logout,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Avatar
                    Container(
                      width: isSmallScreen ? 90 : 110,
                      height: isSmallScreen ? 90 : 110,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          isSmallScreen ? 45 : 55,
                        ),
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(77),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          userName.toString().isNotEmpty
                              ? userName.toString()[0].toUpperCase()
                              : 'U',
                          style: TextStyle(
                            color: AppTheme.primaryBlue,
                            fontSize: isSmallScreen ? 44 : 54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: isSmallScreen ? 16 : 20),
                    
                    // Nombre
                    Text(
                      userName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 24 : 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    SizedBox(height: isSmallScreen ? 4 : 6),
                    
                    // Username
                    Text(
                      _userData['username'],
                      style: TextStyle(
                        color: Colors.white.withAlpha(204),
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                    ),
                    
                    SizedBox(height: isSmallScreen ? 16 : 20),
                  ],
                ),
              ),
              
              // Contenido negro
              Container(
                color: Colors.black,
                child: Column(
                  children: [
                    // Bio
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: isSmallScreen ? 12 : 16,
                      ),
                      child: Text(
                        _userData['bio'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withAlpha(204),
                          fontSize: isSmallScreen ? 13 : 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                    
                    // Stats
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: isSmallScreen ? 12 : 16,
                      ),
                      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStat('Posts', _userData['postsCount'].toString(), 
                              Icons.grid_on, isSmallScreen),
                          _buildDivider(),
                          _buildStat('Likes', _formatNumber(_userData['totalLikes']), 
                              Icons.favorite, isSmallScreen),
                          _buildDivider(),
                          _buildStat('Vistas', _formatNumber(_userData['totalViews']), 
                              Icons.visibility, isSmallScreen),
                        ],
                      ),
                    ),
                    
                    // Botón editar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        width: double.infinity,
                        height: isSmallScreen ? 44 : 48,
                        decoration: BoxDecoration(
                          gradient: AppTheme.buttonGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {},
                            borderRadius: BorderRadius.circular(12),
                            child: Center(
                              child: Text(
                                'Editar perfil',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 14 : 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: isSmallScreen ? 16 : 20),
                    
                    // Tabs
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isGridView = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: _isGridView
                                          ? AppTheme.primaryBlue
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: Icon(
                                  Icons.grid_on,
                                  color: _isGridView
                                      ? AppTheme.primaryBlue
                                      : Colors.white.withAlpha(128),
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isGridView = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: !_isGridView
                                          ? AppTheme.primaryBlue
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: Icon(
                                  Icons.view_list,
                                  color: !_isGridView
                                      ? AppTheme.primaryBlue
                                      : Colors.white.withAlpha(128),
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: isSmallScreen ? 12 : 16),
                    
                    // Grid de imágenes manual
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Wrap(
                        spacing: 2,
                        runSpacing: 2,
                        children: _userPosts.map((post) {
                          return SizedBox(
                            width: (MediaQuery.of(context).size.width - 8) / 3,
                            height: (MediaQuery.of(context).size.width - 8) / 3 * 1.1,
                            child: _buildImageCard(post, isSmallScreen),
                          );
                        }).toList(),
                      ),
                    ),
                    
                    SizedBox(height: isSmallScreen ? 40 : 60),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon, bool isSmallScreen) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryBlue,
          size: isSmallScreen ? 20 : 24,
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: isSmallScreen ? 2 : 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withAlpha(128),
            fontSize: isSmallScreen ? 11 : 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withAlpha(26),
    );
  }

  Widget _buildImageCard(Map<String, dynamic> post, bool isSmallScreen) {
    return GestureDetector(
      onTap: () {},
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            post['image'],
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[900],
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryBlue,
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
              padding: EdgeInsets.symmetric(
                horizontal: 6,
                vertical: isSmallScreen ? 4 : 6,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withAlpha(179),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: isSmallScreen ? 10 : 12,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    _formatNumber(post['likes']),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 9 : 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 6 : 8),
                  Icon(
                    Icons.visibility,
                    color: Colors.white,
                    size: isSmallScreen ? 10 : 12,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    _formatNumber(post['views']),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 9 : 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
