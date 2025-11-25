import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileServices {
  final _supabase = Supabase.instance.client;

  // ---------------- FETCH PROFILE ----------------
  Future<Map<String, dynamic>?> getProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final res = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return res;
    } catch (e) {
      print('Get Profile Error: $e');
    }

    return null;
  }

  // ---------------- UPDATE PROFILE ----------------
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase.from('profiles').update(updates).eq('id', user.id);
      print('Profile updated');
    } catch (e) {
      rethrow;
    }
  }

  //get user Full name
  Future<String> getUserFname() async {
    final profile = await ProfileServices().getProfile();

    return profile!['full_name'] as String;
  }

  Future<bool> isVerified() async {
    final profile = await ProfileServices().getProfile();

    return profile!['isVerified'] as bool;
  }
}
