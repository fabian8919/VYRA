import 'package:flutter/material.dart';
import 'package:vyra/core/theme/app_theme.dart';
import 'package:vyra/services/post_service.dart';
import 'package:vyra/services/auth_service.dart';

class CommentsBottomSheet extends StatefulWidget {
  final String postId;
  final int commentCount;
  final String postUsername;
  final ValueChanged<int>? onCommentAdded;

  const CommentsBottomSheet({
    super.key,
    required this.postId,
    required this.commentCount,
    required this.postUsername,
    this.onCommentAdded,
  });

  static Future<void> show(
    BuildContext context, {
    required String postId,
    required int commentCount,
    required String postUsername,
    ValueChanged<int>? onCommentAdded,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(140),
      builder: (_) => CommentsBottomSheet(
        postId: postId,
        commentCount: commentCount,
        postUsername: postUsername,
        onCommentAdded: onCommentAdded,
      ),
    );
  }

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<Map<String, dynamic>> _comments = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isSending = false;
  String? _replyingToUsername;
  String? _replyingToParentId;
  final Set<String> _expandedReplies = {};
  int _newCommentsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    try {
      final comments = await PostService().getComments(widget.postId);
      if (mounted) {
        setState(() {
          _comments.addAll(comments);
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Future<void> _sendComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);

    final replyingParentId = _replyingToParentId;

    try {
      final newComment = await PostService().createComment(
        postId: widget.postId,
        contenido: text,
        parentId: replyingParentId,
      );

      if (mounted) {
        setState(() {
          _comments.insert(0, newComment);
          _controller.clear();
          _replyingToUsername = null;
          _replyingToParentId = null;
          _isSending = false;
          _newCommentsCount++;
          if (replyingParentId != null) {
            _expandedReplies.add(replyingParentId);
          }
        });
        widget.onCommentAdded?.call(widget.commentCount + _newCommentsCount);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceFirst("Exception: ", "")}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _replyTo(Map<String, dynamic> comment) {
    final username = _extractUsername(comment).replaceFirst('@', '');
    final rootParentId = (comment['parent_id'] as String?) ??
        (comment['id'] as String?);
    setState(() {
      _replyingToUsername = username;
      _replyingToParentId = rootParentId;
    });
    _focusNode.requestFocus();
  }

  void _toggleReplies(String rootId) {
    setState(() {
      if (_expandedReplies.contains(rootId)) {
        _expandedReplies.remove(rootId);
      } else {
        _expandedReplies.add(rootId);
      }
    });
  }

  List<Map<String, dynamic>> get _topLevelComments {
    return _comments
        .where((c) => c['parent_id'] == null)
        .toList();
  }

  List<Map<String, dynamic>> _repliesFor(String parentId) {
    final replies = _comments
        .where((c) {
          final pid = c['parent_id'];
          return pid == parentId;
        })
        .toList();
    replies.sort((a, b) {
      final ad = DateTime.tryParse(a['created_at'] as String? ?? '') ??
          DateTime.now();
      final bd = DateTime.tryParse(b['created_at'] as String? ?? '') ??
          DateTime.now();
      return ad.compareTo(bd);
    });
    return replies;
  }

  String _timeAgo(String? createdAt) {
    if (createdAt == null) return 'Ahora';
    final date = DateTime.tryParse(createdAt);
    if (date == null) return 'Ahora';
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 7) return '${(diff.inDays / 7).floor()} sem';
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'Ahora';
  }

  String _extractUsername(Map<String, dynamic> comment) {
    final profiles = comment['profiles'] as Map<String, dynamic>?;
    final username = profiles?['username'] as String?;
    if (username != null && username.isNotEmpty) {
      return username.startsWith('@') ? username : '@$username';
    }
    return '@usuario';
  }

  String _extractAvatarLetter(Map<String, dynamic> comment) {
    final profiles = comment['profiles'] as Map<String, dynamic>?;
    final username = profiles?['username'] as String?;
    if (username != null && username.isNotEmpty) {
      return username[0].toUpperCase();
    }
    return 'U';
  }

  String? _extractAvatarUrl(Map<String, dynamic> comment) {
    final profiles = comment['profiles'] as Map<String, dynamic>?;
    final url = profiles?['avatar_url'] as String?;
    return (url != null && url.isNotEmpty) ? url : null;
  }

  String? _parentUsernameFor(Map<String, dynamic> comment) {
    final parentId = comment['parent_id'] as String?;
    if (parentId == null) return null;
    final parent = _comments.firstWhere(
      (c) => c['id'] == parentId,
      orElse: () => {},
    );
    if (parent.isEmpty) return null;
    return _extractUsername(parent).replaceFirst('@', '');
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      snap: true,
      snapSizes: const [0.4, 0.65, 0.9],
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _buildHandle(),
              _buildHeader(),
              const Divider(color: Color(0xFF2A2A2A), height: 1),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : _errorMessage != null
                        ? _buildErrorState()
                        : _comments.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                key: ValueKey(_comments.length),
                                controller: scrollController,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                addAutomaticKeepAlives: false,
                                addRepaintBoundaries: false,
                                itemCount: _topLevelComments.length,
                                itemBuilder: (context, index) {
                                  return _buildThreadedComment(
                                    _topLevelComments[index],
                                  );
                                },
                              ),
              ),
              _buildInputBar(bottomInset),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey.shade600,
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
            '${_comments.length} comentarios',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.close, color: Colors.white, size: 22),
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
          Icon(Icons.chat_bubble_outline, color: Colors.grey.shade600, size: 48),
          const SizedBox(height: 12),
          Text(
            'Aún no hay comentarios',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Sé el primero en comentar',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.grey, size: 48),
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _loadComments,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildThreadedComment(Map<String, dynamic> rootComment) {
    final rootId = rootComment['id'] as String? ?? '';
    final replies = _repliesFor(rootId);
    final isExpanded = _expandedReplies.contains(rootId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCommentTile(rootComment, isReply: false),
        if (replies.isNotEmpty)
          _buildRepliesToggle(rootId, replies.length, isExpanded),
        if (isExpanded)
          _buildExpandedReplies(replies),
      ],
    );
  }

  Widget _buildRepliesToggle(String rootId, int count, bool isExpanded) {
    return Padding(
      padding: const EdgeInsets.only(left: 56, bottom: 12, top: 2),
      child: GestureDetector(
        onTap: () => _toggleReplies(rootId),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 1,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 10),
            Text(
              isExpanded
                  ? 'Ocultar respuestas'
                  : 'Ver $count ${count == 1 ? "respuesta más" : "respuestas más"}',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedReplies(List<Map<String, dynamic>> replies) {
    return Container(
      margin: const EdgeInsets.only(left: 16),
      padding: const EdgeInsets.only(left: 12),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Colors.grey.shade800,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: replies
            .map((reply) => _buildCommentTile(reply, isReply: true))
            .toList(),
      ),
    );
  }

  Widget _buildCommentTile(Map<String, dynamic> comment, {bool isReply = false}) {
    final username = _extractUsername(comment);
    final avatarLetter = _extractAvatarLetter(comment);
    final avatarUrl = _extractAvatarUrl(comment);
    final text = comment['contenido'] as String? ?? '';
    final timeAgo = _timeAgo(comment['created_at'] as String?);
    final likes = (comment['likes_count'] as int?) ?? 0;
    final parentUsername = isReply ? _parentUsernameFor(comment) : null;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: isReply ? 6 : 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          _buildAvatar(avatarUrl, avatarLetter, isReply ? 28 : 34),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.white.withAlpha(230),
                      fontSize: 13,
                      height: 1.3,
                    ),
                    children: [
                      TextSpan(
                        text: '$username ',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (parentUsername != null)
                        TextSpan(
                          text: '@$parentUsername ',
                          style: TextStyle(
                            color: Colors.blue.shade300,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      TextSpan(
                        text: text,
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      timeAgo,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => _replyTo(comment),
                      child: Text(
                        'Responder',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Like
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {},
                child: Icon(
                  Icons.favorite_border,
                  color: Colors.grey.shade400,
                  size: 16,
                ),
              ),
              if (likes > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    '$likes',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? url, String letter, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppTheme.buttonGradient,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: url != null
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Text(
                    letter,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size * 0.4,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            : Center(
                child: Text(
                  letter,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size * 0.4,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildInputBar(double bottomInset) {
    final authUser = AuthService().currentUser;
    final userInitial = authUser?.name?.isNotEmpty == true
        ? authUser!.name![0].toUpperCase()
        : (authUser?.email.isNotEmpty == true ? authUser!.email[0].toUpperCase() : 'T');

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 10,
        bottom: bottomInset > 0 ? bottomInset + 8 : 16,
      ),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Colors.grey.shade800)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_replyingToUsername != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(
                    'Respondiendo a @$_replyingToUsername',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() {
                      _replyingToUsername = null;
                      _replyingToParentId = null;
                    }),
                    child: Icon(
                      Icons.close,
                      color: Colors.grey.shade500,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: AppTheme.buttonGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    userInitial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    cursorColor: Colors.white54,
                    maxLines: 1,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: _replyingToUsername != null
                          ? 'Responder a @$_replyingToUsername...'
                          : 'Añade un comentario...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
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
              IconButton(
                onPressed: _isSending ? null : _sendComment,
                icon: _isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.blue,
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        color: Colors.blue,
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
