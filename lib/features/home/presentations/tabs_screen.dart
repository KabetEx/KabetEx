import 'package:flutter/material.dart';
import 'package:kabetex/features/1community/presentation/pages/feed_page.dart';
import 'package:kabetex/features/home/presentations/home_page.dart';
import 'package:kabetex/features/profile/presentantion/profile_page.dart';
import 'package:kabetex/features/home/providers/nav_bar.dart';
import 'package:kabetex/providers/theme_provider.dart';
import 'package:kabetex/features/home/widgets/bottom_nav_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TabsScreen extends ConsumerWidget {
  const TabsScreen({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(tabsProvider);
    final isDark = ref.watch(isDarkModeProvider);

    //Common bottom nav bar
    final pages = [const HomePage(), const FeedPage(), const AccountPage()];

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: GithubStyleBottomBar(
        currentIndex: currentIndex,
        isDarkMode: isDark,
        onTap: (index) {
          ref.read(tabsProvider.notifier).state = index;
        },
      ),
    );
  }
}
