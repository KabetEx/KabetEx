import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
    } on AuthException {
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

  //-----------------delete account-------------

  Future<bool> deleteUserFromSupabase() async {
    try {
      final userId = user!.id;

      final response = await http.post(
        Uri.parse(
          'https://pxrucvvnywlgpcczrzse.supabase.co/functions/v1/deleteUser',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"userId": userId}),
      );

      if (response.statusCode == 200) {
        print('success');
        return true;
      } else {
        print('Error deleting user: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  // ---------------- AUTH STATE STREAM ----------------
  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;
}
