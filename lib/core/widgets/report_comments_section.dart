import 'package:flutter/material.dart';

import '../models/report_comment_model.dart';
import '../services/auth_service.dart';
import '../services/bolajonim_api.dart';
import '../services/teacher_api.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/report_format_utils.dart';

typedef ReportCommentsLoader = Future<List<ReportCommentModel>> Function();
typedef ReportCommentPoster = Future<ReportCommentModel> Function({
  required String commentText,
  int? parentCommentNo,
});

class ReportCommentsSection extends StatefulWidget {
  final int reportNo;
  final bool enabled;
  final ReportCommentsLoader loadComments;
  final ReportCommentPoster postComment;

  const ReportCommentsSection({
    super.key,
    required this.reportNo,
    required this.enabled,
    required this.loadComments,
    required this.postComment,
  });

  @override
  State<ReportCommentsSection> createState() => _ReportCommentsSectionState();
}

class _ReportCommentsSectionState extends State<ReportCommentsSection> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  List<ReportCommentModel>? _comments;
  bool _loading = true;
  bool _posting = false;
  String? _error;
  int? _replyToCommentNo;
  String? _replyToAuthorNm;
  String? _currentUserId;
  String? _currentUserPhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _reload();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final userId = await AuthService.getUserId();
    String? photoUrl;
    final role = await AuthService.getUserRole();
    if (role != 'parent') {
      try {
        final profile = await TeacherApi.getStaffPersonalProfile();
        photoUrl = BolajonimApi.resolveMediaUrl(profile.photoUrl);
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() {
      _currentUserId = userId;
      _currentUserPhotoUrl = photoUrl;
    });
  }

  Future<void> _reload() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final comments = await widget.loadComments();
      if (!mounted) return;
      setState(() {
        _comments = comments;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  void _startReply(ReportCommentModel comment) {
    setState(() {
      _replyToCommentNo = comment.commentNo;
      _replyToAuthorNm = comment.authorNm;
    });
    _focusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyToCommentNo = null;
      _replyToAuthorNm = null;
    });
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _posting) return;

    setState(() => _posting = true);
    try {
      final created = await widget.postComment(
        commentText: text,
        parentCommentNo: _replyToCommentNo,
      );
      if (!mounted) return;
      setState(() {
        _comments = [...?_comments, created];
        _posting = false;
      });
      _controller.clear();
      _cancelReply();
    } catch (e) {
      if (!mounted) return;
      setState(() => _posting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Yuborib bo‘lmadi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Izohlar',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (_error != null)
            Text(_error!, style: AppTextStyles.bodySmall)
          else if (_comments == null || _comments!.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Hali xabar yo‘q. Birinchi izohni yozing.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            ..._comments!.map((comment) {
              final isMine = comment.authorUserId == _currentUserId;
              final photoUrl = isMine
                  ? _currentUserPhotoUrl
                  : BolajonimApi.resolveMediaUrl(comment.authorPhotoUrl);
              return _ChatBubble(
                comment: comment,
                isMine: isMine,
                photoUrl: photoUrl,
                onReply: isMine ? null : () => _startReply(comment),
              );
            }),
          if (_replyToAuthorNm != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Javob: ${_replyToAuthorNm!}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _posting ? null : _cancelReply,
                    child: const Icon(Icons.close_rounded, size: 18),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Xabar yozing...',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF3F5F8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 11,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: AppColors.primary,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: _posting ? null : _submit,
                  customBorder: const CircleBorder(),
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Center(
                      child: _posting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.send_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ReportCommentModel comment;
  final bool isMine;
  final String? photoUrl;
  final VoidCallback? onReply;

  const _ChatBubble({
    required this.comment,
    required this.isMine,
    this.photoUrl,
    this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    final time = ReportFormatUtils.formatCommentTime(comment.createdAt);
    final bubbleColor = isMine
        ? AppColors.primary.withValues(alpha: 0.14)
        : const Color(0xFFF0F2F5);
    final textColor = AppColors.textPrimary;
    final timeColor = AppColors.textSecondary.withValues(alpha: 0.85);

    final bubble = ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.68,
      ),
      child: GestureDetector(
        onLongPress: onReply,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMine ? 16 : 4),
              bottomRight: Radius.circular(isMine ? 4 : 16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                comment.commentText,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.35,
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  time,
                  style: TextStyle(fontSize: 10.5, color: timeColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final avatar = _CommentAvatar(
      name: comment.authorNm,
      photoUrl: photoUrl,
      isMine: isMine,
    );

    final nameLabel = Padding(
      padding: EdgeInsets.only(
        left: isMine ? 0 : 4,
        right: isMine ? 4 : 0,
        bottom: 4,
      ),
      child: Text(
        comment.authorNm,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
        textAlign: isMine ? TextAlign.right : TextAlign.left,
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: isMine
            ? [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [nameLabel, bubble],
                  ),
                ),
                const SizedBox(width: 8),
                avatar,
              ]
            : [
                avatar,
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [nameLabel, bubble],
                  ),
                ),
              ],
      ),
    );
  }
}

class _CommentAvatar extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final bool isMine;

  const _CommentAvatar({
    required this.name,
    this.photoUrl,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    return CircleAvatar(
      radius: 17,
      backgroundColor: isMine
          ? AppColors.primary.withValues(alpha: 0.15)
          : const Color(0xFFE8EEF5),
      backgroundImage:
          photoUrl != null && photoUrl!.isNotEmpty ? NetworkImage(photoUrl!) : null,
      child: photoUrl == null || photoUrl!.isEmpty
          ? Text(
              initial,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isMine ? AppColors.primary : AppColors.textSecondary,
              ),
            )
          : null,
    );
  }
}
