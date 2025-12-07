import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kabetex/common/slide_routing.dart';
import 'package:kabetex/core/snackbars.dart';
import 'package:kabetex/features/1community/data/models/user.dart';
import 'package:kabetex/features/1community/presentation/pages/new_post_page.dart';
import 'package:kabetex/features/1community/presentation/widgets/post_widget.dart';
import 'package:kabetex/features/1community/providers/feed_provider.dart';
import 'package:kabetex/features/1community/providers/user_provider.dart';
import 'package:kabetex/providers/theme_provider.dart';

class CommunityProfilePage extends ConsumerStatefulWidget {
  final String? userID;

  const CommunityProfilePage({super.key, required this.userID});

  @override
  ConsumerState<CommunityProfilePage> createState() =>
      _CommunityProfilePageState();
}

class _CommunityProfilePageState extends ConsumerState<CommunityProfilePage> {
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
      feedProvider(widget.userID),
    ); //pass in the ID to filter posts
    final feedNotifier = ref.read(feedProvider(widget.userID).notifier);

    return userAsync.when(
      data: (userProfile) {
        if (userProfile == null) {
          return const Scaffold(body: Center(child: Text('Not logged in!')));
        }

        final bool isOwner = userProfile.id == currentUserId;

        return Scaffold(
          body: RefreshIndicator(
            onRefresh: () async {
              ref.refresh(feedProvider(widget.userID));
              ref.refresh(currentUserIdProvider);
              await Future.delayed(const Duration(milliseconds: 300));

              SuccessSnackBar.show(
                context: context,
                message:
                    ' filtering posts for ${widget.userID} logged in as : $currentUserId',
                isDark: isDark,
              );
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // AppBar
                SliverAppBar(
                  pinned: false,
                  floating: true,
                  snap: true,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  title: Text(
                    "Profile",
                    style: Theme.of(context).textTheme.titleMedium,
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
                else if (feedState.posts.isEmpty)
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
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final post = feedState.posts[index];
                      return PostWidget(post: post, feedNotifier: feedNotifier);
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
  final UserProfile user;
  final bool isOwner;
  final bool isDark;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.isOwner,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AvatarWidget(user: user),
            const Spacer(),
            if (isOwner) EditProfileButton(isDark: isDark),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          user.name,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontFamily: 'Lato',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        YearNJoinedDateColumn(user: user, isDark: isDark),
        const SizedBox(height: 32),
        Divider(
          color: isDark ? Colors.grey[800] : Colors.grey[700],
          thickness: 0.7,
        ),
        const SizedBox(height: 24),
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

// ================= Avatar Widget =================
class AvatarWidget extends StatelessWidget {
  final UserProfile user;

  const AvatarWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: CachedNetworkImageProvider('https://i.pravatar.cc/150?img=3'),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(2, 4)),
        ],
      ),
    );
  }
}

// ================= Edit Profile Button =================
class EditProfileButton extends StatelessWidget {
  final bool isDark;

  const EditProfileButton({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark ? Colors.white10 : Colors.black12,
        foregroundColor: isDark ? Colors.white : Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 2,
      ),
      onPressed: () {
        // Navigate to edit profile
      },
      child: Text(
        'Edit Profile',
        style: Theme.of(context).textTheme.labelSmall!.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}

// ================= Year + Joined =================
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
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.book,
              color: isDark ? Colors.grey : Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              user.year,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: isDark ? Colors.grey : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.calendar,
              color: isDark ? Colors.grey : Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              'Joined: ${DateFormat('MMM d yyyy').format(user.createdAt!)}',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: isDark ? Colors.grey : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w100,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
