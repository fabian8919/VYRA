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
  
  // Datos de ejemplo de posts
  final List<Map<String, dynamic>> _posts = [
    {
      'username': '@photography_lover',
      'avatar': 'P',
      'title': 'Atardecer en la playa de Cartagena 🌅',
      'image': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
      'likes': 1240,
      'comments': 89,
      'timeAgo': '2h',
    },
    {
      'username': '@nature_wild',
      'avatar': 'N',
      'title': 'Bosque encantado en la Amazonía',
      'image': 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800',
      'likes': 892,
      'comments': 45,
      'timeAgo': '4h',
    },
    {
      'username': '@city_explorer',
      'avatar': 'C',
      'title': 'Arquitectura moderna en Medellín',
      'image': 'https://images.unsplash.com/photo-1518005020951-eccb494ad742?w=800',
      'likes': 2156,
      'comments': 156,
      'timeAgo': '6h',
    },
    {
      'username': '@portrait_master',
      'avatar': 'M',
      'title': 'Retrato natural con luz dorada ✨',
      'image': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800',
      'likes': 3421,
      'comments': 234,
      'timeAgo': '8h',
    },
    {
      'username': '@mountain_hiker',
      'avatar': 'H',
      'title': 'Caminata en los Andes colombianos',
      'image': 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800',
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
    return Stack(
      fit: StackFit.expand,
      children: [
        // Imagen de fondo que ocupa TODA la pantalla
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
        
        // Header flotante (sin gradiente, solo iconos)
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: AppTheme.buttonGradient,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Center(
                      child: Text(
                        'V',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Vyra',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ProfileScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.person_outline,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
        
        // Info y botones en la parte inferior con gradiente
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
                  // Usuario
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: AppTheme.buttonGradient,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: Text(
                            post['avatar'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        post['username'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• ${post['timeAgo']}',
                        style: TextStyle(
                          color: Colors.white.withAlpha(150),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Título
                  Text(
                    post['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Botones de acción
                  Row(
                    children: [
                      // Upvote/Downvote
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF3A3A3A).withAlpha(204),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.arrow_upward,
                                color: Colors.white,
                                size: 20,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              constraints: const BoxConstraints(),
                            ),
                            Text(
                              _formatNumber(post['likes']),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.arrow_downward,
                                color: Colors.white,
                                size: 20,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: 10),
                      
                      // Comentarios
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF3A3A3A).withAlpha(204),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {},
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
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
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 10),
                      
                      // Compartir
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF3A3A3A).withAlpha(204),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {},
                            borderRadius: BorderRadius.circular(20),
                            child: const Padding(
                              padding: EdgeInsets.all(10),
                              child: Icon(
                                Icons.share,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
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
