import 'package:flutter/material.dart';
import 'package:vyra/core/theme/app_theme.dart';

class PostDetailScreen extends StatefulWidget {
  final Map<String, dynamic> post;
  final String? username;
  final String? avatarUrl;
  final String? fullName;

  const PostDetailScreen({
    super.key,
    required this.post,
    this.username,
    this.avatarUrl,
    this.fullName,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  bool _isLiked = false;

  List<String> get _imageUrls {
    final urls = widget.post['image_urls'];
    if (urls is List) {
      return urls.whereType<String>().toList();
    }
    return [];
  }

  String get _description {
    return widget.post['descripcion']?.toString() ?? '';
  }

  String get _createdAt {
    final raw = widget.post['created_at'];
    if (raw == null) return '';
    try {
      final date = DateTime.parse(raw.toString());
      return _formatDate(date);
    } catch (_) {
      return raw.toString();
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Justo ahora';
    if (diff.inHours < 1) return 'Hace ${diff.inMinutes} min';
    if (diff.inDays < 1) return 'Hace ${diff.inHours} h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} d';
    if (diff.inDays < 30) return 'Hace ${(diff.inDays / 7).floor()} sem';

    return '${date.day}/${date.month}/${date.year}';
  }

  String get _displayName {
    return widget.fullName ?? widget.username ?? 'Usuario';
  }

  String get _userHandle {
    final name = widget.username ?? _displayName;
    return name.startsWith('@') ? name : '@$name';
  }

  String get _initials {
    final name = _displayName;
    if (name.isEmpty) return 'U';
    return name[0].toUpperCase();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Publicación',
          style: TextStyle(
            color: AppTheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: AppTheme.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar + username
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: AppTheme.buttonGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipOval(
                      child: widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty
                          ? Image.network(
                              widget.avatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _avatarFallback(),
                            )
                          : _avatarFallback(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _displayName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.onSurface,
                          ),
                        ),
                        if (_userHandle != _displayName)
                          Text(
                            _userHandle,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Carrusel de imágenes
            if (_imageUrls.isNotEmpty)
              AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() => _currentImageIndex = index);
                      },
                      itemCount: _imageUrls.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          _imageUrls[index],
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
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(Icons.broken_image, color: Colors.grey, size: 48),
                            ),
                          ),
                        );
                      },
                    ),
                    // Contador de imágenes
                    if (_imageUrls.length > 1)
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(153),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${_currentImageIndex + 1}/${_imageUrls.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    // Indicadores de página (dots)
                    if (_imageUrls.length > 1)
                      Positioned(
                        bottom: 12,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _imageUrls.length,
                            (index) => Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentImageIndex == index
                                    ? Colors.white
                                    : Colors.white.withAlpha(102),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              )
            else
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  color: Colors.grey.shade100,
                  child: const Center(
                    child: Icon(Icons.image_not_supported, color: Colors.grey, size: 64),
                  ),
                ),
              ),

            // Barra de acciones
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _isLiked = !_isLiked),
                    child: Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_border,
                      color: _isLiked ? Colors.red : AppTheme.onSurface,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.chat_bubble_outline, color: AppTheme.onSurface, size: 26),
                  const SizedBox(width: 16),
                  Icon(Icons.send_outlined, color: AppTheme.onSurface, size: 26),
                  const Spacer(),
                  Icon(Icons.bookmark_border, color: AppTheme.onSurface, size: 26),
                ],
              ),
            ),

            // Likes (placeholder)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '0 me gusta',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurface,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Descripción
            if (_description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 15,
                      color: AppTheme.onSurface,
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(
                        text: '$_userHandle ',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(text: _description),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 8),

            // Fecha
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _createdAt.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _avatarFallback() {
    return Center(
      child: Text(
        _initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
