import 'package:flutter/material.dart';
import 'package:vyra/core/theme/app_theme.dart';
import 'package:vyra/services/auth_service.dart';

class ProfileUnknownScreen extends StatefulWidget {
  final String userId;

  const ProfileUnknownScreen({super.key, required this.userId});

  @override
  State<ProfileUnknownScreen> createState() => _ProfileUnknownScreenState();
}

class _ProfileUnknownScreenState extends State<ProfileUnknownScreen> {
  final _authService = AuthService();
  bool _isGridView = true;
  bool _isLoadingProfile = true;
  Map<String, dynamic>? _profileData;
  final ScrollController _scrollController = ScrollController();
  


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
    try {
      final profile = await _authService.getProfile(widget.userId);
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
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
      return const Scaffold(
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
                                color: AppTheme.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.outlineVariant.withAlpha(100),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.arrow_back,
                                color: AppTheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox.shrink(),
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

                    const SizedBox(height: 20),

                    // Nombre completo
                    Text(
                      fullName ?? nickName,
                      style: const TextStyle(
                        color: AppTheme.onSurface,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    if (fullName != null && fullName.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          nickName,
                          style: const TextStyle(
                            color: AppTheme.onSurfaceVariant,
                            fontSize: 16,
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Bio
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        userBio,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.onSurfaceVariant,
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

            // Stats Card - Diseño proporcionado
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Divider(
                        height: 1,
                        color: AppTheme.outlineVariant.withAlpha(100),
                      ),
                    ),
                    // Segunda fila: Seguidores, Siguiendo (2 columnas centradas)
                    Row(
                      children: [
                        // Espacio vacío a la izquierda (1/6 del ancho)
                        const Expanded(flex: 1, child: SizedBox()),
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
                        const Expanded(flex: 1, child: SizedBox()),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Tabs
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
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
                          padding: const EdgeInsets.symmetric(vertical: 14),
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
                          padding: const EdgeInsets.symmetric(vertical: 14),
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

  Widget _buildAvatarFallback(dynamic userName) {
    return Center(
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
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryBlue, size: 22),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: AppTheme.outline, fontSize: 12),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryBlue, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: AppTheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: AppTheme.outline, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 40, color: AppTheme.outlineVariant);
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
                        _formatNumber(post['likes'] ?? 0),
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
                        _formatNumber(post['views'] ?? 0),
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
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    const SizedBox(height: 16),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 40,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
                            const SizedBox(height: 16),
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
                        padding: const EdgeInsets.symmetric(vertical: 8),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                ),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Center(
                child: Text(
                  avatar,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
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
                    username,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isFollowing ? Colors.transparent : const Color(0xFF2563EB),
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



