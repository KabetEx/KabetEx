import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/1community/widgets/post_widget.dart';
import 'package:kabetex/features/1community/widgets/drawer.dart';
import 'package:kabetex/providers/theme_provider.dart';

class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({super.key});

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);

    return Scaffold(
      key: _scaffoldKey,
      drawer: const MyCommunityDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 4,
            expandedHeight: 60,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16.0),
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
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Icon(
                  Icons.settings_outlined,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: PostWidget(
                  username: 'Moha',
                  timeAgo: 'Yesterday',
                  content: 'Test content',
                  profileUrl: 'https://i.pravatar.cc/150?img=3',
                ),
              );
            }, childCount: 70),
          ),
        ],
      ),
    );
  }
}
