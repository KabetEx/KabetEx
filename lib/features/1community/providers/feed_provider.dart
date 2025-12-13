import 'package:kabetex/features/1community/data/community_repo.dart';
import 'package:kabetex/features/1community/data/models/post.dart';
import 'package:kabetex/features/1community/providers/post_provider.dart';
import 'package:kabetex/features/auth/providers/user_provider.dart';
import 'package:riverpod/legacy.dart';

// Provider
final feedProvider =
    StateNotifierProvider.family<FeedNotifier, FeedState, FeedFilter?>((
      ref,
      feedFilter,
    ) {
      final repo = ref.read(communityRepoProvider);
      final loggedInUserId = ref.watch(currentUserIdProvider) ?? '';

      return FeedNotifier(
        repo: repo,
        currentUserID: loggedInUserId,
        feedFilter: feedFilter,
      );
    });

class FeedFilter {
  final String? profileUID;
  final String? audience;

  const FeedFilter({this.profileUID, this.audience});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedFilter &&
          runtimeType == other.runtimeType &&
          profileUID == other.profileUID &&
          audience == other.audience;

  @override
  int get hashCode => profileUID.hashCode ^ (audience?.hashCode ?? 0);
}

// Feed State
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
  final FeedFilter? feedFilter;

  bool _loadingMore = false;
  String? userYear;

  FeedNotifier({
    required this.repo,
    required this.currentUserID,
    this.feedFilter,
  }) : super(FeedState(posts: [])) {
    _init();
  }

  Future<void> _init() async {
    // fetch user year once
    try {
      final currentUser = await repo.client
          .from('profiles')
          .select('year')
          .eq('id', currentUserID)
          .maybeSingle();

      userYear = currentUser?['year'] as String?;
      print('Current user year: $userYear, userID: $currentUserID`');
    } catch (e, st) {
      print('Failed to fetch user year: $e');
      print(st);
    }

    await fetchPosts();
  }

  // --------------------------
  // FETCH POSTS
  // --------------------------
  Future<void> fetchPosts() async {
    state = state.copyWith(isLoading: true, error: null, page: 0);

    try {
      final rawPosts = await repo.fetchPosts(
        profileUserId: feedFilter?.profileUID,
        audience: feedFilter?.audience,
        currentUserId: currentUserID,
        userYear: userYear,
        page: 0,
        limit: 10,
      );

      final enrichedPosts = await _enrichPosts(rawPosts);

      state = state.copyWith(
        posts: enrichedPosts,
        isLoading: false,
        hasMore: enrichedPosts.length == 10,
        page: 0,
      );
    } catch (e, st) {
      print('FeedNotifier.fetchPosts failed: $e');
      print(st);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // --------------------------
  // LOAD MORE
  // --------------------------
  Future<void> loadMore() async {
    if (_loadingMore || !state.hasMore) return;
    _loadingMore = true;

    try {
      final nextPage = state.page + 1;

      final rawPosts = await repo.fetchPosts(
        profileUserId: feedFilter?.profileUID,
        audience: feedFilter?.audience,
        currentUserId: currentUserID,
        userYear: userYear,
        page: nextPage,
        limit: 10,
      );

      final enrichedPosts = await _enrichPosts(rawPosts);

      state = state.copyWith(
        posts: [...state.posts, ...enrichedPosts],
        page: nextPage,
        hasMore: enrichedPosts.length == 10,
      );
    } catch (e, st) {
      print('FeedNotifier.loadMore failed: $e');
      print(st);
    } finally {
      _loadingMore = false;
    }
  }

  // --------------------------
  // LIKE / UNLIKE
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
      final optimistic = old.copyWith(
        isLiked: !old.isLiked,
        likeCount: old.isLiked ? old.likeCount - 1 : old.likeCount + 1,
      );

      final updated = [...state.posts];
      updated[index] = optimistic;
      state = state.copyWith(posts: updated);

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

  // --------------------------
  // HELPER: ENRICH POSTS
  // --------------------------
  Future<List<Post>> _enrichPosts(List<Post> posts) async {
    return await Future.wait(
      posts.map((post) async {
        final isLiked = currentUserID.isEmpty
            ? false
            : await repo.isPostLiked(post.id, currentUserID);
        final likeCount = await repo.getLikeCount(post.id);
        return post.copyWith(isLiked: isLiked, likeCount: likeCount);
      }),
    );
  }
}
