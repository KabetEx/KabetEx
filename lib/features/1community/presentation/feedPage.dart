import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/common/slide_routing.dart';
import 'package:kabetex/features/1community/presentation/postTweetPage.dart';
import 'package:kabetex/features/1community/widgets/post_widget.dart';
import 'package:kabetex/providers/theme_provider.dart';

class Feedpage extends ConsumerStatefulWidget {
  const Feedpage({super.key});

  @override
  ConsumerState<Feedpage> createState() => _FeedpageState();
}

class _FeedpageState extends ConsumerState<Feedpage> {
  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Icon(
            Icons.account_circle,
            color: isDark ? Colors.white : Colors.black,
            size: 32,
          ),
        ),
        title: Text(
          'KabetEx',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 28,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: PopupMenuButton(
              itemBuilder: (_) => [
                const PopupMenuItem(child: Text('Settings')),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.push(context, SlideRouting(page: const PostTweetPage())),
        backgroundColor: const Color(
          0xFFFF6F00,
        ), // keep consistent accent color
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: 4,
        itemBuilder: (context, index) {
          return const PostWidget(
            username: 'Moha',
            timeAgo: 'Yesterday',
            content: 'Test contetn',
            profileUrl: 'test',
          );
        },
      ),
    );
  }
}
