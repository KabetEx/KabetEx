import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kabetex/common/slide_routing.dart';
import 'package:kabetex/utils/snackbars.dart';
import 'package:kabetex/features/1community/data/models/user.dart';
import 'package:kabetex/features/1community/presentation/pages/edit_profile_page.dart';
import 'package:kabetex/features/1community/presentation/pages/new_post_page.dart';
import 'package:kabetex/features/1community/presentation/widgets/post_widget.dart';
import 'package:kabetex/features/1community/providers/feed_provider.dart';
import 'package:kabetex/features/auth/providers/user_provider.dart';
import 'package:kabetex/providers/theme_provider.dart';
import 'package:kabetex/utils/user_avatar.dart';

class CommunityProfilePage extends ConsumerStatefulWidget {
  final String? userID;

  const CommunityProfilePage({super.key, required this.userID});

  @override
  ConsumerState<CommunityProfilePage> createState() =>
      _CommunityProfilePageState();
}

class _CommunityProfilePageState extends ConsumerState<CommunityProfilePage> {
  late final feedProviderWithID = feedProvider({'profileUID': widget.userID});
  bool isRefreshing = false;

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);
    final currentUserId = ref.watch(
      currentUserIdProvider,
    ); //logged in user ID now

    final userAsync = ref.watch(
      userByIDProvider(widget.userID),
    ); //fetching the profile

    final feedState = ref.watch(
      feedProviderWithID,
    ); //pass in the ID to filter posts

    return userAsync.when(
      data: (userProfile) {
        if (userProfile == null) {
          return const Scaffold(body: Center(child: Text('Not logged in!')));
        }

        final bool isOwner = userProfile.id == currentUserId;

        return Scaffold(
          body: RefreshIndicator(
            onRefresh: () async {
              if (isRefreshing) return;

              isRefreshing = true;
              ref.invalidate(
                userByIDProvider(widget.userID),
              ); //refresh userprofile
              ref.refresh(feedProvider({'profileUID': widget.userID})); //refresh user posts
              await Future.delayed(const Duration(milliseconds: 300));

              SuccessSnackBar.show(
                context: context,
                message: 'refreshing...',
                isDark: isDark,
              );
              isRefreshing = false;
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // AppBar
                SliverAppBar(
                  pinned: true,
                  floating: true,
                  snap: true,
                  centerTitle: false,
                  backgroundColor: Colors.transparent,
                  title: Text(
                    isOwner ? "My Profile" : userProfile.name,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                    ),
                  ),
                  elevation: 0.5,
                  actions: [
                    PopupMenuButton(
                      itemBuilder: (_) => [
                        const PopupMenuItem(child: Text('')),
                      ],
                    ),
                  ],
                ),

                // Profile header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16,
                    ),
                    child: ProfileHeader(
                      user: userProfile,
                      userAsync: userAsync,
                      isOwner: isOwner,
                      isDark: isDark,
                    ),
                  ),
                ),

                // Feed section
                if (feedState.isLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (feedState.error != null)
                  SliverFillRemaining(
                    child: Center(child: Text('Error: ${feedState.error}')),
                  )
                else if (feedState.posts.isEmpty && isOwner)
                  SliverFillRemaining(
                    child: Center(
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            SlideRouting(page: const PostTweetPage()),
                          );
                        },
                        icon: const Icon(Icons.create),
                        label: const Text('Create your first Post!'),
                      ),
                    ),
                  )
                else if (feedState.posts.isEmpty && !isOwner)
                  const SliverFillRemaining(
                    child: Center(child: Text('No posts yet')),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final post = feedState.posts[index];
                      return PostWidget(post: post);
                    }, childCount: feedState.posts.length),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}

// ================= Profile Header =================
class ProfileHeader extends StatelessWidget {
  final AsyncValue<UserProfile?> userAsync;
  final UserProfile user;
  final bool isOwner;
  final bool isDark;

  const ProfileHeader({
    super.key,
    required this.userAsync,
    required this.isOwner,
    required this.isDark,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AvatarWidget(userAsync: userAsync, isDark: isDark),
            const Spacer(),
            Column(
              children: [
                if (isOwner) EditProfileButton(isDark: isDark, user: user),

                if (!isOwner) ...[
                  const ProfileMetrics(posts: 2, followers: 103, following: 23),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      padding: const EdgeInsets.symmetric(horizontal: 64),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {},
                    child: Text(
                      'Follow',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          user.name,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontFamily: 'Lato',
            fontSize: 20,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 8),

        YearNJoinedDateColumn(user: user, isDark: isDark),
        const SizedBox(height: 8),

        if (isOwner) ...[
          const ProfileMetrics(posts: 3, followers: 12, following: 3),
          const SizedBox(height: 16),
        ],

        Divider(
          color: isDark ? Colors.grey[800] : Colors.grey[700],
          thickness: 0.7,
        ),
        const SizedBox(height: 16),

        Text(
          isOwner ? 'My Posts' : 'Posts',
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: isDark ? Colors.white : Colors.black,
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class ProfileMetrics extends StatelessWidget {
  final int posts;
  final int followers;
  final int following;

  const ProfileMetrics({
    super.key,
    required this.posts,
    required this.followers,
    required this.following,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget item(String count, String label, VoidCallback onTap) {
      return GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          item(posts.toString(), "Posts", () {}),
          const SizedBox(width: 8),
          item(followers.toString(), "Followers", () {}),
          const SizedBox(width: 8),
          item(following.toString(), "Following", () {}),
        ],
      ),
    );
  }
}

// ================= Avatar Widget =================
class AvatarWidget extends StatelessWidget {
  final AsyncValue<UserProfile?> userAsync;
  final bool isDark;

  const AvatarWidget({
    super.key,
    required this.userAsync,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return UserAvatar(userAsync: userAsync, radius: 40);
  }
}

// ================= Edit Profile Button =================

class EditProfileButton extends ConsumerWidget {
  final bool isDark;
  final UserProfile user;

  const EditProfileButton({
    super.key,
    required this.isDark,
    required this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(editProfileProvider).isLoading;

    return ElevatedButton(
      onPressed: isLoading
          ? null
          : () {
              Navigator.push(
                context,
                SlideRouting(page: CommunityEditProfilePage(user: user)),
              );
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark ? Colors.white12 : Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 3,
        shadowColor: Colors.black26,
      ),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: isDark ? Colors.white : Colors.white,
              ),
            )
          : Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.white,
              ),
            ),
    );
  }
}

// ================= Year + Joined + Bio =================
class YearNJoinedDateColumn extends StatelessWidget {
  final UserProfile user;
  final bool isDark;

  const YearNJoinedDateColumn({
    super.key,
    required this.user,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Year row
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.book,
              color: isDark ? Colors.grey : Colors.grey[900],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              user.year,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: isDark ? Colors.grey : Colors.grey[900],
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // Joined row
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.calendar,
              color: isDark ? Colors.grey : Colors.grey[900],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Joined: ${DateFormat('MMM d yyyy').format(user.createdAt ?? DateTime.now())}',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: isDark ? Colors.grey : Colors.grey[900],
                fontSize: 16,
                fontWeight: FontWeight.w100,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Modern Bio card
        if (user.bio.isNotEmpty)
          Text(
            user.bio,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.grey[300] : Colors.grey[800],
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
      ],
    );
  }
}
