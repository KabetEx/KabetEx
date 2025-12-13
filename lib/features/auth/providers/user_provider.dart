import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kabetex/features/1community/data/models/user.dart';
import 'package:kabetex/features/1community/data/user_repo.dart';
import 'package:kabetex/features/auth/providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final userRepo = UserRepository(client: Supabase.instance.client);

final currentUserIdProvider = Provider<String?>((ref) {
  // This makes the provider rebuild whenever auth changes
  ref.watch(authStateProvider);

  final user = Supabase.instance.client.auth.currentUser;
  return user?.id;
});

//returns a userProfile based on the provided ID
final userByIDProvider = FutureProvider.family<UserProfile?, String?>((
  ref,
  userID,
) async {
  final link = ref.keepAlive(); // keeps cached value alive

  // dispose after X minutes to free memory
  final timer = Timer(const Duration(minutes: 10), () {
    link.close();
  });

  ref.onDispose(() {
    timer.cancel();
  });

  return await userRepo.getUserByID(userID);
});

//------------------------------------------------------------
//EDIT PROFILE
//------------------------------------------------------------

final editProfileProvider =
    StateNotifierProvider<EditProfileNotifier, AsyncValue<void>>(
      (ref) => EditProfileNotifier(ref.read(userRepositoryProvider)),
    );

final userRepositoryProvider = Provider(
  (ref) => UserRepository(client: Supabase.instance.client),
);

class EditProfileNotifier extends StateNotifier<AsyncValue<void>> {
  final UserRepository repo;

  EditProfileNotifier(this.repo) : super(const AsyncData(null));

  Future<String?> uploadAvatar(String userId, File file) async {
    state = const AsyncLoading();

    try {
      //get url from supabase
      final url = await repo.uploadAvatar(userId, file);
      state = const AsyncData(null);
      return url;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return null;
    }
  }

  Future<void> updateUser({
    required String userId,
    required String name,
    required String email,
    required String pNumber,
    required int year,
    required String? bio,
    required String? avatarUrl,
  }) async {
    try {
      await repo.updateUser(
        userId: userId,
        name: name,
        year: year,
        bio: bio,
        avatarUrl: avatarUrl,
        email: email,
        pNumber: pNumber,
      );
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }
}
