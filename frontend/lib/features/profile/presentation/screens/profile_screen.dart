import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vyra/core/theme/app_theme.dart';
import 'package:vyra/services/auth_service.dart';
import 'package:vyra/features/posts/presentation/screens/create_post_screen.dart';
import 'package:vyra/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:vyra/features/profile/presentation/screens/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  bool _isGridView = true;
  bool _isLoadingProfile = true;
  Map<String, dynamic>? _profileData;
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
    'name': 'Andres Felipe',
    'username': '@andres_f',
    'avatar': 'A',
    'bio':
        '📸 Fotografo apasionado por los paisajes y la naturaleza.\n🌍 Viajando por el mundo una foto a la vez.',
    'totalViews': 89234,
    'postsCount': 156,
    'followers': 2847,
    'following': 543,
  };

  // Datos de ejemplo para seguidores
  final List<Map<String, dynamic>> _followersData = [
    {'name': 'María García', 'username': '@maria_g', 'avatar': 'M', 'isFollowing': true},
    {'name': 'Carlos López', 'username': '@carlos_l', 'avatar': 'C', 'isFollowing': false},
    {'name': 'Laura Martínez', 'username': '@laura_m', 'avatar': 'L', 'isFollowing': true},
    {'name': 'Pedro Rodríguez', 'username': '@pedro_r', 'avatar': 'P', 'isFollowing': false},
    {'name': 'Ana Fernández', 'username': '@ana_f', 'avatar': 'A', 'isFollowing': true},
    {'name': 'Juan Pérez', 'username': '@juan_p', 'avatar': 'J', 'isFollowing': false},
    {'name': 'Sofia Torres', 'username': '@sofia_t', 'avatar': 'S', 'isFollowing': true},
    {'name': 'Diego Ramírez', 'username': '@diego_r', 'avatar': 'D', 'isFollowing': false},
  ];

  // Datos de ejemplo para seguidos
  final List<Map<String, dynamic>> _followingData = [
    {'name': 'Natalia Silva', 'username': '@natalia_s', 'avatar': 'N', 'isFollowing': true},
    {'name': 'Andrea Ruiz', 'username': '@andrea_r', 'avatar': 'A', 'isFollowing': true},
    {'name': 'Luis Gómez', 'username': '@luis_g', 'avatar': 'L', 'isFollowing': true},
    {'name': 'Carmen Vargas', 'username': '@carmen_v', 'avatar': 'C', 'isFollowing': true},
    {'name': 'Miguel Castro', 'username': '@miguel_c', 'avatar': 'M', 'isFollowing': true},
    {'name': 'Isabel Morales', 'username': '@isabel_m', 'avatar': 'I', 'isFollowing': true},
  ];

  // Inicializar listas vacías para evitar null
  List<Map<String, dynamic>> _followers = [];
  List<Map<String, dynamic>> _following = [];

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
  void initState() {
    super.initState();
    // Inicializar listas mutables
    _followers = List<Map<String, dynamic>>.from(_followersData);
    _following = List<Map<String, dynamic>>.from(_followingData);
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = _authService.currentUser;
    if (user != null) {
      try {
        final profile = await _authService.getProfile(user.id);
        if (mounted) {
          setState(() {
            _profileData = profile;
            _isLoadingProfile = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoadingProfile = false);
        }
      }
    } else {
      setState(() => _isLoadingProfile = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await _authService.signOut();
  }

  String _getProfileValue(String key, dynamic fallback) {
    final value = _profileData?[key];
    if (value != null && value.toString().isNotEmpty) return value.toString();
    if (fallback != null) return fallback.toString();
    return '';
  }

  String _formatNumber(dynamic number) {
    if (number == null) return '0';
    final int num = number is int ? number : int.tryParse(number.toString()) ?? 0;
    if (num >= 1000000) {
      return '${(num / 1000000).toStringAsFixed(1)}M';
    } else if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(1)}K';
    }
    return num.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProfile) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryBlue),
        ),
      );
    }

    final user = _authService.currentUser;
    final nickName = _getProfileValue('username', _userData['name']);
    final fullName = user?.userMetadata?['full_name'] as String?;
    final userBio = _getProfileValue('bio', _userData['bio']);
    final avatarUrl = _profileData?['avatar_url'] as String?;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                color: AppTheme.background,
                child: Column(
                  children: [
                    // AppBar
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.outlineVariant.withAlpha(100),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.arrow_back,
                                color: AppTheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              // Botón agregar post (+)
                              Stack(
                                children: [
                                  IconButton(
                                    onPressed: () => _showAddPostOptions(context),
                                    icon: Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        gradient: AppTheme.buttonGradient,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0xFF2563EB).withAlpha(100),
                                            blurRadius: 12,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  // Punto indicador
                                  Positioned(
                                    right: 6,
                                    top: 6,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Color(0xFF2563EB),
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(width: 8),

                              // Botón de notificaciones
                              Stack(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      _showNotificationsModal(context);
                                    },
                                    icon: Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.surfaceContainerLowest,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.outlineVariant.withAlpha(100),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.notifications_outlined,
                                        color: AppTheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                  // Badge de notificaciones no leídas
                                  if (_notifications.where((n) => !n['read']).isNotEmpty)
                                    Positioned(
                                      right: 6,
                                      top: 6,
                                      child: Container(
                                        padding: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '${_notifications.where((n) => !n['read']).length}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              // Menú de opciones (tres puntos)
                              _buildMenuButton(context),
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
                      child: ClipOval(
                        child: avatarUrl != null && avatarUrl.isNotEmpty
                            ? Image.network(
                                avatarUrl,
                                width: 110,
                                height: 110,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildAvatarFallback(fullName ?? nickName),
                              )
                            : _buildAvatarFallback(fullName ?? nickName),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Nombre completo
                    Text(
                      fullName ?? nickName,
                      style: TextStyle(
                        color: AppTheme.onSurface,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    if (fullName != null && fullName.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          nickName,
                          style: TextStyle(
                            color: AppTheme.onSurfaceVariant,
                            fontSize: 16,
                          ),
                        ),
                      ),

                    SizedBox(height: 16),

                    // Bio
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        userBio,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.onSurfaceVariant,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),

                    SizedBox(height: 24),


                  ],
                ),
              ),
            ),

            // Stats Card - Diseño proporcionado
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 24),
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    // Primera fila: Posts, Likes, Vistas (3 columnas)
                    Row(
                      children: [
                        Expanded(
                          child: _buildStat(
                            'Posts',
                            _userData['postsCount'].toString(),
                            Icons.grid_on,
                          ),
                        ),
                        _buildDivider(),
                        Expanded(
                          child: _buildStat(
                            'Likes',
                            _formatNumber(_userData['totalLikes']),
                            Icons.favorite,
                          ),
                        ),
                        _buildDivider(),
                        Expanded(
                          child: _buildStat(
                            'Vistas',
                            _formatNumber(_userData['totalViews']),
                            Icons.visibility,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(
                        height: 1,
                        color: AppTheme.outlineVariant.withAlpha(100),
                      ),
                    ),
                    // Segunda fila: Seguidores, Siguiendo (2 columnas centradas)
                    Row(
                      children: [
                        // Espacio vacío a la izquierda (1/6 del ancho)
                        Expanded(flex: 1, child: SizedBox()),
                        // Seguidores (2/6 = 1/3 del ancho)
                        Expanded(
                          flex: 2,
                          child: _buildStatClickable(
                            'Seguidores',
                            _formatNumber(_userData['followers']),
                            Icons.people_outline,
                            () => _showUsersModal(context, 'Seguidores', _followers),
                          ),
                        ),
                        _buildDivider(),
                        // Siguiendo (2/6 = 1/3 del ancho)
                        Expanded(
                          flex: 2,
                          child: _buildStatClickable(
                            'Siguiendo',
                            _formatNumber(_userData['following']),
                            Icons.person_add_outlined,
                            () => _showUsersModal(context, 'Siguiendo', _following),
                          ),
                        ),
                        // Espacio vacío a la derecha (1/6 del ancho)
                        Expanded(flex: 1, child: SizedBox()),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Tabs
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isGridView = true),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: _isGridView
                                ? AppTheme.buttonGradient
                                : null,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.grid_on,
                            color: _isGridView
                                ? Colors.white
                                : AppTheme.outline,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isGridView = false),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: !_isGridView
                                ? AppTheme.buttonGradient
                                : null,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.view_list,
                            color: !_isGridView
                                ? Colors.white
                                : AppTheme.outline,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Grid de imágenes
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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

            SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context) {
    return PopupMenuButton<String>(
      offset: Offset(0, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: AppTheme.surfaceContainerLowest,
      elevation: 8,
      itemBuilder: (context) => [
        // Editar perfil
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFFE7F3FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.edit,
                  color: Color(0xFF2563EB),
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Editar perfil',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        // Configuracion
        PopupMenuItem<String>(
          value: 'settings',
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.settings_outlined,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Configuracion',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        // Archivadas
        PopupMenuItem<String>(
          value: 'archived',
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.archive_outlined,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Publicaciones archivadas',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        PopupMenuDivider(),
        // Cerrar sesion
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFFFFE4E4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.logout,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Cerrar sesion',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'edit':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EditProfileScreen()),
            ).then((_) => _loadProfile());
            break;
          case 'settings':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SettingsScreen()),
            );
            break;
          case 'archived':
            // Navegar a archivadas
            break;
          case 'logout':
            _logout();
            break;
        }
      },
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.outlineVariant.withAlpha(100),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(
          Icons.more_vert,
          color: AppTheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildAvatarFallback(dynamic userName) {
    return Center(
      child: Text(
        userName.toString().isNotEmpty
            ? userName.toString()[0].toUpperCase()
            : 'U',
        style: TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryBlue, size: 22),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: AppTheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: AppTheme.outline, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildStatClickable(
    String label,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryBlue, size: 22),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: AppTheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(color: AppTheme.outline, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 40, color: AppTheme.outlineVariant);
  }

  void _showAddPostOptions(BuildContext parentContext) {
    final ImagePicker picker = ImagePicker();
    
    showModalBottomSheet(
      context: parentContext,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Crear publicación',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface,
                  ),
                ),
                SizedBox(height: 24),
                _AddPostOption(
                  icon: Icons.camera_alt,
                  label: 'Cámara',
                  description: 'Toma una foto ahora',
                  gradient: AppTheme.buttonGradient,
                  onTap: () async {
                    // Cerrar el modal primero
                    Navigator.pop(sheetContext);
                    
                    // Esperar a que se cierre el modal
                    await Future.delayed(Duration(milliseconds: 100));
                    
                    final XFile? photo = await picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 85,
                    );
                    
                    if (photo != null && parentContext.mounted) {
                      Navigator.of(parentContext).push(
                        MaterialPageRoute(
                          builder: (context) => CreatePostScreen(
                            initialImages: [photo],
                          ),
                        ),
                      );
                    }
                  },
                ),
                SizedBox(height: 12),
                _AddPostOption(
                  icon: Icons.photo_library,
                  label: 'Galería',
                  description: 'Elige de tu biblioteca',
                  gradient: LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF34D399)],
                  ),
                  onTap: () async {
                    // Cerrar el modal primero
                    Navigator.pop(sheetContext);
                    
                    // Esperar a que se cierre el modal
                    await Future.delayed(Duration(milliseconds: 100));
                    
                    final List<XFile> photos = await picker.pickMultiImage(
                      imageQuality: 85,
                    );
                    
                    if (photos.isNotEmpty && parentContext.mounted) {
                      Navigator.of(parentContext).push(
                        MaterialPageRoute(
                          builder: (context) => CreatePostScreen(
                            initialImages: photos,
                          ),
                        ),
                      );
                    }
                  },
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
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
              color: AppTheme.outlineVariant.withAlpha(100),
              blurRadius: 10,
              offset: Offset(0, 4),
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
                    child: Center(
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
                      Icon(Icons.favorite, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        _formatNumber(post['likes'] ?? 0),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(
                        Icons.visibility,
                        color: Colors.white,
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        _formatNumber(post['views'] ?? 0),
                        style: TextStyle(
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

  void _showUsersModal(
    BuildContext context,
    String title,
    List<Map<String, dynamic>>? users,
  ) {
    if (users == null || users.isEmpty) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UsersListModal(
        title: title,
        users: users,
        onFollowToggle: (index) {
          setState(() {
            users[index]['isFollowing'] = !users[index]['isFollowing'];
          });
        },
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
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Header arrastrable
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.textPrimary.withAlpha(20),
                      blurRadius: 8,
                      offset: Offset(0, 2),
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
                        color: AppTheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Título y acciones
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Notificaciones',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
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
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _FilterChip(label: 'Todas', isActive: true),
                    SizedBox(width: 8),
                    _FilterChip(label: 'No leídas', isActive: false),
                  ],
                ),
              ),

              // Lista de notificaciones
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 0),
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

                    SizedBox(height: 40),
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
      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          if (title == 'Nuevas')
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
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
        color: isRead ? AppTheme.surfaceContainerLowest : AppTheme.primaryBlue.withAlpha(20),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                      color: AppTheme.outlineVariant,
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
                        color: Color(0xFF2563EB),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12),
            // Contenido
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Texto de la notificación
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.35,
                        color: AppTheme.textPrimary,
                      ),
                      children: [
                        TextSpan(
                          text: notification['title'] as String,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        TextSpan(
                          text: ' ${notification['message']}',
                          style: TextStyle(fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4),
                  // Tiempo
                  Text(
                    notification['time'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      color: isRead ? AppTheme.textLight : Color(0xFF2563EB),
                      fontWeight: isRead ? FontWeight.w400 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Menú de opciones
            IconButton(
              icon: Icon(Icons.more_horiz, color: AppTheme.textLight),
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
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
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Color(0xFFE7F3FF) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isActive ? Color(0xFF2563EB) : Colors.grey.shade700,
        ),
      ),
    );
  }
}

// Opción para crear post
class _AddPostOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Gradient gradient;
  final VoidCallback onTap;

  const _AddPostOption({
    required this.icon,
    required this.label,
    required this.description,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFFF0F0FF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// MODAL DE USUARIOS (SEGUIDORES/SIGUIENDO) ESTILO INSTAGRAM
// ============================================================================

class UsersListModal extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> users;
  final Function(int) onFollowToggle;

  const UsersListModal({
    super.key,
    required this.title,
    required this.users,
    required this.onFollowToggle,
  });

  @override
  State<UsersListModal> createState() => _UsersListModalState();
}

class _UsersListModalState extends State<UsersListModal> {
  final TextEditingController _searchController = TextEditingController();
  late List<Map<String, dynamic>> _filteredUsers;
  late List<int> _originalIndices;

  @override
  void initState() {
    super.initState();
    final usersList = widget.users;
    _filteredUsers = List<Map<String, dynamic>>.from(usersList);
    _originalIndices = List<int>.generate(usersList.length, (i) => i);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterUsers(String query) {
    setState(() {
      final usersList = widget.users;
      if (query.isEmpty) {
        _filteredUsers = List<Map<String, dynamic>>.from(usersList);
        _originalIndices = List<int>.generate(usersList.length, (i) => i);
      } else {
        _filteredUsers = <Map<String, dynamic>>[];
        _originalIndices = <int>[];
        for (int i = 0; i < usersList.length; i++) {
          final user = usersList[i];
          final name = user['name']?.toString().toLowerCase() ?? '';
          final username = user['username']?.toString().toLowerCase() ?? '';
          if (name.contains(query.toLowerCase()) ||
              username.contains(query.toLowerCase())) {
            _filteredUsers.add(user);
            _originalIndices.add(i);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      ' ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterUsers,
                    decoration: InputDecoration(
                      hintText: 'Buscar',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey.shade500,
                      ),
                      prefixIconConstraints: BoxConstraints(
                        minWidth: 40,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _filteredUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey.shade300,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No se encontraron usuarios',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: EdgeInsets.symmetric(vertical: 8),
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          final originalIndex = _originalIndices[index];
                          return _UserListItem(
                            user: user,
                            onFollowToggle: () {
                              widget.onFollowToggle(originalIndex);
                              setState(() {});
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _UserListItem extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onFollowToggle;

  const _UserListItem({
    required this.user,
    required this.onFollowToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isFollowing = user['isFollowing'] as bool? ?? false;
    final avatar = user['avatar']?.toString() ?? '?';
    final username = user['username']?.toString() ?? '@usuario';
    final name = user['name']?.toString() ?? 'Usuario';

    return InkWell(
      onTap: () {},
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                ),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Center(
                child: Text(
                  avatar,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onFollowToggle,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isFollowing ? Colors.transparent : Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(8),
                  border: isFollowing
                      ? Border.all(color: Colors.grey.shade300)
                      : null,
                ),
                child: Text(
                  isFollowing ? 'Siguiendo' : 'Seguir',
                  style: TextStyle(
                    color: isFollowing ? AppTheme.onSurface : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



