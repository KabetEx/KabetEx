import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/1community/data/models/user.dart';
import 'package:kabetex/providers/theme_provider.dart';

class CommunityProfilePage extends ConsumerStatefulWidget {
  const CommunityProfilePage({super.key, required this.userProfile});

  final UserProfile userProfile;
  @override
  ConsumerState<CommunityProfilePage> createState() =>
      _CommunityProfilePageState();
}

class _CommunityProfilePageState extends ConsumerState<CommunityProfilePage> {
  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);
    final userProfile = widget.userProfile;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 32,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16,
              ),
              child: Divider(
                thickness: 0.7,
                color: isDark ? Colors.grey[800] : Colors.grey[700],
                height: 0,
              ),
            ),

            Text(
              userProfile.name,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontFamily: 'Lato',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
