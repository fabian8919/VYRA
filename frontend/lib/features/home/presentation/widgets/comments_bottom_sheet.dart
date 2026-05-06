import 'package:flutter/material.dart';
import 'package:vyra/core/theme/app_theme.dart';

class CommentsBottomSheet extends StatefulWidget {
  final int commentCount;
  final String postUsername;

  const CommentsBottomSheet({
    super.key,
    required this.commentCount,
    required this.postUsername,
  });

  /// Shows the comments sheet and returns when dismissed.
  static Future<void> show(
    BuildContext context, {
    required int commentCount,
    required String postUsername,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(140),
      builder: (_) => CommentsBottomSheet(
        commentCount: commentCount,
        postUsername: postUsername,
      ),
    );
  }

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<_Comment> _comments = [];
  String? _replyingTo;

  @override
  void initState() {
    super.initState();
    _comments.addAll(_mockComments);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendComment() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _comments.insert(
        0,
        _Comment(
          username: 'Tú',
          avatar: 'T',
          text: _replyingTo != null ? '@$_replyingTo $text' : text,
          timeAgo: 'Ahora',
          likes: 0,
        ),
      );
      _controller.clear();
      _replyingTo = null;
    });
  }

  void _replyTo(String username) {
    setState(() => _replyingTo = username);
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.pop(context),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.85,
        snap: true,
        snapSizes: const [0.4, 0.6, 0.85],
        builder: (context, scrollController) {
          return GestureDetector(
            onTap: () {},
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  _buildHandle(),

                  // Header
                  _buildHeader(),

                  Divider(color: AppTheme.outlineVariant.withAlpha(30), height: 1),

                  // Comments list
                  Expanded(
                    child: _comments.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            itemCount: _comments.length,
                            itemBuilder: (context, index) {
                              return _buildCommentTile(_comments[index]);
                            },
                          ),
                  ),

                  // Input field
                  _buildInputBar(bottomInset),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppTheme.textSecondary.withAlpha(60),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Text(
            '${widget.commentCount} comentarios',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.close, color: AppTheme.textSecondary, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline, color: AppTheme.textLight.withAlpha(60), size: 48),
          SizedBox(height: 12),
          Text(
            'Aún no hay comentarios',
            style: TextStyle(color: AppTheme.textLight.withAlpha(80), fontSize: 14),
          ),
          SizedBox(height: 4),
          Text(
            'Sé el primero en comentar',
            style: TextStyle(color: AppTheme.textLight.withAlpha(60), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentTile(_Comment comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppTheme.buttonGradient,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(
                comment.avatar,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.username,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      comment.timeAgo,
                      style: TextStyle(
                        color: AppTheme.textLight.withAlpha(80),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.text,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _replyTo(comment.username),
                      child: Text(
                        'Responder',
                        style: TextStyle(
                          color: AppTheme.textLight.withAlpha(80),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.favorite_border,
                      color: AppTheme.textLight.withAlpha(80),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      comment.likes > 0 ? '${comment.likes}' : '',
                      style: TextStyle(
                        color: AppTheme.textLight.withAlpha(80),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(double bottomInset) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 10,
        bottom: bottomInset > 0 ? bottomInset + 8 : 16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        border: Border(top: BorderSide(color: AppTheme.outlineVariant.withAlpha(40))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Reply indicator
          if (_replyingTo != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(
                    'Respondiendo a $_replyingTo',
                    style: TextStyle(color: AppTheme.textLight.withAlpha(80), fontSize: 12),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _replyingTo = null),
                    child: Icon(
                      Icons.close,
                      color: AppTheme.textLight.withAlpha(80),
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),

          Row(
            children: [
              // User avatar
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: AppTheme.buttonGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'T',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Text field
              Expanded(
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppTheme.textPrimary.withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                    cursorColor: Colors.white54,
                    maxLines: 1,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: _replyingTo != null
                          ? 'Responder a $_replyingTo...'
                          : 'Añade un comentario...',
                      hintStyle: TextStyle(
                        color: AppTheme.textSecondary.withAlpha(100),
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    onSubmitted: (_) => _sendComment(),
                  ),
                ),
              ),

              // Send button
              IconButton(
                onPressed: _sendComment,
                icon: const Icon(
                  Icons.send_rounded,
                  color: AppTheme.primaryBlue,
                  size: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Comment {
  final String username;
  final String avatar;
  final String text;
  final String timeAgo;
  final int likes;

  const _Comment({
    required this.username,
    required this.avatar,
    required this.text,
    required this.timeAgo,
    required this.likes,
  });
}

// Mock data
const _mockComments = [
  _Comment(
    username: '@maría_garcía',
    avatar: 'M',
    text: '¡Qué hermosa foto! Me encanta la composición 😍',
    timeAgo: '15 min',
    likes: 24,
  ),
  _Comment(
    username: '@carlos_lopez',
    avatar: 'C',
    text: 'Increíble captura, ¿qué cámara usaste?',
    timeAgo: '32 min',
    likes: 8,
  ),
  _Comment(
    username: '@laura_art',
    avatar: 'L',
    text: 'Los colores son espectaculares 🎨✨',
    timeAgo: '1h',
    likes: 15,
  ),
  _Comment(
    username: '@pedro_viajero',
    avatar: 'P',
    text: 'Quiero ir a ese lugar, ¿dónde es exactamente?',
    timeAgo: '1h',
    likes: 3,
  ),
  _Comment(
    username: '@ana_foto',
    avatar: 'A',
    text:
        'La iluminación es perfecta. Se nota que esperaste el momento justo para tomar la foto.',
    timeAgo: '2h',
    likes: 42,
  ),
  _Comment(
    username: '@diego_nature',
    avatar: 'D',
    text: 'Naturaleza pura 🌿',
    timeAgo: '3h',
    likes: 11,
  ),
  _Comment(
    username: '@sofia_travels',
    avatar: 'S',
    text: '¡Definitivamente en mi lista de viajes! Gracias por compartir 🙌',
    timeAgo: '4h',
    likes: 19,
  ),
  _Comment(
    username: '@juan_photo',
    avatar: 'J',
    text: 'Me inspiras a salir más con la cámara 📸',
    timeAgo: '5h',
    likes: 7,
  ),
];
