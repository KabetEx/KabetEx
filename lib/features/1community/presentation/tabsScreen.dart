import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/1community/presentation/pages/feedPage.dart';
import 'package:kabetex/features/1community/presentation/pages/new_post_page.dart';
import 'package:kabetex/features/1community/presentation/pages/profile_page.dart';
import 'package:kabetex/features/1community/providers/tabs_provider.dart';
import 'package:kabetex/providers/theme_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommunityTabsScreen extends ConsumerStatefulWidget {
  const CommunityTabsScreen({super.key});

  @override
  ConsumerState<CommunityTabsScreen> createState() => _CommunityTabsScreen();
}

class _CommunityTabsScreen extends ConsumerState<CommunityTabsScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    if (index == 1) {
      // Middle add button tapped
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PostTweetPage()),
      );
    } else {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);
    final showBars = ref.watch(bottomBarVisibleProvider);
    final user = Supabase.instance.client.auth.currentUser;

    final List<Widget> pages = [
      const FeedPage(),
      const SizedBox(), // placeholder for middle add button
      CommunityProfilePage(userID: user?.id),
    ];

    return Scaffold(
      body: pages[_currentIndex],
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
                        color: _currentIndex == 0
                            ? Colors.deepOrange
                            : isDark
                            ? Colors.white
                            : Colors.grey[600],
                      ),
                      onPressed: () => _onTabTapped(0),
                    ),
                    const SizedBox(width: 40), // space for the middle button
                    IconButton(
                      icon: Icon(
                        CupertinoIcons.person,
                        color: _currentIndex == 2
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
        backgroundColor: const Color(0xFFFF6F00),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
