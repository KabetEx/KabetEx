import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/1community/presentation/widgets/post_widget.dart';
import 'package:kabetex/features/1community/presentation/widgets/drawer.dart';
import 'package:kabetex/features/1community/providers/post_provider.dart';
import 'package:kabetex/features/1community/providers/tabs_provider.dart';
import 'package:kabetex/features/1community/providers/user_provider.dart';
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
      ref.invalidate(currentUserProvider); // mark for refresh
      ref.read(currentUserProvider.future); // optionally await new data
    });
  }

  Future<void> onRefresh() async {
    ref.invalidate(communityPostsProvider);
    ref.invalidate(currentUserProvider);
    await ref.read(
      communityPostsProvider.future,
    ); //wait until posts are refetched

    await Future.delayed(
      const Duration(milliseconds: 600),
    ); //not remove the indicator instantly
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);
    final postsAsync = ref.watch(communityPostsProvider);

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
              backgroundColor: Colors.black,
              elevation: 4,
              expandedHeight: 60,
              leading: Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 16),
                child: GestureDetector(
                  onTap: () => _scaffoldKey.currentState?.openDrawer(),
                  child: const CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/150?img=12',
                    ),
                  ),
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
                  padding: const EdgeInsets.only(right: 16.0, top: 16),
                  child: Icon(
                    Icons.settings_outlined,
                    color: isDark ? Colors.white : Colors.black,
                    size: 32,
                  ),
                ),
              ],
            ),

            postsAsync.when(
              data: (posts) => SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: PostWidget(post: posts[index]),
                  );
                }, childCount: posts.length),
              ),
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => SliverFillRemaining(
                child: Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
