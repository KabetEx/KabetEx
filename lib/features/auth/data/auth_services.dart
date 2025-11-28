import 'dart:async';
import 'dart:io';

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
      final response = await supabase.auth
          .signUp(email: email, password: password)
          .timeout(const Duration(seconds: 10));

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
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } on SocketException {
      throw Exception(
        'No internet connection. Please check your WiFi or data.',
      );
    } on TimeoutException {
      throw Exception('Request timed out. Your internet is probably off.');
    } catch (e) {
      // Any other Supabase/Unexpected error
      throw e.toString();
    }
  }

  // ---------------- LOGIN ----------------
  Future<void> signInfcn({
    required String email,
    required String password,
  }) async {
    try {
      await supabase.auth
          .signInWithPassword(email: email, password: password)
          .timeout(const Duration(seconds: 10));
    } on AuthException catch (error) {
      throw error.message;
    } on SocketException {
      throw Exception(
        'No internet connection. Please check your WiFi or data.',
      );
    } on TimeoutException {
      throw Exception('Request timed out. Your internet is probably off.');
    } on http.ClientException {
      throw Exception(
        'No internet connection. Please check your WiFi or data.',
      );
    } catch (e) {
      // Any other Supabase/Unexpected error
      throw e.toString();
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
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final currentUser = Supabase.instance.client.auth.currentUser;

    // if logged out, return null instead of crashing
    if (currentUser == null) return null;

    final profile = await supabase
        .from('profiles')
        .select()
        .eq('id', currentUser.id)
        .maybeSingle();

    return profile;
  }

  //-----------------delete account-------------
  Future<bool> deleteUserFromSupabase() async {
    try {
      final userId = user!.id;

      // 1️⃣ Delete auth user via Supabase Function
      final response = await http.post(
        Uri.parse(
          'https://pxrucvvnywlgpcczrzse.functions.supabase.co/deleteUser',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      );

      print("Response: ${response.statusCode}   ${response.body}");

      if (response.statusCode != 200) return false;

      // 2️⃣ Delete profile locally
      await supabase.from('profiles').delete().eq('id', userId);

      // 3️⃣ Fetch all user products
      final productsRes = await supabase
          .from('products')
          .select('id, image_urls')
          .eq('seller_id', userId);
      final products = productsRes as List<dynamic>?;

      if (products != null && products.isNotEmpty) {
        for (final product in products) {
          final productId = product['id'] as String;
          final imageUrls = (product['image_urls'] as List<dynamic>)
              .cast<String>();

          // Extract storage paths
          final paths = imageUrls
              .map((url) => url.split('/product-images/').last)
              .toList();

          // Delete images
          if (paths.isNotEmpty) {
            await supabase.storage.from('product-images').remove(paths);
          }

          // Delete product
          await supabase.from('products').delete().eq('id', productId);
        }
      }

      // 4️⃣ Finally, logout
      await supabase.auth.signOut();

      return true;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  // ---------------- AUTH STATE STREAM ----------------
  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;
}
