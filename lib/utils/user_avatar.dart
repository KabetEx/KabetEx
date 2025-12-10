import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/1community/data/models/user.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.userAsync, this.radius = 24.0});

  final AsyncValue<UserProfile?> userAsync;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return userAsync.when(
      data: (user) {
        if (user == null || user.avatarUrl.isEmpty) {
          // Guest or user with no avatar
          return CircleAvatar(
            radius: radius,
            backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
            child: Icon(
              CupertinoIcons.person_fill,
              size: radius,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          );
        }
        // Logged-in user with avatar
        return CircleAvatar(
          radius: radius,
          backgroundColor: Colors.deepOrange,
          backgroundImage: CachedNetworkImageProvider(user.avatarUrl),
        );
      },
      loading: () => CircleAvatar(
        radius: radius,
        backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
      ),
      error: (_, __) => CircleAvatar(
        radius: radius,
        backgroundColor: isDark ? Colors.red[900] : Colors.red[100],
        child: Icon(
          CupertinoIcons.exclamationmark_triangle_fill,
          size: radius,
          color: isDark ? Colors.red[100] : Colors.red[700],
        ),
      ),
    );
  }
}
