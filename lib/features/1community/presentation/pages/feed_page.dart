import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/common/slide_routing.dart';
import 'package:kabetex/features/1community/data/models/user.dart';
import 'package:kabetex/features/1community/presentation/pages/post_shimmer.dart';
import 'package:kabetex/features/1community/presentation/widgets/sliver_status_indicator.dart';
import 'package:kabetex/features/1community/presentation/widgets/drawer.dart';
import 'package:kabetex/features/1community/presentation/widgets/post_widget.dart';
import 'package:kabetex/features/1community/providers/feed_provider.dart';
import 'package:kabetex/features/1community/providers/tabs_provider.dart';
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
  double _lastOffset = 0;

  @override
  void initState() {
    super.initState();

    //--------------------SCROLL PAGINATION-------------------------------------
    //-------------------- ------------------------------------------------------
    _scrollController.addListener(() {
      final position = _scrollController.position;

      // When user hits 85% of the bottom -> load more
      if (position.pixels >= position.maxScrollExtent * 0.85) {
        ref.read(feedProvider(null).notifier).loadMore();
      }
    });

    _scrollController.addListener(() {
      final offset = _scrollController.offset;
      const sensitivity = 8;

      if (offset > _lastOffset + sensitivity) {
        // scrolling down → hide
        ref.read(bottomBarVisibleProvider.notifier).state = false;
      } else if (offset < _lastOffset - sensitivity) {
        // scrolling up → show
        ref.read(bottomBarVisibleProvider.notifier).state = true;
      }

      _lastOffset = offset;
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
              isDark: isDark,
              userAsync: userAsync,
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

class MySliverAppBar extends ConsumerWidget {
  const MySliverAppBar({
    super.key,
    required this.scaffoldKey,
    required this.userAsync,
    required this.isDark,
  });
  final AsyncValue<UserProfile?> userAsync;
  final bool isDark;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context, ref) {
    return SliverAppBar(
      pinned: false,
      floating: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 4,
      toolbarHeight: 64,
      leadingWidth: 64,
      actionsPadding: const EdgeInsets.symmetric(horizontal: 12),
      leading: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: GestureDetector(
          onTap: () => scaffoldKey.currentState?.openDrawer(),
          // Use the new reusable UserAvatar widget.
          // The padding is now part of the AppBar's leadingWidth and internal padding.
          child: Consumer(
            builder: (context, ref, child) {
              return UserAvatar(userAsync: userAsync, radius: 18);
            },
          ),
        ),
      ),
      centerTitle: true,
      title: Text(
        "KabetEx",
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 24,
          letterSpacing: 1.2,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, size: 40),
          color: isDark ? Colors.white : Colors.grey[1000],
          onPressed: () =>
              Navigator.push(context, SlideRouting(page: const SettingsPage())),
        ),
      ],
    );
  }
}
