import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/common/slide_routing.dart';
import 'package:kabetex/features/1community/data/models/user.dart';
import 'package:kabetex/features/1community/providers/user_provider.dart';
import 'package:kabetex/utils/snackbars.dart';
import 'package:kabetex/features/1community/data/models/post.dart';
import 'package:kabetex/features/1community/presentation/pages/profile_page.dart';
import 'package:kabetex/features/1community/providers/feed_provider.dart';
import 'package:kabetex/features/auth/presentation/login.dart';
import 'package:kabetex/providers/theme_provider.dart';
import 'package:kabetex/utils/user_avatar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostDetailPage extends ConsumerStatefulWidget {
  final Post post;

  const PostDetailPage({super.key, required this.post});

  @override
  ConsumerState<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends ConsumerState<PostDetailPage> {
  late bool postLiked;
  late int likeCount;
  final user = Supabase.instance.client.auth.currentUser;

  @override
  void initState() {
    super.initState();
    postLiked = widget.post.isLiked;
    likeCount = widget.post.likeCount;
  }

  void _openCommentSheet(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final controller = TextEditingController();

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(25),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black54 : Colors.grey.withAlpha(80),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  maxLines: 5,
                  autocorrect: true,
                  autofocus: true,
                  enableSuggestions: true,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: "Write a comment...",
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.grey[900] : Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    if (controller.text.trim().isEmpty) return;

                    SuccessSnackBar.show(
                      context: context,
                      message: "Comment sent!",
                      isDark: isDark,
                    );
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Colors.deepOrange, Colors.orangeAccent],
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        "Post Comment",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);
    final userProfileAsync = ref.watch(userByIDProvider(widget.post.userId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Post',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        centerTitle: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 3,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.black, width: 0.3),
        ),
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// USER details row
            const SizedBox(height: 16),

            UserDetailsRow(
              post: widget.post,
              userProfileAsync: userProfileAsync,
              isDark: isDark,
            ),

            const SizedBox(height: 16),

            /// CONTENT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                widget.post.content,
                style: TextStyle(
                  fontSize: 18,
                  color: isDark ? Colors.white.withAlpha(220) : Colors.black87,
                  fontFamily: 'Lato',
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// ACTIONS
            ActionsRow(
              postLiked: postLiked,
              likeCount: likeCount,
              postId: widget.post.id,
              onClickComment: _openCommentSheet,
            ),

            Divider(color: isDark ? Colors.grey[700] : Colors.black45),
          ],
        ),
      ),
    );
  }
}

class UserDetailsRow extends StatelessWidget {
  const UserDetailsRow({
    super.key,
    required this.userProfileAsync,
    required this.post,
    required this.isDark,
  });

  final AsyncValue<UserProfile?> userProfileAsync;
  final Post post;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              SlideRouting(page: CommunityProfilePage(userID: post.userId)),
            );
          },
          child: UserAvatar(userAsync: userProfileAsync),
        ),
        const SizedBox(width: 16),

        Text(
          post.userFullname ?? "",
          style: TextStyle(
            fontFamily: 'Lato',
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 22,
            height: 1.5,
            fontWeight: FontWeight.w400,
          ),
        ),

        const Spacer(),

        PopupMenuButton(
          itemBuilder: (context) {
            return [const PopupMenuItem(child: Text('Report'))];
          },
        ),
      ],
    );
  }
}

class ActionsRow extends ConsumerStatefulWidget {
  final bool postLiked;
  final int likeCount;
  final String postId;
  final void Function(BuildContext context) onClickComment;

  const ActionsRow({
    super.key,
    required this.postLiked,
    required this.likeCount,
    required this.postId,
    required this.onClickComment,
  });

  @override
  ConsumerState<ActionsRow> createState() => _ActionsRowState();
}

class _ActionsRowState extends ConsumerState<ActionsRow> {
  late bool postLiked;
  late int likeCount;
  bool isLiking = false;

  @override
  void initState() {
    super.initState();
    postLiked = widget.postLiked;
    likeCount = widget.likeCount;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);
    final user = Supabase.instance.client.auth.currentUser;

    return Row(
      children: [
        IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Icon(
              postLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
              key: ValueKey(postLiked),
              size: 28,
              color: isDark
                  ? postLiked
                        ? Colors.red
                        : Colors.white
                  : postLiked
                  ? Colors.red
                  : Colors.black,
            ),
          ),
          onPressed: !isLiking
              ? () async {
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

                  if (isLiking) return;

                  setState(() {
                    postLiked = !postLiked;
                    likeCount += postLiked ? 1 : -1;
                    isLiking = true;
                  });

                  try {
                    final result = await ref
                        .read(feedProvider(null).notifier)
                        .toggleLike(widget.postId);

                    setState(() {
                      postLiked = result['isLiked'];
                      likeCount = result['likeCount'];
                      isLiking = false;
                    });
                  } catch (e) {
                    setState(() {
                      postLiked = !postLiked;
                      likeCount += postLiked ? 1 : -1;
                    });
                    FailureSnackBar.show(
                      context: context,
                      message: 'failed to like post. Please try again',
                      isDark: isDark,
                    );
                  } finally {
                    isLiking = false; // unlock
                  }
                }
              : null,
        ),
        Text(
          likeCount.toString(),
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: isDark ? Colors.grey : Colors.grey[900],
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          icon: Icon(
            CupertinoIcons.text_bubble,
            size: 26,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () {
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
            widget.onClickComment(context);
          },
        ),
      ],
    );
  }
}
