import 'package:flutter/material.dart';
import 'package:vyra/core/theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _query = '';

  final List<Map<String, dynamic>> _trending = [
    {'tag': 'Atardecer', 'posts': '12.5K publicaciones', 'icon': Icons.local_fire_department},
    {'tag': 'Fotografía callejera', 'posts': '8.3K publicaciones', 'icon': Icons.local_fire_department},
    {'tag': 'Naturaleza', 'posts': '45.2K publicaciones', 'icon': Icons.local_fire_department},
    {'tag': 'Retratos', 'posts': '23.1K publicaciones', 'icon': Icons.local_fire_department},
    {'tag': 'Viajes Colombia', 'posts': '6.7K publicaciones', 'icon': Icons.local_fire_department},
    {'tag': 'Arquitectura', 'posts': '9.8K publicaciones', 'icon': Icons.local_fire_department},
    {'tag': 'Paisajes nocturnos', 'posts': '4.1K publicaciones', 'icon': Icons.local_fire_department},
    {'tag': 'Comida colombiana', 'posts': '15.9K publicaciones', 'icon': Icons.local_fire_department},
  ];

  final List<Map<String, dynamic>> _suggestedUsers = [
    {'name': 'María García', 'username': '@maria_g', 'avatar': 'M', 'followers': '12.5K'},
    {'name': 'Carlos López', 'username': '@carlos_foto', 'avatar': 'C', 'followers': '8.2K'},
    {'name': 'Laura Martínez', 'username': '@laura_art', 'avatar': 'L', 'followers': '25.1K'},
    {'name': 'Diego Herrera', 'username': '@diego_nature', 'avatar': 'D', 'followers': '5.7K'},
    {'name': 'Sofía Rodríguez', 'username': '@sofia_travels', 'avatar': 'S', 'followers': '18.3K'},
  ];

  final List<String> _recentSearches = [
    'paisajes colombianos',
    '@photography_lover',
    'atardecer playa',
    'cámara Sony A7',
    'edición fotos',
  ];

  List<Map<String, dynamic>> get _filteredTrending {
    if (_query.isEmpty) return _trending;
    return _trending
        .where((t) => t['tag'].toString().toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  List<Map<String, dynamic>> get _filteredUsers {
    if (_query.isEmpty) return _suggestedUsers;
    return _suggestedUsers
        .where((u) =>
            u['name'].toString().toLowerCase().contains(_query.toLowerCase()) ||
            u['username'].toString().toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  List<String> get _filteredRecent {
    if (_query.isEmpty) return _recentSearches;
    return _recentSearches
        .where((r) => r.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  if (_filteredRecent.isNotEmpty && _query.isEmpty) ...[
                    _buildSectionHeader('Búsquedas recientes', showClear: true),
                    _buildRecentSearches(),
                    const SizedBox(height: 20),
                  ],
                  if (_filteredUsers.isNotEmpty) ...[
                    _buildSectionHeader(
                      _query.isEmpty ? 'Usuarios sugeridos' : 'Usuarios',
                    ),
                    _buildUsersList(),
                    const SizedBox(height: 20),
                  ],
                  if (_filteredTrending.isNotEmpty) ...[
                    _buildSectionHeader(
                      _query.isEmpty ? 'Tendencias' : 'Resultados',
                    ),
                    _buildTrendingList(),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary, size: 20),
          ),

          // Search field
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.textPrimary.withAlpha(20),
                borderRadius: BorderRadius.circular(22),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                cursorColor: AppTheme.primaryBlue,
                decoration: InputDecoration(
                  hintText: 'Buscar usuarios, fotos, tags...',
                  hintStyle: TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppTheme.textLight,
                    size: 20,
                  ),
                  suffixIcon: _query.isNotEmpty
                      ? GestureDetector(
                          onTap: () => _searchController.clear(),
                          child: Icon(
                            Icons.close,
                            color: AppTheme.textLight,
                            size: 18,
                          ),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool showClear = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          if (showClear)
            GestureDetector(
              onTap: () => setState(() => _recentSearches.clear()),
              child: Text(
                'Borrar todo',
                style: TextStyle(
                  color: AppTheme.primaryBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Column(
      children: _filteredRecent.map((search) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          leading: Icon(
            Icons.history,
            color: AppTheme.textLight,
            size: 20,
          ),
          title: Text(
            search,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          trailing: GestureDetector(
            onTap: () {
              setState(() => _recentSearches.remove(search));
            },
            child: Icon(
              Icons.close,
              color: AppTheme.textLight,
              size: 16,
            ),
          ),
          onTap: () {
            _searchController.text = search;
            _searchController.selection = TextSelection.fromPosition(
              TextPosition(offset: search.length),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildUsersList() {
    return Column(
      children: _filteredUsers.map((user) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: AppTheme.buttonGradient,
                  borderRadius: BorderRadius.circular(23),
                ),
                child: Center(
                  child: Text(
                    user['avatar'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['name'],
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${user['username']}  •  ${user['followers']} seguidores',
                      style: TextStyle(
                        color: AppTheme.textSecondary.withAlpha(120),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Follow button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  gradient: AppTheme.buttonGradient,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  'Seguir',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTrendingList() {
    return Column(
      children: _filteredTrending.asMap().entries.map((entry) {
        final index = entry.key;
        final trend = entry.value;

        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: index < 3
                    ? AppTheme.primaryBlue.withAlpha(40)
                    : AppTheme.textPrimary.withAlpha(15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                index < 3 ? Icons.local_fire_department : Icons.tag,
                color: index < 3 ? AppTheme.primaryBlue : AppTheme.textSecondary,
                size: 20,
              ),
            ),
            title: Text(
              trend['tag'],
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              trend['posts'],
              style: TextStyle(
                color: AppTheme.textSecondary.withAlpha(90),
                fontSize: 12,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.textLight.withAlpha(50),
              size: 14,
            ),
            onTap: () {
              _searchController.text = trend['tag'];
            },
          ),
        );
      }).toList(),
    );
  }
}
