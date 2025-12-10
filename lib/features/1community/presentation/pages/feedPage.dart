import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/common/slide_routing.dart';
import 'package:kabetex/features/1community/data/models/user.dart';
import 'package:kabetex/features/1community/presentation/pages/post_shimmer.dart';
import 'package:kabetex/features/1community/presentation/widgets/post_widget.dart';
import 'package:kabetex/features/1community/presentation/widgets/drawer.dart';
import 'package:kabetex/features/1community/providers/feed_provider.dart';
import 'package:kabetex/features/1community/providers/tabs_provider.dart';
import 'package:kabetex/features/1community/providers/user_provider.dart';
import 'package:kabetex/features/settings/presentations/settings_page.dart';
import 'package:kabetex/providers/theme_provider.dart';

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

    // Refresh user profile when FeedPage opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userID = ref.read(currentUserIdProvider);
      ref.invalidate(currentUserIdProvider); //supabase user ID
      ref.invalidate(userByIDProvider); // mark for refresh
      ref.read(userByIDProvider(userID).future); // optionally await new data
    });
  }

  Future<void> onRefresh() async {
    final userID = ref.read(currentUserIdProvider);

    ref.invalidate(userByIDProvider);
    ref.read(userByIDProvider(userID).future);

    ref
        .read(feedProvider(null).notifier)
        .fetchPosts(); //wait until posts are refetched
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
                ),
              )
            else if (feedState.error != null)
              SliverFillRemaining(
                child: Center(child: Text('Error: ${feedState.error}')),
              )
            else if (posts.isEmpty)
              const SliverFillRemaining(
                child: Center(child: Text('No posts yet 😢')),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final post = posts[index];
                  final feedNotifier = ref.read(feedProvider(null).notifier);

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: PostWidget(post: post, feedNotifier: feedNotifier),
                  );
                }, childCount: posts.length),
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
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 4,
      toolbarHeight: 64,
      leadingWidth: 36,
      leading: GestureDetector(
        onTap: () => scaffoldKey.currentState?.openDrawer(),
        child: userAsync.when(
          data: (user) {
            if (user == null) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Icon(
                  CupertinoIcons.profile_circled,
                  size: 48,
                  color: Colors.grey[700],
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: Colors.deepOrange,
                backgroundImage: CachedNetworkImageProvider(user.avatarUrl),
              ),
            );
          },
          loading: () =>
              CircleAvatar(radius: 24, backgroundColor: Colors.grey[800]),
          error: (_, __) => const Icon(
            CupertinoIcons.profile_circled,
            size: 48,
            color: Colors.red,
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
