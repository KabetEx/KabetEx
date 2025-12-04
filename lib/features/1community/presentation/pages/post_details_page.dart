import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/common/slide_routing.dart';
import 'package:kabetex/core/snackbars.dart';
import 'package:kabetex/features/1community/data/models/post.dart';
import 'package:kabetex/features/1community/providers/feed_provider.dart';
import 'package:kabetex/features/auth/presentation/login.dart';
import 'package:kabetex/providers/theme_provider.dart';
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
            /// USER
            Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/150?img=12',
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  widget.post.userFullname ?? "",
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// CONTENT
            Text(
              widget.post.content,
              style: TextStyle(
                fontSize: 18,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),

            const SizedBox(height: 20),

            /// ACTIONS
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    postLiked ? Icons.favorite : Icons.favorite_border,
                    size: 28,
                    color: Colors.deepOrange,
                  ),
                  onPressed: () async {
                    final user = Supabase.instance.client.auth.currentUser;
                    if (user == null) {
                      FailureSnackBar.show(
                        context: context,
                        message: 'Log in to like! ',
                        isDark: isDark,
                        onPressed: () => Navigator.push(
                          context,
                          SlideRouting(page: const LoginPage()),
                        ),
                        btnLabel: 'Log in',
                      );
                    }
                    setState(() {
                      postLiked = !postLiked;
                      likeCount += postLiked ? 1 : -1;
                    });

                    final result = await ref
                        .read(feedProvider.notifier)
                        .toggleLike(widget.post.id);

                    setState(() {
                      postLiked = result['isLiked'];
                      likeCount = result['likeCount'];
                    });
                  },
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
                    Icons.mode_comment_outlined,
                    size: 26,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  onPressed: () => _openCommentSheet(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
