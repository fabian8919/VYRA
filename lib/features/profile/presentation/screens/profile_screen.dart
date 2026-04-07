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

  // Datos de ejemplo para notificaciones
  final List<Map<String, dynamic>> _notifications = [
    {
      'type': 'like',
      'title': 'A María le gustó tu foto',
      'message': 'Le encantó tu publicación del atardecer',
      'time': 'Hace 5 min',
      'icon': Icons.favorite,
      'iconColor': Colors.red,
      'iconBgColor': Color(0xFFFFE4E4),
      'read': false,
    },
    {
      'type': 'message',
      'title': 'Nuevo mensaje de Carlos',
      'message': 'Hey, ¿cómo estás? Me encantaron tus fotos...',
      'time': 'Hace 15 min',
      'icon': Icons.message,
      'iconColor': Color(0xFF2563EB),
      'iconBgColor': Color(0xFFE0E7FF),
      'read': false,
    },
    {
      'type': 'view',
      'title': 'Laura vio tu perfil',
      'message': 'Alguien nuevo ha visto tu perfil',
      'time': 'Hace 1 hora',
      'icon': Icons.visibility,
      'iconColor': Color(0xFF10B981),
      'iconBgColor': Color(0xFFD1FAE5),
      'read': true,
    },
    {
      'type': 'like',
      'title': 'A Pedro y 3 más les gustó tu foto',
      'message': 'Tu foto de la montaña está siendo popular',
      'time': 'Hace 2 horas',
      'icon': Icons.favorite,
      'iconColor': Colors.red,
      'iconBgColor': Color(0xFFFFE4E4),
      'read': true,
    },
    {
      'type': 'message',
      'title': 'Nuevo mensaje de Ana',
      'message': '¡Hola! ¿Qué cámara usas para tus fotos?',
      'time': 'Hace 3 horas',
      'icon': Icons.message,
      'iconColor': Color(0xFF2563EB),
      'iconBgColor': Color(0xFFE0E7FF),
      'read': true,
    },
    {
      'type': 'view',
      'title': '15 personas vieron tu perfil',
      'message': 'Tu perfil ha tenido visitas recientemente',
      'time': 'Hace 5 horas',
      'icon': Icons.visibility,
      'iconColor': Color(0xFF10B981),
      'iconBgColor': Color(0xFFD1FAE5),
      'read': true,
    },
  ];

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
                              // Botón de notificaciones
                              Stack(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      _showNotificationsModal(context);
                                    },
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
                                        Icons.notifications_outlined,
                                        color: _ProfileColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                  // Badge de notificaciones no leídas
                                  if (_notifications.where((n) => !n['read']).isNotEmpty)
                                    Positioned(
                                      right: 6,
                                      top: 6,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '${_notifications.where((n) => !n['read']).length}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
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

  void _showNotificationsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NotificationsModal(
        notifications: _notifications,
        onMarkAsRead: (index) {
          setState(() {
            _notifications[index]['read'] = true;
          });
        },
        onMarkAllAsRead: () {
          setState(() {
            for (var notification in _notifications) {
              notification['read'] = true;
            }
          });
        },
      ),
    );
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

// ============================================================================
// MODAL DE NOTIFICACIONES ESTILO FACEBOOK
// ============================================================================

class NotificationsModal extends StatelessWidget {
  final List<Map<String, dynamic>> notifications;
  final Function(int) onMarkAsRead;
  final VoidCallback onMarkAllAsRead;

  const NotificationsModal({
    super.key,
    required this.notifications,
    required this.onMarkAsRead,
    required this.onMarkAllAsRead,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Header arrastrable
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Barra de arrastre
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Título y acciones
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Notificaciones',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        // Botón marcar todo como leído
                        _HeaderButton(
                          icon: Icons.done_all,
                          onTap: () {
                            onMarkAllAsRead();
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Filtros tipo Facebook
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _FilterChip(label: 'Todas', isActive: true),
                    const SizedBox(width: 8),
                    _FilterChip(label: 'No leídas', isActive: false),
                  ],
                ),
              ),

              // Lista de notificaciones
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  children: [
                    // Sección: Nuevas
                    if (notifications.any((n) => !n['read']))
                      _buildSectionHeader('Nuevas'),
                    ...notifications
                        .asMap()
                        .entries
                        .where((e) => !e.value['read'])
                        .map((e) => _buildFacebookNotification(e.key, e.value)),

                    // Sección: Anteriores
                    if (notifications.any((n) => n['read'])) ...[
                      _buildSectionHeader('Anteriores'),
                      ...notifications
                          .asMap()
                          .entries
                          .where((e) => e.value['read'])
                          .map((e) => _buildFacebookNotification(e.key, e.value)),
                    ],

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          if (title == 'Nuevas')
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF2563EB),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFacebookNotification(int index, Map<String, dynamic> notification) {
    final bool isRead = notification['read'] as bool;
    
    return InkWell(
      onTap: () {
        onMarkAsRead(index);
      },
      child: Container(
        color: isRead ? Colors.white : const Color(0xFFE7F3FF),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar/Icono con indicador
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: notification['iconBgColor'] as Color,
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    notification['icon'] as IconData,
                    color: notification['iconColor'] as Color,
                    size: 26,
                  ),
                ),
                // Indicador de no leído
                if (!isRead)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Contenido
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Texto de la notificación
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.35,
                        color: Colors.black87,
                      ),
                      children: [
                        TextSpan(
                          text: notification['title'] as String,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        TextSpan(
                          text: ' ${notification['message']}',
                          style: const TextStyle(fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Tiempo
                  Text(
                    notification['time'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      color: isRead ? Colors.grey.shade500 : const Color(0xFF2563EB),
                      fontWeight: isRead ? FontWeight.w400 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Menú de opciones
            IconButton(
              icon: Icon(Icons.more_horiz, color: Colors.grey.shade400),
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}

// Botón circular del header
class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black87, size: 22),
      ),
    );
  }
}

// Chip de filtro
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;

  const _FilterChip({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFE7F3FF) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isActive ? const Color(0xFF2563EB) : Colors.grey.shade700,
        ),
      ),
    );
  }
}
