import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/1community/data/community_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// final communityPostsProvider = FutureProvider<List<Post>>((ref) async {
//   final repo = CommunityRepository(client: Supabase.instance.client);
//   return repo.fetchPosts();
// });

final communityRepoProvider = Provider(
  (ref) => CommunityRepository(client: Supabase.instance.client),
);
