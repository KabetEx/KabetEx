import 'package:flutter/cupertino.dart';
import 'package:kabetex/features/1community/data/models/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/post.dart';

class CommunityRepository {
  final SupabaseClient client;

  CommunityRepository({required this.client});
  final user = Supabase.instance.client.auth.currentUser;

  //report post
  Future<void> submitReport(
    String postId,
    String reason,
    String details,
    BuildContext context,
  ) async {
    try {
      await Supabase.instance.client.from('post-reports').insert({
        'post_id': postId,
        'reporter_id': user?.id,
        'reason': reason,
        'details': details,
      });
    } catch (e) {
      throw Exception('Failed to submit report: $e');
    }
  }

  // Fetch all posts (and if user liked or not)
  Future<List<Post>> fetchPosts({
    required String currentUserId,
    String? profileUserId,
    String? audience,
    String? userYear,
    int limit = 10,
    required int page,
  }) async {
    final start = page * limit;
    final end = start + limit - 1;

    try {
      var query = client.from('community-posts').select();

      // Profile filter
      if (profileUserId != null) {
        query = query.eq('user_id', profileUserId);
      }

      // Audience filter
      if (audience != null) {
        //classmates filter
        if (audience == 'Classmates' && userYear != null) {
          query = query.eq('year', userYear);
          print('Filtering posts for classmates, year: $userYear');
          //Everyone filter
        } else if (audience == 'For you🔥') {
          // For You🔥: keep unfiltered  
          print('Fetching For You🔥 posts');
        } else {
          // Any other audience
          query = query.eq('audience', audience);
        }
      }

      // Pagination & ordering
      final response = await query
          .order('created_at', ascending: false)
          .range(start, end);

      final data = response as List<dynamic>? ?? [];
      print('Raw posts from DB: ${data.length}');

      final List<Post> posts = [];

      for (final raw in data) {
        final postId = raw['id'] as String;

        final isLiked = currentUserId.isEmpty
            ? false
            : await isPostLiked(postId, currentUserId);

        final likeCount = await getLikeCount(postId);

        posts.add(
          Post.fromMap({...raw, 'isLiked': isLiked, 'likeCount': likeCount}),
        );
      }

      print('Fetched posts: ${posts.length}');
      return posts;
    } catch (e) {
      throw Exception('repo failed to fetch posts $e');
    }
  }

  //delete post
  Future<void> deletePost(String postId) async {
    try {
      await client.from('community-posts').delete().eq('id', postId);
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }

  // Create new post
  Future<Post> createPost({
    required UserProfile userProfile,
    required String content,
    required String audience,
  }) async {
    try {
      final response = await client
          .from('community-posts')
          .insert({
            'user_id': userProfile.id,
            'content': content,
            'full_name': userProfile.name,
            'avatar_url': userProfile.avatarUrl,
            'audience': audience,
            'year': userProfile.year,
          })
          .select()
          .single();

      return Post.fromMap(response);
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  //------------------Like a post--------------------------------//

  // Check if user liked a post
  Future<bool> isPostLiked(String postId, String userId) async {
    final existing = await client
        .from('post-likes')
        .select()
        .eq('post_id', postId)
        .eq('user_id', userId)
        .maybeSingle();

    return existing != null;
  }

  // Get like count for a post
  Future<int> getLikeCount(String postId) async {
    final response = await client
        .from('post-likes')
        .select()
        .eq(
          'post_id',
          postId,
        ); //return list<Post>.length from db eq to the postID

    final data = response as List<dynamic>;
    return data.length;
  }

  // Toggle like (returns new like state and updated count)
  Future<Map<String, dynamic>> toggleLike(String postId, String userId) async {
    try {
      final existing = await client
          .from('post-likes')
          .select()
          .eq('post_id', postId)
          .eq('user_id', userId)
          .maybeSingle();

      bool isLiked;

      if (existing == null) {
        await client.from('post-likes').insert({
          'post_id': postId,
          'user_id': userId,
        });
        isLiked = true;
      } else {
        await client
            .from('post-likes')
            .delete()
            .eq('post_id', postId)
            .eq('user_id', userId);
        isLiked = false;
      }

      final count = await getLikeCount(postId);

      return {'isLiked': isLiked, 'likeCount': count};
    } catch (e) {
      print('Error toggling like: $e');
      throw Exception('Failed to toggle like');
    }
  }
}
