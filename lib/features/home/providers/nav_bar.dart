import 'package:riverpod/legacy.dart';

 
// providers.dart
final tabsProvider = StateProvider<int>((ref) => 0);

final isCommunityLoadingProvider = StateProvider<bool>((ref) => false);

final isLoadingMarketprovider = StateProvider<bool>((ref) => false);
