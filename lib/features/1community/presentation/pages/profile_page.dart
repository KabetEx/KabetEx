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

    final feedState = ref.watch(feedProvider(userProfile.id));
    final posts = feedState.posts;
    final feedNotifier = ref.read(feedProvider(userProfile.id).notifier);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(feedProvider(userProfile.id));
          // optional delay
          await Future.delayed(const Duration(milliseconds: 300));
          SuccessSnackBar.show(
            context: context,
            message: 'Posts refreshed',
            isDark: isDark,
          );
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: false,
              floating: true,
              snap: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Text(
                "Profile",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              actions: [
                PopupMenuButton(
                  itemBuilder: (_) => [const PopupMenuItem(child: Text(''))],
                ),
              ],
              elevation: 0.5,
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar + edit button row
                    Row(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: const DecorationImage(
                              image: CachedNetworkImageProvider(
                                'https://i.pravatar.cc/150?img=3',
                              ),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark ? Colors.white24 : Colors.black26,
                                blurRadius: 6,
                                offset: const Offset(2, 4),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? Colors.white10
                                : Colors.black12,
                            foregroundColor: isDark
                                ? Colors.white
                                : Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                              side: BorderSide(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            elevation: 2,
                          ),
                          onPressed: () {
                            // navigate to edit profile
                          },
                          child: Text(
                            'Edit Profile',
                            style: Theme.of(context).textTheme.labelSmall!
                                .copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Name
                    Text(
                      userProfile.name,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontFamily: 'Lato',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Year + joined date
                    YearNJoinedDateColumn(isDark: isDark, user: userProfile),

                    const SizedBox(height: 32),

                    Divider(
                      color: isDark ? Colors.grey[800] : Colors.grey[700],
                      thickness: 0.7,
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'My Posts',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: isDark ? Colors.white : Colors.black,
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            if (feedState.isLoading) ...[
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
            ] else if (feedState.error != null) ...[
              SliverFillRemaining(
                child: Center(child: Text('Error: ${feedState.error}')),
              ),
            ] else if (posts.isEmpty) ...[
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
              ),
            ] else ...[
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final post = posts[index];
                  return PostWidget(post: post, feedNotifier: feedNotifier);
                }, childCount: posts.length),
              ),
              // optional padding at end
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ],
        ),
      ),
    );
  }
}

class YearNJoinedDateColumn extends StatelessWidget {
  const YearNJoinedDateColumn({
    super.key,
    required this.isDark,
    required this.user,
  });

  final UserProfile user;
  final bool isDark;
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

        //joined date
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
