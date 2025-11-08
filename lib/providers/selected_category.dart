import 'package:riverpod/legacy.dart';

final selectedCategoryProvider = StateProvider<String>((ref) {
  return 'all';
});
