import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/common/slide_routing.dart';
import 'package:kabetex/features/1community/data/models/user.dart';
import 'package:kabetex/features/1community/presentation/pages/new_post_page.dart';
import 'package:kabetex/features/1community/presentation/pages/post_shimmer.dart';
import 'package:kabetex/features/1community/presentation/widgets/sliver_status_indicator.dart';
import 'package:kabetex/features/1community/presentation/widgets/drawer.dart';
import 'package:kabetex/features/1community/presentation/widgets/post_widget.dart';
import 'package:kabetex/features/1community/providers/feed_provider.dart';
import 'package:kabetex/features/auth/providers/user_provider.dart';
import 'package:kabetex/features/settings/presentations/settings_page.dart';
import 'package:kabetex/providers/theme_provider.dart';
import 'package:kabetex/utils/user_avatar.dart';

class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({super.key});

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  String _selectedAudience = 'Everyone';

  @override
  void initState() {
    super.initState();

    //--------------------SCROLL PAGINATION-------------------------------------
    //--------------------------------------------------------------------------
    _scrollController.addListener(() {
      final position = _scrollController.position;

      // When user hits 85% of the bottom -> load more
      if (position.pixels >= position.maxScrollExtent * 0.85) {
        ref.read(feedProvider(null).notifier).loadMore();
      }
    });
  }

  Future<void> onRefresh() async {
    final userID = ref.read(currentUserIdProvider);
    // ref.refresh returns a Future, so we can await them.
    await Future.wait([
      ref.refresh(userByIDProvider(userID).future),
      ref.refresh(feedProvider(null).notifier).fetchPosts(),
    ]);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);
    final userID = ref.watch(currentUserIdProvider);
    final userAsync = ref.watch(userByIDProvider(userID));
    final feedState = ref.watch(feedProvider(null)); //dont filter
    final posts = feedState.posts;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const MyCommunityDrawer(),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            MySliverAppBar(
              scaffoldKey: _scaffoldKey,
              scrollController: _scrollController,
              isDark: isDark,
              selectedAudience: _selectedAudience,
              onAudienceChanged: (value) {
                setState(() {
                  _selectedAudience = value;
                });
              },
              userAsync: userAsync,
            ),

            //NEWPOST CARD
            SliverToBoxAdapter(
              child: NewPostCard(userAsync: userAsync, isdark: isDark),
            ),

            // ✅ Conditional Sliver content
            if (feedState.isLoading)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => const PostWidgetShimmer(),
                  childCount: 4,
                ),
              )
            else if (feedState.error != null && posts.isEmpty)
              SliverStatusIndicator.error(
                message: 'Could not load feed',
                onRetry: onRefresh,
              )
            else if (posts.isEmpty)
              const SliverStatusIndicator.empty(message: 'No posts yet 😢')
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == posts.length) {
                        return const PostWidgetShimmer();
                      }

                      final post = posts[index];

                      return TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeIn,
                        builder: (context, opacity, child) {
                          return Opacity(opacity: opacity, child: child);
                        },
                        child: PostWidget(post: post, key: ValueKey(post.id)),
                      );
                    },
                    childCount:
                        feedState.posts.length + (feedState.hasMore ? 1 : 0),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class NewPostCard extends ConsumerWidget {
  const NewPostCard({super.key, required this.userAsync, required this.isdark});

  final AsyncValue<UserProfile?> userAsync; //check if user is logged in

  final bool isdark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return userAsync.when(
      data: (user) {
        if (user == null) return const SizedBox.shrink();

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isdark
                  ? Colors.grey[900]
                  : Theme.of(context).scaffoldBackgroundColor,
              border: Border.all(
                color: isdark ? Colors.grey[800]! : Colors.black12,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isdark ? Colors.grey.withAlpha(30) : Colors.black12,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                // Slide up to CreatePostPage
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const PostTweetPage(),
                    transitionDuration: const Duration(milliseconds: 200),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          const begin = Offset(0, 1); //from down to up
                          const end = Offset(0, 0); // original position

                          final tween = Tween(
                            begin: begin,
                            end: end,
                          ).chain(CurveTween(curve: Curves.bounceInOut));

                          return SlideTransition(
                            position: tween.animate(animation),
                            child: child,
                          );
                        },
                  ),
                );
              },
              splashColor: isdark ? Colors.grey : Colors.grey[300],
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: isdark
                        ? Colors.grey[700]
                        : Colors.grey[300],
                    child: Icon(
                      CupertinoIcons.add_circled,
                      size: 24,
                      color: isdark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "What's on your mind?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isdark ? Colors.grey[600] : Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox(
        height: 60,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class MySliverAppBar extends ConsumerStatefulWidget {
  const MySliverAppBar({
    super.key,
    required this.scaffoldKey,
    required this.userAsync,
    required this.isDark,
    required this.selectedAudience,
    required this.onAudienceChanged,
    required this.scrollController,
  });
  final AsyncValue<UserProfile?> userAsync;
  final ValueChanged<String> onAudienceChanged;
  final String selectedAudience;
  final ScrollController scrollController;
  final bool isDark;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  ConsumerState<MySliverAppBar> createState() => _MySliverAppBarState();
}

class _MySliverAppBarState extends ConsumerState<MySliverAppBar> {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: false,
      floating: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 4,
      toolbarHeight: 70,
      leadingWidth: 76,
      actionsPadding: const EdgeInsets.symmetric(horizontal: 12),
      leading: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
        child: GestureDetector(
          onTap: () => widget.scaffoldKey.currentState?.openDrawer(),
          // Use the new reusable UserAvatar widget.
          // The padding is now part of the AppBar's leadingWidth and internal padding.
          child: UserAvatar(userAsync: widget.userAsync, radius: 18),
        ),
      ),
      centerTitle: true,
      title: GestureDetector(
        onTap: () {
          //slide to top
          widget.scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInBack,
          );
        },
        child: Text(
          "KabetEx",
          style: TextStyle(
            color: widget.isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, size: 42),
          color: widget.isDark ? Colors.white : Colors.grey[1000],
          onPressed: () =>
              Navigator.push(context, SlideRouting(page: const SettingsPage())),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['Everyone', 'Friends', 'Classmates'].map((audience) {
              final isSelected = widget.selectedAudience == audience;
              final isDark = ref.watch(isDarkModeProvider);

              return AnimatedScale(
                scale: isSelected ? 1.05 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: GestureDetector(
                  onTap: () => widget.onAudienceChanged(audience),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? isSelected
                                ? Colors.deepOrange
                                : Colors.grey[900]
                          : isSelected
                          ? Colors.deepOrange
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      audience,
                      style: TextStyle(
                        color: isDark
                            ? isSelected
                                  ? Colors.white
                                  : Colors.white
                            : isSelected
                            ? Colors.white
                            : Colors.black,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
