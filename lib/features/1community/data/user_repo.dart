import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/user.dart';

class UserRepository {
  final SupabaseClient client;

  UserRepository({required this.client});

  final supabase = Supabase.instance.client;

  // Upload avatar
  Future<String> uploadAvatar(String userId, File file) async {
    final filePath =
        'avatars/$userId-${DateTime.now().millisecondsSinceEpoch}.jpg';

    await supabase.storage
        .from('profile-images')
        .upload(filePath, file, fileOptions: const FileOptions(upsert: true));

    final publicUrl = supabase.storage
        .from('profile-images')
        .getPublicUrl(filePath);
    return publicUrl;
  }

  // Update user
  Future<void> updateUser({
    required String userId,
    required String name,
    required String email,
    required String pNumber,
    required String year,
    required String? bio,
    required String? avatarUrl,
  }) async {
    await supabase
        .from('profiles')
        .update({
          'full_name': name,
          'bio': bio,
          'email': email,
          'phone_number': pNumber,
          'year': year,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
        })
        .eq('id', userId);
  }

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
}
