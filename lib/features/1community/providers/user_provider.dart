import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/1community/data/community_repo.dart';
import 'package:kabetex/features/1community/data/models/user.dart';
import 'package:kabetex/features/1community/data/user_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final repo = CommunityRepository(client: Supabase.instance.client);

// final getUserProfile = FutureProvider<Map<String, dynamic>?>((ref) async {
//   final userProfile = await repo.getCurrentUserProfile();

//   return userProfile;
// });

// final getUserFNameProvider = FutureProvider<String>((ref) async {
//   final profileAsync = await ref.watch(getUserProfile.future);
//   return profileAsync?['full_name'] ?? 'Unknown User';
// });

final userRepo = UserRepository(client: Supabase.instance.client);

final currentUserProvider = FutureProvider<UserProfile?>((ref) async {
  final supabaseUser = Supabase.instance.client.auth.currentUser;
  if (supabaseUser == null) return null;

  return await userRepo.getCurrentUser();
});
