import 'package:kabetex/features/1community/data/community_repo.dart';
import 'package:kabetex/features/1community/data/models/post.dart';
import 'package:kabetex/features/1community/providers/post_provider.dart';
import 'package:kabetex/features/1community/providers/user_provider.dart';
import 'package:riverpod/legacy.dart';

// Provider
final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  final repo = ref.read(communityRepoProvider);
  final user = ref.watch(currentUserProvider).value;
  // if (user == null) {
  //   throw Exception('User not logged in');
  // }

  return FeedNotifier(repo: repo, userId: user?.id ?? '');
});

// State
class FeedState {
  final List<Post> posts;
  final bool isLoading;
  final String? error;

  FeedState({required this.posts, this.isLoading = false, this.error});

  FeedState copyWith({List<Post>? posts, bool? isLoading, String? error}) {
    return FeedState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// StateNotifier
class FeedNotifier extends StateNotifier<FeedState> {
  final CommunityRepository repo;
  final String userId;

  FeedNotifier({required this.repo, required this.userId})
    : super(FeedState(posts: [])) {
    fetchPosts();
  }

  // ------------------------
  // FETCH POSTS (with isLiked + likeCount)
  // ------------------------
  Future<void> fetchPosts() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      //raw posts from db
      final rawPosts = await repo.fetchPosts(userId);

      // Enrich posts with more info such as isliked and likecount
      final enrichedPosts = await Future.wait(
        rawPosts.map((post) async {
          final isLiked = userId.isEmpty
              ? false
              : await repo.isPostLiked(post.id, userId);
          final likeCount = await repo.getLikeCount(post.id);

          return post.copyWith(isLiked: isLiked, likeCount: likeCount);
        }),
      );

      //updating
      state = state.copyWith(posts: enrichedPosts, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ------------------------
  // OPTIMISTIC UPDATE TOGGLE LIKE (instant animation)
  // ------------------------
  Future<Map<String, dynamic>> toggleLike(String postId) async {
    if (userId.isEmpty) {
      // Guest users cannot like
      return {
        'isLiked': false,
        'likeCount': state.posts.firstWhere((p) => p.id == postId).likeCount,
      };
    }

    try {
      final index = state.posts.indexWhere(
        (p) => p.id == postId,
      ); //index is pstn of post
      //if not found (post not liked by user)
      if (index == -1) return {'isLiked': false, 'likeCount': 0};

      //---otherwise if post exists
      final old =
          state.posts[index]; //snapshot of the old post (Not optimised )

      // 1 — Optimistic update
      final optimistic = old.copyWith(
        isLiked: !old.isLiked,
        likeCount: old.isLiked
            ? old.likeCount - 1
            : old.likeCount + 1, //like or unlike
      );

      final updatedPosts = [...state.posts];
      updatedPosts[index] = optimistic; //mathch old post to new
      state = state.copyWith(posts: updatedPosts); //update state

      // 2 — Update DB in background
      final result = await repo.toggleLike(postId, userId);

      // 3 — Confirm DB truth
      final confirmed = optimistic.copyWith(
        isLiked: result['isLiked'],
        likeCount: result['likeCount'],
      );

      updatedPosts[index] = confirmed;
      state = state.copyWith(posts: updatedPosts);

      // ✅ Return the latest like info
      return {'isLiked': confirmed.isLiked, 'likeCount': confirmed.likeCount};
    } catch (e) {
      print('toggle like error: $e');
      return {'isLiked': false, 'likeCount': 0};
    }
  }
}
