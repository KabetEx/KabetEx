import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/user.dart';

class UserRepository {
  final SupabaseClient client;

  UserRepository({required this.client});

  // Get current user
  Future<UserProfile?> getCurrentUser() async {
    final user = client.auth.currentUser;

    if (user == null) return null;

    final response = await client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (response == null) return null;
    return UserProfile.fromMap(response);
  }

  // Create or update user in DB
  Future<void> updateInsert(UserProfile user) async {
    await client.from('profiles').upsert(user.toMap());
  }
}
