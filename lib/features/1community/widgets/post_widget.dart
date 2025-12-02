import 'package:flutter/material.dart';

class PostWidget extends StatelessWidget {
  final String username;
  final String timeAgo;
  final String content;
  final String profileUrl;

  const PostWidget({
    super.key,
    required this.username,
    required this.timeAgo,
    required this.content,
    required this.profileUrl,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Image
          CircleAvatar(radius: 22, backgroundImage: NetworkImage(profileUrl)),
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
                          username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          timeAgo,
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
                  content,
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
