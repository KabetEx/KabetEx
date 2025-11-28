import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/auth/data/auth_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//used for current logged in user
final futureProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) {
  return AuthService().getProfile();
});

//used in product details page
final sellerProfileProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, sellerId) async {
      try {
        final supabase = Supabase.instance.client;
        final res = await supabase
            .from('profiles')
            .select('id, full_name, phone_number, isVerified')
            .eq('id', sellerId)
            .maybeSingle();

        print('seller profile: $sellerId');

        return res; // returns null if not found
      } catch (e) {
        print('Error fetching profile $e');
        throw Exception('Failed to fetch seller profile');
      }
    });
