import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/1community/presentation/pages/feed_page.dart';
import 'package:kabetex/features/1community/presentation/pages/new_post_page.dart';
import 'package:kabetex/features/1community/presentation/pages/profile_page.dart';
import 'package:kabetex/features/1community/providers/tabs_provider.dart';
import 'package:kabetex/features/1community/providers/user_provider.dart';
import 'package:kabetex/providers/theme_provider.dart';

class CommunityTabsScreen extends ConsumerStatefulWidget {
  const CommunityTabsScreen({super.key});

  @override
  ConsumerState<CommunityTabsScreen> createState() => _CommunityTabsScreen();
}

class _CommunityTabsScreen extends ConsumerState<CommunityTabsScreen> {
  final int _previousIndex = 0;

  void _onTabTapped(int index) {
    if (index == 1) {
      // Middle add button tapped
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const PostTweetPage(),

          transitionDuration: const Duration(microseconds: 150),

          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      );
    } else {
      ref.read(communityTabsProvider.notifier).state = index;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(communityTabsProvider);
    final isDark = ref.watch(isDarkModeProvider);
    final showBars = ref.watch(bottomBarVisibleProvider);
    final userID = ref.watch(currentUserIdProvider);

    final List<Widget> pages = [
      const FeedPage(),
      const SizedBox(), // placeholder for middle add button
      CommunityProfilePage(userID: userID),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          // Slide from right if going forward, left if going back
          final currentIndex = ref.watch(communityTabsProvider);
          final previousIndex =
              _previousIndex; // you'll need a variable in your state
          final isForward = currentIndex >= previousIndex;

          final offsetAnimation = Tween<Offset>(
            begin: Offset(isForward ? 1.0 : -1.0, 0),
            end: Offset.zero,
          ).animate(animation);

          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(ref.watch(communityTabsProvider)),
          child: pages[ref.watch(communityTabsProvider)],
        ),
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: showBars ? 60 : 0,
        child: showBars
            ? BottomAppBar(
                shape: const CircularNotchedRectangle(),
                notchMargin: 4,
                color: isDark ? Colors.grey[900] : Colors.white,
                elevation: 8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: Icon(
                        CupertinoIcons.home,
                        color: currentIndex == 0
                            ? Colors.deepOrange
                            : isDark
                            ? Colors.white
                            : Colors.grey[600],
                      ),
                      onPressed: () => _onTabTapped(0),
                    ),
                    const SizedBox(width: 40),
                    IconButton(
                      icon: Icon(
                        CupertinoIcons.person,
                        color: currentIndex == 2
                            ? Colors.deepOrange
                            : isDark
                            ? Colors.white
                            : Colors.grey[600],
                      ),
                      onPressed: () => _onTabTapped(2),
                    ),
                  ],
                ),
              )
            : const SizedBox(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onTabTapped(1),
        backgroundColor: Colors.deepOrange,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
