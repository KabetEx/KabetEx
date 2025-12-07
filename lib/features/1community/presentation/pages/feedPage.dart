import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/common/slide_routing.dart';
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
      ref.invalidate(currentUserIdProvider); //supabase user ID
      ref.invalidate(userByIDProvider); // mark for refresh
      ref.read(userByIDProvider(null).future); // optionally await new data
    });
  }

  Future<void> onRefresh() async {
    ref.invalidate(userByIDProvider);
    ref.read(userByIDProvider(null).future);

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
    final feedState = ref.watch(feedProvider(null)); //dont filter
    final posts = feedState.posts;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const MyCommunityDrawer(),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: isDark ? Colors.black : Colors.transparent,
              elevation: 4,
              expandedHeight: 60,
              leading: Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 8, bottom: 8),
                child: GestureDetector(
                  onTap: () => _scaffoldKey.currentState?.openDrawer(),
                  child: const Icon(CupertinoIcons.bars, size: 38),
                  //later ....
                  // const CircleAvatar(
                  //   radius: 24,
                  //   backgroundImage: NetworkImage(
                  //     'https://i.pravatar.cc/150?img=12',
                  //   ),
                  // ),
                ),
              ),
              centerTitle: true,
              title: GestureDetector(
                onTap: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    "KabetEx",
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(
                    right: 16.0,
                    top: 8,
                    bottom: 8,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.settings_outlined, size: 32),
                    color: isDark ? Colors.white : Colors.black,
                    onPressed: () => Navigator.push(
                      context,
                      SlideRouting(page: const SettingsPage()),
                    ),
                  ),
                ),
              ],
            ),

            // ✅ Conditional Sliver content
            if (feedState.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
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
                    child: PostWidget(
                      post: post,
                      feedNotifier: feedNotifier,
                    ),
                  );
                }, childCount: posts.length),
              ),
          ],
        ),
      ),
    );
  }
}
