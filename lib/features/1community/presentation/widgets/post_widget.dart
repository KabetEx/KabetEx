import 'package:flutter/material.dart';
import 'package:kabetex/features/1community/data/models/post.dart';
import 'package:intl/intl.dart';

class PostWidget extends StatelessWidget {
  final Post post;

  const PostWidget({super.key, required this.post});

  String _timeAgo(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return DateFormat('MMM d').format(createdAt); // fallback, e.g., Jan 5
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Image placeholder
          const CircleAvatar(radius: 22, backgroundColor: Colors.grey),
          const SizedBox(width: 12),

          // Main Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username + timestamp + 3-dot
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
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        // open report / more options menu
                      },
                      icon: Icon(
                        Icons.more_horiz,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      splashRadius: 20,
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Post content
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

                // Action row
                Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.favorite_border,
                        size: 20,
                        color: Colors.deepOrange,
                      ),
                      splashRadius: 20,
                    ),
                    const SizedBox(width: 16),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
