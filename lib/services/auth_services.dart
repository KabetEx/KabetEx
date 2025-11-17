import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;
  final user = Supabase.instance.client.auth.currentUser;

  // ---------------- SIGN UP ----------------
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String year,
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      // 🔥 If user is null → signup failed → throw AuthException manually
      if (response.user == null) {
        throw const AuthException('Signup failed.');
      }

      // Create profile after successful signup
      await createProfile(
        id: response.user!.id,
        name: name,
        email: email,
        phone: phone,
        year: year,
      );
      print('User signed up and profile created!');
    } on AuthException catch (error) {
      rethrow;
    } catch (e) {
      // 🔥 rethrow general errors too so UI can show them
      throw Exception('Unexpected Error: $e');
    }
  }

  // ---------------- LOGIN ----------------
  Future<void> signInfcn({
    required String email,
    required String password,
  }) async {
    try {
      final res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      //successful login
      if (res.session != null) {
        print('Logged in as: ${res.user?.email}');
      } else {
        print('Login failed: session is null.');
      }
    } on AuthException catch (error) {
      throw AuthException(error.message);
    } catch (e) {
      // 🔥 Send unexpected errors to UI too
      throw Exception('Unexpected Error: $e');
    }
  }

  // ---------------- SIGN OUT ----------------
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
      print('User signed out');
    } catch (e) {
      print('SignOut Error: $e');
    }
  }

  // ---------------- CREATE PROFILE ----------------
  Future<void> createProfile({
    required String id,
    required String name,
    required String email,
    required String phone,
    required String year,
  }) async {
    try {
      final res = await supabase.from('profiles').insert({
        'id': id,
        'full_name': name,
        'email': email,
        'phone_number': phone,
        'year': year,
      });
      print('Profile Insert Response: $res');
    } catch (e) {
      print('Create Profile Error: $e');
    }
  }

  // ---------------- FETCH PROFILE ----------------
  Future<Map<String, dynamic>?> getProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final res = await supabase
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
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      await supabase.from('profiles').update(updates).eq('id', user.id);
      print('Profile updated');
    } catch (e) {
      print('Update Profile Error: $e');
    }
  }

  // ---------------- AUTH STATE STREAM ----------------
  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;
  
}
