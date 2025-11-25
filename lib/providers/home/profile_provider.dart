import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/auth/data/auth_services.dart';

final futureProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) {
  return AuthService().getProfile();
});
