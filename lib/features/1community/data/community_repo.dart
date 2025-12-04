import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/post.dart';

class CommunityRepository {
  final SupabaseClient client;

  CommunityRepository({required this.client});

  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;

    final response = await client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();
    print(response);

    return response;
  }

  // Fetch all posts
  Future<List<Post>> fetchPosts(String userId) async {
    try {
      final response = await client
          .from('community-posts')
          .select()
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;

      List<Post> posts = [];

      for (final raw in data) {
        final postId = raw['id'] as String;

        final isLiked = userId.isEmpty
            ? false
            : await isPostLiked(postId, userId);
        final likeCount = await getLikeCount(postId);

        posts.add(
          Post.fromMap({...raw, 'isLiked': isLiked, 'likeCount': likeCount}),
        );
      }

      return posts;
    } catch (e) {
      print('error fetching posts $e');
      throw Exception('Failed to fetch $e');
    }
  }

  // Create new post
  Future<Post> createPost({
    required String userId,
    required String content,
    String? imageUrl,
    required String fullName,
  }) async {
    try {
      final response = await client
          .from('community-posts')
          .insert({
            'user_id': userId,
            'content': content,
            'full_name': fullName,
          })
          .select()
          .single();

      return Post.fromMap(response);
    } catch (e) {
      print('Failed to create post: $e');
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
