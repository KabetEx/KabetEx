import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/1community/presentation/feedPage.dart';
import 'package:kabetex/features/1community/presentation/postTweetPage.dart';
import 'package:kabetex/features/profile/presentantion/profile_page.dart';
import 'package:kabetex/features/home/presentations/home_page.dart';
import 'package:kabetex/providers/theme_provider.dart';

class CommunityTabsScreen extends ConsumerStatefulWidget {
  const CommunityTabsScreen({super.key});

  @override
  ConsumerState<CommunityTabsScreen> createState() => _CommunityTabsScreen();
}

class _CommunityTabsScreen extends ConsumerState<CommunityTabsScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const FeedPage(),
    const SizedBox(), // placeholder for middle add button
    const ProfilePage(),
  ];

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

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 4,
        color: isDark ? Colors.grey[900] : Colors.white,
        elevation: 8,
        child: SizedBox(
          height: 16,
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
        ),
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
