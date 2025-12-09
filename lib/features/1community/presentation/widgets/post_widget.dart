import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/common/slide_routing.dart';
import 'package:kabetex/core/snackbars.dart';
import 'package:kabetex/features/1community/data/models/post.dart';
import 'package:intl/intl.dart';
import 'package:kabetex/features/1community/presentation/pages/post_details_page.dart';
import 'package:kabetex/features/1community/presentation/pages/profile_page.dart';
import 'package:kabetex/features/1community/providers/feed_provider.dart';
import 'package:kabetex/features/1community/providers/user_provider.dart';
import 'package:kabetex/features/auth/presentation/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostWidget extends ConsumerWidget {
  final Post post;
  final FeedNotifier feedNotifier; //for liking

  const PostWidget({super.key, required this.post, required this.feedNotifier});

  String _timeAgo(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) return '${difference.inSeconds}s';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m';
    if (difference.inHours < 24) return '${difference.inHours}h';
    if (difference.inDays < 7) return '${difference.inDays}d';
    return DateFormat('MMM d').format(createdAt);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loggedInUser = ref.watch(currentUserIdProvider);

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
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  SlideRouting(page: CommunityProfilePage(userID: post.userId)),
                );
              },
              child: CircleAvatar(
                radius: 22,
                backgroundColor: isDark ? Colors.grey[300] : Colors.grey[700],
                backgroundImage: post.avatarUrl!.isNotEmpty
                    ? CachedNetworkImageProvider(post.avatarUrl!)
                    : null, // fallback if empty
                child: post.avatarUrl!.isEmpty
                    ? Icon(
                        CupertinoIcons.person,
                        color: isDark ? Colors.grey[800] : Colors.white,
                      )
                    : null,
              ),
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
                            _timeAgo(post.createdAt!),
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
                            debugPrint('Report clicked');
                          }
                        },
                        itemBuilder: (context) {
                          final isOwner = post.userId == loggedInUser;
                          if (isOwner) {
                            return [
                              const PopupMenuItem(
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
                  PostWidgetActionsRow(
                    post: post,
                    isDark: isDark,
                    feedNotifier: feedNotifier,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PostWidgetActionsRow extends ConsumerWidget {
  final Post post;
  final bool isDark;
  final FeedNotifier feedNotifier;

  const PostWidgetActionsRow({
    super.key,
    required this.post,
    required this.isDark,
    required this.feedNotifier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // ❤️ Like button
        IconButton(
          onPressed: () async {
            final user = Supabase.instance.client.auth.currentUser;
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

            feedNotifier.toggleLike(post.id);
            print('Liked');
          },
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Icon(
              key: ValueKey(post.isLiked),
              post.isLiked ? Icons.favorite : Icons.favorite_border,
              size: 20,
              color: isDark
                  ? post.isLiked
                        ? Colors.deepOrange
                        : Colors.white
                  : post.isLiked
                  ? Colors.deepOrange
                  : Colors.black,
            ),
          ),
          splashRadius: 20,
        ),

        // ❤️ Like count
        Text(
          post.likeCount.toString(),
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: isDark ? Colors.grey : Colors.grey[900],
          ),
        ),

        const SizedBox(width: 8),

        // 🔗 Share
        IconButton(
          onPressed: () {},
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
