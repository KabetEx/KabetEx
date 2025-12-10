import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/common/slide_routing.dart';
import 'package:kabetex/utils/snackbars.dart';
import 'package:kabetex/features/1community/data/models/post.dart';
import 'package:kabetex/features/1community/presentation/pages/post_details_page.dart';
import 'package:kabetex/features/1community/presentation/pages/profile_page.dart';
import 'package:kabetex/features/1community/providers/feed_provider.dart';
import 'package:kabetex/features/1community/providers/user_provider.dart';
import 'package:kabetex/features/auth/presentation/login.dart';
import 'package:kabetex/utils/time_utils.dart';
import 'package:kabetex/utils/user_avatar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostWidget extends ConsumerWidget {
  final Post post;
  // final FeedNotifier feedNotifier; //for liking

  const PostWidget({
    super.key,
    required this.post,
    //  required this.feedNotifier
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loggedInUser = ref.watch(currentUserIdProvider);
    final postOwnerID = post.userId;
    final userProfileAsync = ref.watch(userByIDProvider(postOwnerID));

    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).push(SlideRouting(page: PostDetailPage(post: post)));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark ? Colors.grey[800]! : Colors.grey[400]!,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //post avatar
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  SlideRouting(page: CommunityProfilePage(userID: postOwnerID)),
                );
              },
              child: UserAvatar(userAsync: userProfileAsync),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Username + timestamp
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            post.userFullname ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            timeAgo(post.createdAt!),
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      PopupMenuButton(
                        icon: const Icon(Icons.more_horiz),
                        color: isDark ? Colors.grey : Colors.white,
                        onSelected: (value) {
                          if (value == 'report') {
                            debugPrint(
                              'Report Post action for post ID: ${post.id}',
                            );
                            // TODO: Implement actual report functionality, e.g., showReportDialog(context, post.id);
                          }
                          // TODO: Implement 'edit' and 'delete' actions
                          // Example: if (value == 'edit') { Navigator.push(context, SlideRouting(page: EditPostPage(post: post))); }
                          // Example: if (value == 'delete') { showDeleteConfirmationDialog(context, post.id); }
                        },
                        itemBuilder: (context) {
                          final isOwner = post.userId == loggedInUser;
                          if (isOwner) {
                            return [
                              const PopupMenuItem(
                                // TODO: Implement edit functionality
                                value: 'edit',
                                child: Text('Edit Post'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete Post'),
                              ),
                            ];
                          } else {
                            return [
                              const PopupMenuItem(
                                // TODO: Implement report functionality
                                value: 'report',
                                child: Text('Report Post'),
                              ),
                            ];
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    post.content,
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark
                          ? Colors.white.withAlpha(220)
                          : Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 10),

                  //actions row
                  PostWidgetActionsRow(post: post),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PostWidgetActionsRow extends ConsumerStatefulWidget {
  final Post post;

  const PostWidgetActionsRow({super.key, required this.post});

  @override
  ConsumerState<PostWidgetActionsRow> createState() =>
      _PostWidgetActionsRowState();
}

class _PostWidgetActionsRowState extends ConsumerState<PostWidgetActionsRow> {
  late bool _isLiked;
  late int _likeCount;
  bool _isLiking = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;
    _likeCount = widget.post.likeCount;
  }

  /// Ensures the local state is updated if the parent widget rebuilds with a new post object.
  @override
  void didUpdateWidget(covariant PostWidgetActionsRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.post.isLiked != oldWidget.post.isLiked ||
        widget.post.likeCount != oldWidget.post.likeCount) {
      setState(() {
        _isLiked = widget.post.isLiked;
        _likeCount = widget.post.likeCount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = Supabase.instance.client.auth.currentUser;

    return Row(
      children: [
        // ❤️ Like button
        Focus(
          child: IconButton(
            onPressed: _isLiking
                ? null // Disable button while liking
                : () async {
                    if (user == null) {
                      FailureSnackBar.show(
                        context: context,
                        message: 'Log in to like!',
                        isDark: isDark,
                        onPressed: () => Navigator.push(
                          context,
                          SlideRouting(page: const LoginPage()),
                        ),
                        btnLabel: 'Log in',
                      );
                      return;
                    }

                    setState(() {
                      _isLiking = true;
                      // Optimistic UI update
                      _isLiked = !_isLiked;
                      _likeCount += _isLiked ? 1 : -1;
                    });

                    try {
                      // Access the notifier directly via ref and perform the action.
                      final result = await ref
                          .read(feedProvider(null).notifier)
                          .toggleLike(widget.post.id);

                      // Confirm the UI with the actual data from the database.
                      if (mounted) {
                        setState(() {
                          _isLiked = result['isLiked'];
                          _likeCount = result['likeCount'];
                        });
                      }
                    } catch (e) {
                      // If something goes wrong, revert the optimistic update.
                      if (mounted) {
                        setState(() {
                          _isLiked = !_isLiked;
                          _likeCount += _isLiked ? 1 : -1;
                        });

                        FailureSnackBar.show(
                          context: context,
                          isDark: isDark,
                          message: 'failed to like post. Please try again',
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() {
                          _isLiking = false; // Re-enable the button
                        });
                      }
                    }
                  },
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                _isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                key: ValueKey(_isLiked),
                size: 24,
                color: isDark
                    ? _isLiked
                          ? Colors.red
                          : Colors.white
                    : _isLiked
                    ? Colors.red
                    : Colors.black,
              ),
            ),
            splashRadius: 20,
          ),
        ),

        // ❤️ Like count
        Text(
          _likeCount.toString(), // Use local state
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: isDark ? Colors.grey : Colors.grey[900],
          ),
        ),

        const SizedBox(width: 8),

        // 🔗 Share
        IconButton(
          onPressed: () {
            // TODO: Implement share functionality, e.g., using the share_plus package
            debugPrint('Share Post action for post ID: ${widget.post.id}');
          },
          icon: Icon(
            Icons.share_outlined,
            size: 20,
            color: isDark ? Colors.white : Colors.black,
          ),
          splashRadius: 20,
        ),
      ],
    );
  }
}
