import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kabetex/features/1community/data/models/user.dart';
import 'package:kabetex/features/1community/data/user_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final userRepo = UserRepository(client: Supabase.instance.client);

final currentUserIdProvider = Provider<String?>((ref) {
  return Supabase.instance.client.auth.currentUser?.id;
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
    required String? bio,
    required String? avatarUrl,
  }) async {
    state = const AsyncLoading();
    try {
      await repo.updateUser(
        userId: userId,
        name: name,
        bio: bio,
        avatarUrl: avatarUrl,
      );
      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}
