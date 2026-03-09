import 'package:flutter/material.dart';
import 'package:vyra/core/theme/app_theme.dart';
import 'package:vyra/features/auth/presentation/screens/login_screen.dart';
import 'package:vyra/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  
  // Datos de ejemplo - reemplazar con datos reales de Supabase
  final List<Map<String, dynamic>> _posts = [
    {
      'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
      'username': '@mountain_lover',
      'caption': 'Amanecer en los Alpes 🏔️✨',
      'likes': 1243,
      'avatar': 'M',
    },
    {
      'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800',
      'username': '@ocean_dreams',
      'caption': 'El mar siempre me encuentra 🌊',
      'likes': 892,
      'avatar': 'O',
    },
    {
      'image': 'https://images.unsplash.com/photo-1518005020951-eccb494ad742?w=800',
      'username': '@architecture',
      'caption': 'Líneas y curvas modernas 🏢',
      'likes': 2156,
      'avatar': 'A',
    },
    {
      'image': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800',
      'username': '@portrait_artist',
      'caption': 'Luces naturales 💫',
      'likes': 3421,
      'avatar': 'P',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await AuthService().signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Feed vertical tipo TikTok
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: (index) {},
            itemCount: _posts.length,
            itemBuilder: (context, index) {
              return _buildPostItem(_posts[index], isSmallScreen);
            },
          ),
          
          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: isSmallScreen ? 40 : 50,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withAlpha(153),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Vyra',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      IconButton(
                        onPressed: _logout,
                        icon: const Icon(
                          Icons.logout,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom navigation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                bottom: isSmallScreen ? 20 : 30,
                top: isSmallScreen ? 16 : 20,
                left: 20,
                right: 20,
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
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.home, 'Inicio', true),
                  _buildNavItem(Icons.explore, 'Descubrir', false),
                  _buildAddButton(),
                  _buildNavItem(Icons.favorite, 'Me gusta', false),
                  _buildNavItem(Icons.person, 'Perfil', false),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostItem(Map<String, dynamic> post, bool isSmallScreen) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Imagen de fondo
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
                ),
              ),
            );
          },
        ),
        
        // Overlay gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withAlpha(204),
                Colors.transparent,
                Colors.transparent,
              ],
              stops: const [0.0, 0.3, 1.0],
            ),
          ),
        ),
        
        // Info del post (lado derecho)
        Positioned(
          right: isSmallScreen ? 12 : 16,
          bottom: isSmallScreen ? 100 : 120,
          child: Column(
            children: [
              // Avatar
              Container(
                width: isSmallScreen ? 48 : 56,
                height: isSmallScreen ? 48 : 56,
                decoration: BoxDecoration(
                  gradient: AppTheme.buttonGradient,
                  borderRadius: BorderRadius.circular(isSmallScreen ? 24 : 28),
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    post['avatar'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 20 : 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: isSmallScreen ? 16 : 20),
              
              // Like
              _buildActionButton(
                Icons.favorite,
                post['likes'].toString(),
                () {},
                isSmallScreen,
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              
              // Comment
              _buildActionButton(
                Icons.chat_bubble,
                '128',
                () {},
                isSmallScreen,
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              
              // Share
              _buildActionButton(
                Icons.share,
                'Share',
                () {},
                isSmallScreen,
              ),
            ],
          ),
        ),
        
        // Info del usuario (abajo izquierda)
        Positioned(
          left: 20,
          right: isSmallScreen ? 80 : 100,
          bottom: isSmallScreen ? 100 : 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post['username'],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: isSmallScreen ? 6 : 8),
              Text(
                post['caption'],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
              SizedBox(height: isSmallScreen ? 10 : 12),
              Row(
                children: [
                  Icon(
                    Icons.music_note,
                    color: Colors.white,
                    size: isSmallScreen ? 14 : 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Sonido original - ${post['username'].toString().substring(1)}',
                    style: TextStyle(
                      color: Colors.white.withAlpha(204),
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap, bool isSmallScreen) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: isSmallScreen ? 28 : 32,
          ),
          SizedBox(height: isSmallScreen ? 2 : 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 11 : 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isSelected ? AppTheme.primaryBlue : Colors.white.withAlpha(153),
          size: isSmallScreen ? 24 : 28,
        ),
        SizedBox(height: isSmallScreen ? 2 : 4),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.primaryBlue : Colors.white.withAlpha(153),
            fontSize: isSmallScreen ? 10 : 12,
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    
    return Container(
      width: isSmallScreen ? 40 : 48,
      height: isSmallScreen ? 32 : 36,
      decoration: BoxDecoration(
        gradient: AppTheme.buttonGradient,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.add,
        color: Colors.white,
        size: isSmallScreen ? 24 : 28,
      ),
    );
  }
}
