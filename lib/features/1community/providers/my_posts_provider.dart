import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/1community/data/models/post.dart';
import 'package:kabetex/features/1community/providers/feed_provider.dart';

final profilePostsProvider = FutureProvider.family<List<Post>, String>((
  ref,
  userId,
) async {
  final feedState = ref.watch(
    feedProvider({'profileUID': userId}),
  ); //filters posts
  final posts = feedState.posts;

  return posts;
});
