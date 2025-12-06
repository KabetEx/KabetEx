import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/1community/data/community_repo.dart';
import 'package:kabetex/features/1community/data/models/user.dart';
import 'package:kabetex/features/1community/data/user_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final repo = CommunityRepository(client: Supabase.instance.client);

final userRepo = UserRepository(client: Supabase.instance.client);

final currentUserProvider = FutureProvider<UserProfile?>((ref) async {
  final supabaseUser = Supabase.instance.client.auth.currentUser;
  if (supabaseUser == null) return null;

  return await userRepo.getCurrentUser();
});
