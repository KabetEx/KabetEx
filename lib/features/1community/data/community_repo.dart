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
  Future<List<Post>> fetchPosts() async {
    try {
      final response = await client
          .from('community-posts')
          .select()
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;
      return data.map((e) => Post.fromMap(e)).toList();
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
    required String full_name
  }) async {
    // final profile = await getCurrentUserProfile() ?? {};
    // String userfullName = profile['full_name'] ?? '';

    // if (userfullName.isEmpty)
    //   throw Exception('Cannot create post: missing user name');

    try {
      final response = await client
          .from('community-posts')
          .insert({
            'user_id': userId,
            'content': content,
            'likes': [],
            'full_name': full_name,
          })
          .select()
          .single();

      return Post.fromMap(response);
    } catch (e) {
      print('Failed to create post: $e');
      throw Exception('Failed to create post: $e');
    }
  }

  // Like a post
  Future<void> likePost(String postId, String userId) async {
    try {
      // 1️⃣ Fetch current likes from a post
      final post = await client
          .from('community-posts')
          .select('likes')
          .eq('id', postId)
          .maybeSingle();

      if (post == null) {
        throw Exception('Post not found');
      }

      //store to a List variable
      List<String> likes = List<String>.from(post['likes'] ?? []);

      // 2️⃣ Toggle like
      if (!likes.contains(userId)) {
        likes.add(userId); // like
      } else {
        likes.remove(userId); // unlike
      }

      // 3️⃣ Update post
      await client
          .from('community-posts')
          .update({'likes': likes})
          .eq('id', postId);
    } catch (e) {
      print('Error liking/unliking post: $e');
      throw Exception('Failed to like/unlike post');
    }
  }
}
