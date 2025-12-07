import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/user.dart';

class UserRepository {
  final SupabaseClient client;

  UserRepository({required this.client});


  // Get userProfile by ID
  Future<UserProfile?> getUserByID(String? userID) async {
    //final user = client.auth.currentUser;

    if (userID == null) return null;

    final response = await client
        .from('profiles')
        .select()
        .eq('id', userID)
        .maybeSingle();

    if (response == null) return null;
    return UserProfile.fromMap(response);
  }

  // Create or update user in DB
  Future<void> updateInsert(UserProfile user) async {
    await client.from('profiles').upsert(user.toMap());
  }
}
