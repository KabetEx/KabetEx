import 'package:kabetex/features/1community/data/community_repo.dart';
import 'package:kabetex/features/1community/data/models/post.dart';
import 'package:kabetex/features/1community/providers/post_provider.dart';
import 'package:kabetex/features/1community/providers/user_provider.dart';
import 'package:riverpod/legacy.dart';

// Provider
final feedProvider =
    StateNotifierProvider.family<FeedNotifier, FeedState, String?>((
      ref,
      profileUserID,
    ) {
      final repo = ref.read(communityRepoProvider);
      final loggedInUserId =
          ref.watch(currentUserIdProvider) ?? ''; //for like feature

      return FeedNotifier(
        repo: repo,
        currentUserID: loggedInUserId,
        profileUserID: profileUserID, //not null if needs to filter posts
      );
    });

// State
class FeedState {
  final List<Post> posts;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int page;

  FeedState({
    required this.posts,
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.page = 0,
  });

  FeedState copyWith({
    List<Post>? posts,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? page,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
    );
  }
}

// StateNotifier
class FeedNotifier extends StateNotifier<FeedState> {
  final CommunityRepository repo;
  final String currentUserID;
  final String? profileUserID;

  bool _loadingMore = false;

  FeedNotifier({
    required this.repo,
    required this.currentUserID,
    this.profileUserID,
  }) : super(FeedState(posts: [])) {
    fetchPosts();
  }

  // --------------------------
  // PAGINATION: LOAD MORE
  // --------------------------
  Future<void> loadMore() async {
    if (_loadingMore || !state.hasMore) return;

    _loadingMore = true;

    try {
      final nextPage = state.page + 1;

      final raw = await repo.fetchPosts(
        profileUserId: profileUserID,
        currentUserId: currentUserID,
        page: nextPage,
        limit: 3,
      );

      final enriched = await Future.wait(
        raw.map((post) async {
          final isLiked = currentUserID.isEmpty
              ? false
              : await repo.isPostLiked(post.id, currentUserID);
          final likeCount = await repo.getLikeCount(post.id);
          return post.copyWith(isLiked: isLiked, likeCount: likeCount);
        }),
      );

      state = state.copyWith(
        posts: [...state.posts, ...enriched],
        page: nextPage,
        hasMore: enriched.length == 3,
      );
    } catch (_) {
    } finally {
      _loadingMore = false;
    }
  }

  // --------------------------
  // INITIAL FETCH
  // --------------------------
  Future<void> fetchPosts() async {
    state = state.copyWith(isLoading: true, error: null, page: 0);

    try {
      final rawPosts = await repo.fetchPosts(
        profileUserId: profileUserID,
        currentUserId: currentUserID,
        page: 0,
        limit: 3,
      );

      final enrichedPosts = await Future.wait(
        rawPosts.map((post) async {
          final isLiked = currentUserID.isEmpty
              ? false
              : await repo.isPostLiked(post.id, currentUserID);
          final likeCount = await repo.getLikeCount(post.id);
          return post.copyWith(isLiked: isLiked, likeCount: likeCount);
        }),
      );

      state = state.copyWith(
        posts: enrichedPosts,
        isLoading: false,
        hasMore: enrichedPosts.length == 3,
        page: 0,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // --------------------------
  // LIKE / UNLIKE
  // (Optimistic update)
  // --------------------------
  Future<Map<String, dynamic>> toggleLike(String postId) async {
    if (currentUserID.isEmpty) {
      return {
        'isLiked': false,
        'likeCount': state.posts.firstWhere((p) => p.id == postId).likeCount,
      };
    }

    try {
      final index = state.posts.indexWhere((p) => p.id == postId);
      if (index == -1) return {'isLiked': false, 'likeCount': 0};

      final old = state.posts[index];

      // Optimistic update
      final optimistic = old.copyWith(
        isLiked: !old.isLiked,
        likeCount: old.isLiked ? old.likeCount - 1 : old.likeCount + 1,
      );

      final updated = [...state.posts];
      updated[index] = optimistic;
      state = state.copyWith(posts: updated);

      // Update DB
      final result = await repo.toggleLike(postId, currentUserID);

      final confirmed = optimistic.copyWith(
        isLiked: result['isLiked'],
        likeCount: result['likeCount'],
      );

      updated[index] = confirmed;
      state = state.copyWith(posts: updated);

      return {'isLiked': confirmed.isLiked, 'likeCount': confirmed.likeCount};
    } catch (e) {
      return {'isLiked': false, 'likeCount': 0};
    }
  }
}
